# frozen_string_literal: true
class ExternalFileStorages::GoogleDriveController < FrontController
  before_action :verify_authorization
  before_action :load_google_doc

  def authorize_url
    session[:google_drive_state] = SecureRandom.hex(30)

    redirect_to Gdr::Client.new.authorize_url(callback_google_drive_url, session[:google_drive_state])
  end

  def callback
    if params[:state].present? && params[:state] == session[:google_drive_state]
      if params[:code].present?
        begin
          client = Gdr::Client.new
          client.authorize(params[:code], callback_google_drive_url)

          @google_doc.access_token            = client.access_token.token
          @google_doc.refresh_token           = client.access_token.refresh_token
          @google_doc.is_configured           = true
          @google_doc.access_token_expires_at = Time.at client.access_token.expires_at

          @google_doc.save

          flash[:success] = 'Votre compte Google Drive a été configuré avec succès.'
        rescue OAuth2::Error
          flash[:error] = 'Impossible de configurer votre compte Google Drive.'
        end
      elsif params[:error] == 'access_denied'
        flash[:error] = "Vous avez refusé l'accès à votre compte Google Drive."
      end
    else
      flash[:error] = 'La requête est invalide ou a expiré.'
    end

    session[:google_drive_state] = nil

    redirect_to profiles_path
  end

  private

  def verify_authorization
    unless @user.find_or_create_external_file_storage.is_google_docs_authorized?
      flash[:error] = "Vous n'êtes pas autorisé à utiliser Google Drive."
      redirect_to profiles_path
    end
  end

  def load_google_doc
    @google_doc = @user.find_or_create_external_file_storage.google_doc
  end
end