class AccountingPlan {
  constructor(){
    this.applicationJS       = new ApplicationJS;
    this.organization_id     = $('input:hidden[name="organization_id"]').val();
    this.edit_provider_modal = $('#edit-provider-customer.modal');
    this.customer_id         = $('input:hidden[name="customer_id"]').val();
  }

  set_auto_update(){
    let self = this;
    $('#auto-update-accounting-plan').unbind('click').bind('click', function(e) {
      e.stopPropagation();

      let current_element = $(this);

      let element         = current_element.attr('info').split('-');
      let organization_id = element[0];
      let customer_id     = element[1];
      let software        = element[2];

      var promise = new Promise(function(resolve, reject) {
       window.setTimeout(function() {
         resolve(self.get_data(current_element, software));
       });
      }).then(function(data) {
        const params =  {
                    'url': '/organizations/' + organization_id + '/customers/' + customer_id + '/accounting_plan/auto_update',
                    'type': 'POST',
                    'data': data,
                    'dataType': 'json',
                    'contentType': 'application/json'
                  };

        self.applicationJS.parseAjaxResponse(params).then((result)=>{ self.applicationJS.noticeFlashMessageFrom(null, result.message); });
     });
    });
  }

  get_data(current_element, software){
    let auto_updating_accounting_plan = 0;
    let software_table  = 'ibiza';

    if (current_element.val() === 'true'){
      auto_updating_accounting_plan = 1
    }
    if (software === 'My Unisoft'){
      software_table = 'my_unisoft'
    }

    return JSON.stringify({
      auto_updating_accounting_plan: auto_updating_accounting_plan,
      software: software,
      software_table: software_table
    });
  }


  edit_provider_customer(){
    let self = this;
    $('.sub_menu .edit').unbind('click').bind('click', function(e) {
      e.stopPropagation();
      e.preventDefault();

      if ($(this).hasClass('provider')) { self.get_edit_view('.customer-form'); }
      else if ($(this).hasClass('customer')) { self.get_edit_view('.provider-form'); }

      self.edit_provider_modal.modal('show');
      ApplicationJS.set_checkbox_radio();
    })
  }

  main() {
    if ($('#accounting-plan #auto-update-accounting-plan').length > 0) {
      this.set_auto_update();
    }

    this.edit_provider_customer();
    this.handle_edit_delete_sub_menu();
    ApplicationJS.set_checkbox_radio();
    ApplicationJS.hide_submenu();
  }


  get_edit_view(target){
    let self = this;

    self.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + self.organization_id + '/customers/' + self.customer_id + '/accounting_plan/edit' }).then((element)=>{
      self.edit_provider_modal.find('.modal-body').html($(element).find('#accounting_plan').html());
      self.edit_provider_modal.find(target).remove();
      if (target === '.provider-form') { self.edit_provider_modal.find('.modal-title').text('Éditer un client'); }
      ApplicationJS.set_checkbox_radio();
    });
  }


  handle_edit_delete_sub_menu(){
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
  let accounting_plan = new AccountingPlan();
  accounting_plan.main();
});