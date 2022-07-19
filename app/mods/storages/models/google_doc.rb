# -*- encoding : UTF-8 -*-
class StoragesMod::GoogleDoc < ApplicationRecord
  self.table_name = 'google_docs'

  belongs_to :external_file_storage

  attr_encrypted :refresh_token,           random_iv: true
  attr_encrypted :access_token,            random_iv: true
  attr_encrypted :access_token_expires_at, random_iv: true, type: :datetime

  def is_configured?
    is_configured
  end

  def reset
    update(refresh_token: '', access_token: '', access_token_expires_at: nil, is_configured: false)
  end

  def user
    external_file_storage.user
  end
end
