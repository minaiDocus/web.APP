class FavoriteCustomer < ApplicationRecord
  serialize :customer_ids, Array

  belongs_to :user

  def self.get_infos_of(customer_id)
    customer = User.where(id: customer_id).first
    result = OpenStruct.new()

    if customer
      result = OpenStruct.new({ id: customer.id, name: customer.info, note: 'Moyen', state: 'medium', message: '', active: customer.still_active? })

      result.last_pack = customer.packs.order(updated_at: :desc).first

      result.temp_docs_error_size = customer.temp_documents.where(state: 'unreadable').count

      if customer.subscription.periods.last.is_active?(:retriever_option)
        result.retriever_option_active = true
        result.retriever_error_size = customer.retrievers.where(state: 'error').count
      end

      result.duplicated_preseizures_size = Pack::Report::Preseizure.unscoped.where(user_id: customer.id, is_blocked_for_duplication: true).count
    end

    result
  end
end