# frozen_string_literal: true
class FtpsSetting::UserController < FrontController
  before_action :verify_authorization
  before_action :load_sftp

  prepend_view_path('app/templates/front/ftps/views')

  def edit; end

  def update
    @sftp.assign_attributes(ftp_params)
    if @sftp.valid? && Ftp::VerifySettings.new(@sftp, current_user.code).execute
      @sftp.is_configured = true
      @sftp.save
      flash[:success] = 'Votre compte FTP a été configuré avec succès.'
      redirect_to account_profile_path(anchor: 'sftp', panel: 'efs_management')
    else
      flash[:error] = @sftp.reload.error_message
      render :edit
    end
  end

  def destroy
    @sftp.reset_info
    flash[:success] = 'Vos paramètres FTP ont été réinitialisé.'
    redirect_to account_profile_path(anchor: 'sftp', panel: 'efs_management')
  end

  private

  def verify_authorization
    unless @user.find_or_create_external_file_storage.is_ftp_authorized?
      flash[:error] = "Vous n'êtes pas autorisé à utiliser FTP."
      redirect_to account_profile_path(panel: 'efs_management')
    end
  end

  def load_sftp
    @sftp = @user.find_or_create_external_file_storage.sftp
  end

  def ftp_params
    params.require(:sftp).permit(:host, :port, :is_passive, :login, :password)
  end
end