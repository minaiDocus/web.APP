class VatAccount {
  constructor(){
    this.applicationJS         = new ApplicationJS;
    this.organization_id       = $('input:hidden[name="organization_id"]').val();
    this.add_vat_account_modal = $('#add-vat-account.modal');
    this.customer_id           = $('input:hidden[name="customer_id"]').val();
  }


  add_vat_account(){
    let self = this;
    $('#add-new-vat-account').unbind('click').bind('click', function(e) {
      e.stopPropagation();
      e.preventDefault();

      self.get_edit_view('.customer-form');

      self.add_vat_account_modal.modal('show');
      // ApplicationJS.set_checkbox_radio();
    })
  }

  main() {
    if ($('#vat_accounts #add-new-vat-account').length > 0) {
      this.add_vat_account();
    }

    this.handle_edit_delete_submenu();
    ApplicationJS.set_checkbox_radio();
    ApplicationJS.hide_submenu();
  }


  get_edit_view(target='edit'){
    let self = this;

    self.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + self.organization_id + '/customers/' + self.customer_id + '/accounting_plan/vat_accounts/edit_multiple' }).then((element)=>{
      self.add_vat_account_modal.find('.modal-body').html($(element).find('#accounting_plan.edit').html());
      if (target === 'edit') { self.add_vat_account_modal.find('.modal-title').text('Éditer un compte TVA'); }
      ApplicationJS.set_checkbox_radio();
    });
  }


  handle_edit_delete_submenu(){
    $('.action.edit-delete-menu').unbind('click').bind('click',function(e) {
      e.stopPropagation();

      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).parent().find('.sub_menu').removeClass('hide');
    });
  }
}



jQuery(function() {
  let accounting_plan = new VatAccount();
  accounting_plan.main();
});