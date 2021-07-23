# frozen_string_literal: true

class Documents::PreseizuresController < FrontController
  append_view_path('app/templates/front/documents/views')

  before_action :load_preseizure, except: %w[accounts_list]

  def show
    if params[:view] == 'by_type'
      if @preseizure.operation
        render file: Rails.root.join('app/templates/front/documents/views/documents/operations/_operation_box.html.haml'), locals: { preseizure: @preseizure }
      else
        @pieces = [@preseizure.piece]
        render file: Rails.root.join('app/templates/front/documents/views/documents/pieces/_piece_box.html.haml')
      end
    else
      render partial: 'show'
    end
  end

  def update
    if @user.has_collaborator_action?
      error = ''
      if params[:partial_update].present?
        @preseizure.date = params[:date] if params[:date].present?
        if params[:deadline_date].present?
          @preseizure.deadline_date  = params[:deadline_date]
        end
        if params[:third_party].present?
          @preseizure.third_party    = params[:third_party]
        end

        error = @preseizure.errors.full_messages unless @preseizure.save
      else
        @preseizure.assign_attributes params[:pack_report_preseizure].permit(:date, :deadline_date, :third_party, :operation_label, :piece_number, :amount, :currency, :conversion_rate, :observation)
        if @preseizure.conversion_rate_changed? || @preseizure.amount_changed?
          @preseizure.update_entries_amount
        end

        error = @preseizure.errors.full_messages unless @preseizure.save
      end

      render json: { error: error }, status: 200
    else
      render json: { error: "Authorisation requise" }, status: 200
    end
  end

  def update_account
    if @user.has_collaborator_action?
      error = ''
      if params[:type] == 'account'
        account = Pack::Report::Preseizure::Account.find params[:account_id]
        account.number = params[:new_value]
        error = account.errors.full_messages if not account.save
      elsif params[:type] == 'entry'
        entry = Pack::Report::Preseizure::Entry.find params[:account_id]
        entry.amount = params[:new_value]
        error = entry.errors.full_messages if not entry.save
      elsif params[:type] == 'change_type'
        entry = Pack::Report::Preseizure::Entry.find params[:account_id]
        entry.type = params[:new_value]
        error = entry.errors.full_messages if not entry.save
      end

      render json: { error: error }, status: 200
    else
      render json: { error: '' }, status: 200
    end
  end

  def accounts_list
    account        = Pack::Report::Preseizure::Account.find params[:account_id]
    @accounts_name = account.get_similar_accounts

    render partial: 'accounts_list'
  end

  private

  def load_preseizure
    @preseizure = Pack::Report::Preseizure.find params[:id]
  end
end
