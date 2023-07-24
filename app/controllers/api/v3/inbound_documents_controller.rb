### TODO : Refactor in a service ###
class Api::V3::InboundDocumentsController < Api::V3::MainController
  def create        
    if user && ledger
      dir = CustomUtils.mktmpdir('temp_document_controller', nil, false)

      filename = File.join(dir, "#{user.code}_#{allowed_params[:filename]}")

      File.open(filename, 'wb') do |f|
        f.write(Base64.decode64(allowed_params[:content_base64]))
      end

      uploaded_document = UploadedDocument.new(File.open(filename),
                                            allowed_params[:filename],
                                            user,
                                            ledger.name,
                                            0,
                                            user,
                                            allowed_params[:source] || "upload_api_v3",
                                            nil,
                                            allowed_params[:source_identifier],
                                            true,
                                            nil)
    end

    if uploaded_document && uploaded_document.errors.any?
      render json: uploaded_document.try(:errors).flatten, status: :unprocessable_entity
    elsif !user || !ledger
      head(404)
    elsif (user && !user.in?(authenticated_organization.users)) || (user && user.inactive?)
      head(403)
    else
      head(201)
    end
  end

  protected

  def user
    begin
      user = if allowed_params[:user_id]
        authenticated_organization.customers.find(allowed_params[:user_id])
      elsif allowed_params[:user_code]
        authenticated_organization.customers.find_by(code: allowed_params[:user_code])
      elsif allowed_params[:user_legal_identifier]
        authenticated_organization.customers.find_by(registration_number: allowed_params[:user_legal_identifier])
      end
    rescue
      user = nil
    end
  end

  def ledger
    if user
      ledger = if allowed_params[:ledger_id]
        user.account_book_types.find(allowed_params[:ledger_id])
      elsif allowed_params[:ledger_name]
        user.account_book_types.find_by(name: allowed_params[:ledger_name])
      end
    end
  end

  private

  def allowed_params
    params.permit!
  end

  def serializer
    V3::TempDocumentSerializer
  end
end
