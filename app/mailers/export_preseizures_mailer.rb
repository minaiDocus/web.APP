class ExportPreseizuresMailer < BaseMailer
  def notify_success(user)
    mail(to: user.email, subject: "[iDocus] Notification : Documents prêts", content_type: "text/html")
  end

  def notify_failure(user)
    mail(to: user.email, subject: "[iDocus] Erreur : Préparation de documents échouée ", content_type: "text/html")
  end
end
