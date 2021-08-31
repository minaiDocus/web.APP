# frozen_string_literal: true
class Notifications::MainController < FrontController
  skip_before_action :verify_suspension, only: :latest, raise: false
  skip_before_action :verify_if_active, raise: false
  before_action :load_notifications, except: :link_through

  prepend_view_path('app/templates/front/notifications/views')

  def index
    @notifications.update_all is_read: true, updated_at: Time.now
  end

  def latest
    if organizations_suspended?
      render body: nil
    else
      render partial: 'notifications', layout: false, locals: { notifications: @notifications }
    end
  end

  def link_through
    notification = Notification.find params[:id]
    notification.update is_read: true if notification.user == true_user
    redirect_to notification.url
  end

  def unread_all_notifications
    if params[:unread].presence
      @user.notifications.update_all is_read: true, updated_at: Time.now
    end
  end

  private

  def load_notifications
    @notifications = @user.notifications.order(is_read: :asc, created_at: :desc).page(params[:page]).per(params[:per_page])
  end
end