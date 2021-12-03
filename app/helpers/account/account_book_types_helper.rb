module Account::AccountBookTypesHelper
  def account_book_type_entry_type_for_select(organization, customer)
    options = if organization.specific_mission
      [
        [t('simple_form.labels.account_book_type.entry_type_5'),5]
      ]
    elsif !customer || (customer && customer.options.is_preassignment_authorized)
      [
        [t('simple_form.labels.account_book_type.entry_type_0'),0],
        [t('simple_form.labels.account_book_type.entry_type_2'),2],
        [t('simple_form.labels.account_book_type.entry_type_3'),3]
      ]
    else
      [
        [t('simple_form.labels.account_book_type.entry_type_0'),0]
      ]
    end

    if customer && !organization.specific_mission
      if customer.options.is_retriever_authorized
        options << [t('simple_form.labels.account_book_type.entry_type_4'),4]
      end

      if customer.options.is_preassignment_authorized
        options << [t('simple_form.labels.account_book_type.entry_type_1'),1]
      end
    end

    options
  end
end