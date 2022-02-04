# -*- encoding : UTF-8 -*-
class WelcomeMailer < BaseMailer
  def welcome_customer(user, token)
    @user   = user
    @token = token

    if @user.organization&.code == "ALM"
      mail(to: @user.email, subject: '[Axelium] Création de compte Axelium')
    else
      mail(to: @user.email, subject: '[iDocus] Création de compte iDocus')
    end
  end

  def welcome_collaborator(collaborator, token)
    @token = token
    @collaborator = collaborator

    if "ALM".in?(@collaborator.organizations.pluck(:code))
      mail(to: @collaborator.email, subject: '[Axelium] Création de compte Axelium')
    else
      mail(to: @collaborator.email, subject: '[iDocus] Création de compte iDocus')
    end
  end

  def welcome_guest_collaborator(guest, token)
    @token = token
    @guest = guest

    if @guest.organization&.code == "ALM"
      mail(to: @guest.email, subject: '[Axelium] Création de compte Axelium')
    else
      mail(to: @guest.email, subject: '[iDocus] Création de compte iDocus')
    end
  end
end
