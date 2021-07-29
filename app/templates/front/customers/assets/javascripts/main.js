class Customer{

  constructor(){
    this.applicationJS = new ApplicationJS;
    this.create_customer_modal = $('#create-customer.modal');
    this.filter_customer_modal = $('#customers-filter');
    this.organization_id = $('input:hidden[name="organization_id"]').val();
  }


  set_sub_menu_toggle(){
    $('.action.sub_edit_delete, .edit_group').unbind('click');
    $('.action.sub_edit_delete, .edit_group').bind('click',function(e) {
      e.stopPropagation();

      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).parent().find('.sub_menu').removeClass('hide');
    });
  }


  main(){
    this.set_sub_menu_toggle();

    this.add_customer();
    this.edit_customer();
    this.get_subscription_edit_view();
    this.get_accounting_plan_view();
    this.filter_customer();
    this.check_software();

    this.get_customer_edit_view();

    if ($('#customer.edit.ibiza').length > 0 ) {
      this.get_ibiza_customers_list($('#ibiza-customers-list'));
    }

    this.show_ibiza_customer();

    this.hide_sub_menu();
  }



  get_customer_edit_view(){
    if ($('#customer-content').length > 0) {
      this.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + this.organization_id + '/customers/' + $('input:hidden[name="customer_id"]').val() + '/edit' }).then((element)=>{
        $('#customer-content .tab-content .tab-pane#information').html($(element).find('.customer-form-content').html());
        $('#customer-content #customer-form-data .carousel-item-action').remove();
        $('#customer-content #customer-form-data .normal-form-action').removeClass('hide');
        $('#customer-content #customer-form-data .subscription-base-form').parent().remove();
        $('#customer-content #customer-form-data .accounting-plan-base-form').parent().remove();

        $('select#select-group-list').removeClass('form-control');
        $('select#select-group-list').searchableOptionList({
          'noneText': 'Selectionner un/des groupe(s)',
          'allText': 'Tous séléctionnés'
        });

        this.show_ibiza_customer();
      });
    }
  }

  get_subscription_edit_view(){
    let self = this;
    let customer_id = $('input:hidden[name="customer_id"]').val();
    $('.tab-pane#subscription .subscription-edit').unbind('click').bind('click',function(e) {
      e.preventDefault();
      
      self.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + self.organization_id + '/customers/' + customer_id + '/subscription/edit' }).then((element)=>{
        $('#customer-content .tab-content .tab-pane#subscription').html($(element).find('#subscriptions.edit').html());
      });
    });
  }

  get_accounting_plan_view(){
    let self = this;
    let customer_id = $('input:hidden[name="customer_id"]').val();
    $('#accounting-plan-tab').unbind('click').bind('click',function(e) {
      e.preventDefault();
      
      self.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + self.organization_id + '/customers/' + customer_id + '/accounting_plan' }).then((element)=>{
        $('#customer-content .tab-content .tab-pane#accounting-plan').html($(element).find('#accounting_plan').html());
        self.get_vat_accounts_view(customer_id);

        self.set_sub_menu_toggle();
        self.set_ckeck_box_state();

        self.get_vat_accounts_view(customer_id);
      });
    });
  }


  get_external_file_storages(){
    
  }


  get_vat_accounts_view(customer_id){
    this.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + this.organization_id + '/customers/' + customer_id + '/accounting_plan/vat_accounts' }).then((result)=>{
      $('#vat_accounts').html($(result).find('#vat_accounts').html());
    });
  }

  add_customer(){
    var self = this;
    $('.new-customer').unbind('click').bind('click',function(e) {
      e.stopPropagation();
      self.get_customer_first_step_form();

      self.set_pre_assignment_view();
    });
  }


  set_ckeck_box_state(){
    $('.input-toggle').change(function() {
      if ($(this).is(':checked')){
        $(this).parent().find('label').text('Oui');
        $(this).attr('value', true);
        $(this).attr('checked', true);
      }
      else {
        $(this).parent().find('label').text('Non');
        $(this).attr('value', false);
        $(this).attr('checked', false);
        // $(this).removeAttr("checked");
      }        
    });
  }


  get_ibiza_customers_list(element) {
    let params =  {
                    'url': element.data('users-list-url'),
                    'type': 'GET',
                    'dataType': 'json'
                  }

    this.applicationJS.parseAjaxResponse(params).then((result)=>{
      if(result['message'] === undefined || result['message'] === null)
      {
        let original_value = element.data('original-value') || '';
        for (let iterator = 0; iterator < result.length; iterator++) {
          let _element = result[iterator];
          let option_html = '';
          if (original_value.length > 0 && original_value === _element['id']) {
            option_html = '<option value="' + _element['id'] + '" selected="selected">' + _element['name'] + '</option>';
          } else {
            option_html = '<option value="' + _element['id'] + '">' + _element['name'] + '</option>';
          }
          element.append(option_html);
        }
        element.show();
        element.chosen({
          search_contains: true,
          no_results_text: 'Aucun résultat correspondant à'
        });
        $('.removable-feedback').remove();
        if ($('input[type=submit]').length > 0) {
          $('input[type=submit]').removeAttr('disabled');
        }
      }
      else
      {
        // TO PERSONALIZE THIS NOTIFICATION

        // let message = result['message'] + " ==> iBiza n'est pas configuré correctement"
        // this.applicationJS.noticeInternalErrorFrom(null, message);
      }


      if ($('#customer-form-data input[type="checkbox"].check-ibiza').is(':checked')) {
        $('#customer-form-data .softwares-section').css('display', 'block');
      } else {
        $('#customer-form-data .softwares-section').css('display', 'none');
      }
    });
  }


  show_ibiza_customer(){
    $('#customer-form-data input[type="checkbox"].check-ibiza').change(function() {
      if ($(this).is(':checked')) {
        $('#customer-form-data .softwares-section').css('display', 'block');
      } else {
        $('#customer-form-data .softwares-section').css('display', 'none');
      }
    });

    if ($('#customer-form-data .softwares-section .ibiza-customers-list').length > 0) {
      this.get_ibiza_customers_list($('#customer-form-data .softwares-section .ibiza-customers-list'));
    }
  }


  check_software(){
    $('.check-software').change(function() {
      if ($(this).is(':checked')){
        $(this).parent().find('label').text('Oui');
        $(this).attr('value', 1);
        $(this).attr('checked', true);
      }
      else {
        $(this).parent().find('label').text('Non');
        $(this).attr('value', 0);
        $(this).attr('checked', false);
      }        
    });
  }


  set_pre_assignment_view(){
    var self = this;
    $(document).on('show.bs.modal', '#create-customer.modal', function () {
      self.show_ibiza_customer();
      self.show_next();
      self.show_previous();
      self.do_submit_customer();

      self.set_ckeck_box_state();
    });
  }

  get_customer_first_step_form(){
    this.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + this.organization_id + '/customers/form_with_first_step' }).then((element)=>{
      this.create_customer_modal.find('.modal-content').html($(element).find('.modal-content').html());
      
      $('select#select-group-list').removeClass('form-control');
      $('select#select-group-list').searchableOptionList({
        'noneText': 'Selectionner un/des groupe(s)',
        'allText': 'Tous séléctionnés'
      });
      
      this.create_customer_modal.modal('show');
      this.set_custom_add_class('.next', 'do-next');
      this.create_customer_modal.find('.previous').attr('disabled','disabled');
      this.show_next();
      this.show_previous();
      this.do_submit_customer();
    });
  }


  set_custom_add_class(target, new_class){
    this.create_customer_modal.find(target).addClass(new_class);
  }

  set_custom_remove_class(target, new_class){
    this.create_customer_modal.find(target).removeClass(new_class);
  }


  create(){
    let datas = this.create_customer_modal.find('#customer-form-data').serialize();
    let url = this.create_customer_modal.find('#customer-form-data').attr('action');

    let params =  {
                    'url': url,
                    'type': 'POST',
                    'data': datas,
                    'dataType': 'html'
                  }

    this.applicationJS.parseAjaxResponse(params).then((result)=>{
      this.applicationJS.noticeFlashMessageFrom(null, 'Ajout avec succès');
      // if(result.error.toString() == '')
      // {
      //   this.applicationJS.noticeFlashMessageFrom(null, 'Ajout avec succès');
      // }
      // else
      // {
      //   this.applicationJS.noticeInternalErrorFrom(null, result.error);
      // }


      this.create_customer_modal.find('.accounting-plan-base-form').html($(result).find('.accounting-plan-base-form').html());
      this.set_custom_remove_class('.next', 'do-submit');
      this.set_custom_add_class('.next', 'load-journal-form');
      this.create_customer_modal.find('.modal-footer .previous').attr('disabled','disabled');
      $('#create-customer.modal.show .modal-title').text('Paramètrage: journaux comptables');
    });
  }



  active_deactive_previous() {
    if (this.create_customer_modal.find('.next.do-submit').length > 0) {
      this.create_customer_modal.find('.previous').removeAttr('disabled');
    }
    else {
      this.create_customer_modal.find('.previous').attr('disabled','disabled');
    }
  }



  show_next(){
    let self = this;
    $('.do-next').unbind('click').bind('click',function(e) {
      e.stopPropagation();

      console.log('LOAD');

      self.set_custom_remove_class('.next', 'do-next');
      self.set_custom_add_class('.next', 'do-submit');
      self.create_customer_modal.find('.modal-title').text('Sélectionner un abonnement');
      self.create_customer_modal.find('.next').text('Valider');
      self.set_custom_add_class('.previous', 'active');
      self.active_deactive_previous();

      self.show_previous();

      self.do_submit_customer();
    });
  }


  show_previous(){
    let self = this;
    $('.previous.active').unbind('click').bind('click', function(e){ 
      e.stopPropagation();

      console.log('DEACTIVE');

      self.set_custom_remove_class('.next', 'do-submit');
      self.set_custom_add_class('.next', 'do-next');
      self.create_customer_modal.find('.modal-title').text('Créer un nouveau client');
      self.set_custom_remove_class('.previous', 'active');
      self.show_next();
      self.active_deactive_previous();
    });
  }

  do_submit_customer(){
    let self = this;
    $('.do-submit').unbind('click').bind('click',function(e) {
      e.stopPropagation();

      self.set_custom_remove_class('.previous', 'active');
      self.set_custom_remove_class('.next', 'do-submit');
      self.active_deactive_previous();
      // self.create();
    });
  }

  hide_sub_menu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.sub_menu').addClass('hide');
      }
    });
  }


  edit_customer(){
    $('.sub_menu .edit-customer').unbind('click').bind('click',function(e) {
      e.stopPropagation();

      $('.list-customers').addClass('hide')
      $('.customer-parameters').removeClass('hide')
    });
  }


  filter_customer(){
    $('.customer-filter').unbind('click');
    $(".customer-filter").bind('click',function(e) {
      e.stopPropagation();

      $('#group-filter').multiSelect({
        'noneText': 'Selectionner un/des groupes',
        'allText': 'Tous séléctionnés'
      });

      $('#collaborator-filter').multiSelect({
        'noneText': 'Selectionner un/des collaborateurs',
        'allText': 'Tous séléctionnés'
      });

      $('#customers-filter').modal('show');
    });
  }
}


jQuery(function () {
  var customer = new Customer();
  customer.main();
});