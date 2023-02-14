class ExportPreseizuresMailer < BaseMailer
  def notify_success
    mail(to: @user.email, subject: "[iDocus] Notification : Documents prêts", content_type: "text/html")
  end


  def notify_failure
    mail(to: @user.email, subject: "[iDocus] Erreur : Préparation de documents échouée ", content_type: "text/html")
  end


end
