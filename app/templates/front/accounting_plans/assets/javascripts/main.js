class AccountingPlan {
  constructor(){
    this.applicationJS = new ApplicationJS;
    this.organization_id = $('input:hidden[name="organization_id"]').val();
    this.edit_provider_modal = $('#edit-provider-customer.modal');
    this.customer_id = $('input:hidden[name="customer_id"]').val();
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
    let that = this;
    $('.sub_menu .edit').unbind('click').bind('click', function(e) {
      e.stopPropagation();
      e.preventDefault();

      if ($(this).hasClass('provider')) { that.get_edit_view('.customer-form'); }
      else if ($(this).hasClass('customer')) { that.get_edit_view('.provider-form'); }

      that.edit_provider_modal.modal('show');
      that.set_ckeck_box_state();
    })
  }

  main() {
    if ($('#accounting-plan #auto-update-accounting-plan').length > 0) {
      this.set_auto_update();
    }

    this.edit_provider_customer();
    this.handle_edit_delete_sub_menu();
    this.set_ckeck_box_state();
    this.hide_sub_menu();
  }


  get_edit_view(target){
    let that = this;  

    that.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + that.organization_id + '/customers/' + that.customer_id + '/accounting_plan/edit' }).then((element)=>{
      that.edit_provider_modal.find('.modal-body').html($(element).find('#accounting_plan').html());
      that.edit_provider_modal.find(target).remove();
      if (target === '.provider-form') { that.edit_provider_modal.find('.modal-title').text('Éditer un client'); }
      that.set_ckeck_box_state();
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

  hide_sub_menu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.sub_menu').addClass('hide');
      }
    });
  }

  set_ckeck_box_state(){
    let class_list = [];
    let self = this;

    $('.input-toggle').change(function() {
      class_list = $(this).attr('class').split(/\s+/);

      if ($(this).is(':checked')){
        $(this).attr('checked', true);

        if (class_list.indexOf("ido-custom-checkbox") > -1) { $(this).parents().eq(3).find('label.ido-custom-label').text('Oui'); }
        else { $(this).parent().find('label').text('Oui'); }

        if ((class_list.indexOf("check-software") > -1) || (class_list.indexOf("filter-customer") > -1)) { $(this).attr('value', 1); }
        else { $(this).attr('value', true); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).addClass('active_option'); }

      }
      else {
        $(this).attr('checked', false);

        if (class_list.indexOf("ido-custom-checkbox") > -1) { $(this).parents().eq(3).find('label.ido-custom-label').text('Non'); }
        else { $(this).parent().find('label').text('Non'); }

        if ((class_list.indexOf("check-software") > -1) || (class_list.indexOf("filter-customer") > -1)) { $(this).attr('value', 0); }
        else { $(this).attr('value', false); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).removeClass('active_option'); }
      }

      if(class_list.indexOf("option_checkbox") > -1){
        self.check_input_number();
        self.update_price(); 
      }       
    });


    if ($('.input-toggle:checked').length > 0) {
      const selected = $('.input-toggle:checked');

      $.each(selected, function() {
        class_list = $(this).attr('class').split(/\s+/);
        let element = $(this);

        if (class_list.indexOf("ido-custom-checkbox") > -1) {
          element = $('.ido-custom-checkbox.input-toggle:checked');
          element.parents().eq(3).find('label.ido-custom-label').text('Oui');
        }
        else {
          element.parent().find('label').text('Oui');
        }
      });
    }
  }
}



jQuery(function() {
  let accounting_plan = new AccountingPlan();
  accounting_plan.main();
});