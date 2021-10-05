# frozen_string_literal: true
class News::MainController < FrontController
  layout false

  prepend_view_path('app/templates/front/news/views')

  def index
    @news_present = @user.news_read_at ? News.published.where('published_at > ?', @user.news_read_at).exists? : News.exists?
    if @news_present
      @news = ::News.published.where(target_audience: target_audience).order(created_at: :desc).limit(5)
      @user.update_column(:news_read_at, Time.now)
    end

    render partial: 'index'
  end

  private

  def target_audience
    @user.is_prescriber ? %w[everyone collaborators] : %w[everyone customers]
  end
end