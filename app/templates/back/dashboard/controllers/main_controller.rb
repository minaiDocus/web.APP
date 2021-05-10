# frozen_string_literal: true
class Admin::Dashboard::MainController < BackController
  append_view_path('app/templates/back/dashboard/views')

  def index
    @new_provider_requests = NewProviderRequest.not_processed.order(created_at: :desc).includes(:user).limit(5)
    @unbillable_organizations = Organization.billed.select { |e| e.billing_address.nil? }
  end

  # GET /admin/ocr_needed_temp_packs
  def ocr_needed_temp_packs
    @ocr_needed_temp_packs = TempDocument.where(state: 'ocr_needed').group(:temp_pack_id).includes(:temp_pack).map do |data|
      object = OpenStruct.new
      object.date           = data.try(:updated_at).try(:localtime)
      object.name           = data.temp_pack.name.sub(/ all\z/, '')
      object.document_count = data.temp_pack.temp_documents.ocr_needed.count
      object.message        = false
      object
    end

    render partial: 'ocr_needed_temp_packs', locals: { collection: @ocr_needed_temp_packs }
  end

end