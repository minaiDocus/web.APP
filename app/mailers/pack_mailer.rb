# -*- encoding : UTF-8 -*-
class PackMailer < BaseMailer
  def new_document_available(user, packs, start_at, end_at)
    @url      = Settings.first.inner_url + '/documents'
    @user     = user
    @packs    = packs
    @start_at = Time.at start_at
    @end_at   = Time.at end_at

    mail(to: user.email, subject: '[iDocus] Mise à jour des documents')
  end
end
