# -*- encoding : UTF-8 -*-
class User::Collaborator::CloseAccount
  def initialize(collaborator)
    @collaborator = collaborator
  end


  def execute
    @collaborator.subscription.try(:destroy)

    @collaborator.external_file_storage.try(:destroy)
  end
end
