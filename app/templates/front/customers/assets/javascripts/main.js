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
    this.set_ckeck_box_state();

    this.get_customer_edit_view();

    if ($('#customer.edit.ibiza').length > 0 ) {
      this.get_ibiza_customers_list($('#ibiza-customers-list'));
    }

    this.show_ibiza_customer();

    if ($('#personalize_subscription_package_form').length > 0 ) {
      this.check_input_number();
      this.show_subscription_option();

      this.update_price()
    }

    this.hide_sub_menu();
  }


  check_input_number(){
    let self = this;

    $('#personalize_subscription_package_form .subscription_number_of_journals .special_input').focus();

    $('#personalize_subscription_package_form .subscription_number_of_journals .special_input').bind('click', function(e) {
      e.stopPropagation();
      self.update_price();
    })

    $('.subscription_number_of_journals input[type="number"].special_input').unbind('keyup keydown change').bind('keyup keydown change', function(e) {
      e.stopPropagation();
      self.update_price();
    });

    $('#personalize_subscription_package_form .subscription_number_of_journals .special_input').bind('keypress', function(e) { 
      e.preventDefault();
      e.stopPropagation();
    });
  }





  update_price() {
    let prices_list = JSON.parse($('#subscription_packages_price').val());
    let selected_options = [];
    let price = 0;
    let options = [];

    if ($('#subscription_subscription_option_ido_x').is(':checked')) {
      options.push('ido_x');
    }
    if ($('#subscription_subscription_option_ido_nano').is(':checked')) {
      options.push('ido_nano');
    }
    if ($('#subscription_subscription_option_ido_micro').is(':checked')) {
      options.push('ido_micro');
    }
    if ($('#subscription_subscription_option_ido_mini').is(':checked')) {
      options.push('ido_mini', 'signing_piece', 'pre_assignment_option');
    }
    if ($('#subscription_subscription_option_ido_classique').is(':checked')) {
      options.push('ido_classique', 'signing_piece', 'pre_assignment_option');
    }
    if ($('.active_option#subscription_mail_option').is(':checked')) {
      options.push('mail_option');
    }
    if ($('.active_option#subscription_digitize_option').is(':checked') || $('#subscription_subscription_option_digitize_option').is(':checked')) {
      options.push('digitize_option');
    }
    if ($('.active_option#subscription_retriever_option').is(':checked')) {
      if ($('.active_option#subscription_retriever_option').data('retriever-price-option') === 'reduced_retriever') {
        options.push('retriever_option_reduced');
      } else {
        options.push('retriever_option');
      }
    }
    if ($('#subscription_subscription_option_retriever_option').is(':checked')) {
      if ($('#subscription_subscription_option_retriever_option').data('retriever-price-option') === 'reduced_retriever') {
        options.push('retriever_option_reduced');
      } else {
        options.push('retriever_option');
      }
    }
    for (let o in options) {
      if (options[o] === 'pre_assignment_option') {
        if ($('#subscription_is_pre_assignment_active').is(':checked')) {
          selected_options.push('pre_assignment_option');
        }
      } else {
        selected_options.push(options[o]);
      }
    }
    if (options.length > 0) {
      let number_of_journals = parseInt($('input[name="subscription[number_of_journals]"]').val());
      if (number_of_journals > 5) {
        price += number_of_journals - 5;
      }
    }
    for (let so in selected_options) {
      price += prices_list[selected_options[so]];
    }
    
    $('.total_price').html(price + ",00€ HT");
  }


  clone_subscription_option(class_list, email_option, retriever_option, digitization_option){
    if (retriever_option.length > 0 ) {
      retriever_option.html($('.input-retriever-option').html());

      if (retriever_option.closest('.retriever-option').data('active')) {
        retriever_option.find('.option_checkbox').addClass('active_option');
      }
      if (retriever_option.closest('.retriever-option').data('notify')) {
        retriever_option.find('.form-check-inline').addClass('notify-warning');
      }

      retriever_option.find('.option_checkbox').attr({
        'checked': retriever_option.closest('.retriever-option').data('active')
      });
    }
    if (email_option.length > 0) {
      email_option.html($('.input-mail-option').html());

      if (email_option.closest('.mail-option').data('active')) {
        email_option.find('.option_checkbox').addClass('active_option');
      }
      if (email_option.closest('.mail-option').data('notify')) {
        email_option.find('.form-check-inline').addClass('notify-warning');
      }

      email_option.find('.option_checkbox').attr({
        'checked': email_option.closest('.mail-option').data('active')
      });
    }
    if (digitization_option.length > 0 ) {
      digitization_option.html($('.input-digitization-option').html());

      if (digitization_option.closest('.digitization-option').data('active')) {
        digitization_option.find('.option_checkbox').addClass('active_option');
      }
      if (digitization_option.closest('.digitization-option').data('notify')) {
        digitization_option.find('.form-check-inline').addClass('notify-warning');
      }

      digitization_option.find('.option_checkbox').attr({
        'checked': digitization_option.closest('.digitization-option').data('active')
      });
    }

    if (class_list.indexOf("ido_x") > -1) {
      $('input.ido_x_option').removeAttr('disabled');
    }

    if (class_list.indexOf("ido_nano") > -1) {
      email_option.find('.option_checkbox').addClass('ido_nano_option');
      digitization_option.find('.option_checkbox').addClass('ido_nano_option');
    }

    if (class_list.indexOf("ido_micro") > -1) {
      email_option.find('.option_checkbox').addClass('ido_micro_option');
      digitization_option.find('.option_checkbox').addClass('ido_micro_option');
    }

    if (class_list.indexOf("ido_classique") > -1) {
      email_option.find('.option_checkbox').addClass('ido_classique_option');
      retriever_option.find('.option_checkbox').addClass('ido_classique_option');
      digitization_option.find('.option_checkbox').addClass('ido_classique_option');
    }


    this.set_ckeck_box_state();
    this.check_input_number();
    this.update_price();
  }


  show_subscription_option(){
    let self = this;
    let class_list = [];
    let email_option = null;
    let retriever_option = null;
    let digitization_option = null;

    $('#personalize_subscription_package_form .radio-button').unbind('click').bind('click', function(e){
      e.stopPropagation();

      email_option = $(this).parents().eq(4).find('.mail-option');
      retriever_option = $(this).parents().eq(4).find('.retriever-option');
      digitization_option = $(this).parents().eq(4).find('.digitization-option');

      $('#personalize_subscription_package_form .package-options .mail-option').html('');
      $('#personalize_subscription_package_form .package-options .retriever-option').html('');
      $('#personalize_subscription_package_form .package-options .digitization-option').html('');
      $('#personalize_subscription_package_form .package-options .journal-numbers').html('');
      $('#personalize_subscription_package_form .package-options').addClass('hide');

      $(this).parents().eq(4).find('.package-options').removeClass('hide');
      $(this).parents().eq(4).find('.journal-numbers').html($('.input-journal-numbers').html());

      class_list = $(this).attr('class').split(/\s+/);

      self.clone_subscription_option(class_list, email_option, retriever_option, digitization_option)
    });

    if ($('#personalize_subscription_package_form input[type="radio"].radio-button').is(':checked')) {
      let current_active = $('#personalize_subscription_package_form input[type="radio"].radio-button:checked');
      class_list = current_active.attr('class').split(/\s+/);
      current_active.parents().eq(4).find('.package-options').removeClass('hide');

      current_active.parents().eq(4).find('.journal-numbers').html($('.input-journal-numbers').html());
      
      email_option = current_active.parents().eq(4).find('.package-options .mail-option');
      retriever_option = current_active.parents().eq(4).find('.package-options .retriever-option');
      digitization_option = current_active.parents().eq(4).find('.package-options .digitization-option');
      self.clone_subscription_option(class_list, email_option, retriever_option, digitization_option)
    }
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
    $('#customer-content #subscription-tab').unbind('click').bind('click',function(e) {
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
    let class_list = [];
    let self = this;

    $('.input-toggle').change(function() {
      class_list = $(this).attr('class').split(/\s+/);

      if ($(this).is(':checked')){
        $(this).attr('checked', true);

        if (class_list.indexOf("ido-custom-checkbox") > -1) { $(this).parents().eq(3).find('label.ido-custom-label').text('Oui'); }
        else { $(this).parent().find('label').text('Oui'); }

        if (class_list.indexOf("check-software") > -1) { $(this).attr('value', 1); }
        else { $(this).attr('value', true); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).addClass('active_option'); }

      }
      else {
        $(this).attr('checked', false);

        if (class_list.indexOf("ido-custom-checkbox") > -1) { $(this).parents().eq(3).find('label.ido-custom-label').text('Non'); }
        else { $(this).parent().find('label').text('Non'); }

        if (class_list.indexOf("check-software") > -1) { $(this).attr('value', 0); }
        else { $(this).attr('value', false); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).removeClass('active_option'); }
      }

      self.check_input_number();
      self.update_price();        
    });


    if ($('.input-toggle').is(':checked')) {
      let selected = $('.input-toggle:checked');

      class_list = selected.attr('class').split(/\s+/);

      if (class_list.indexOf("ido-custom-checkbox") > -1) {
        selected = $('.ido-custom-checkbox.input-toggle:checked');
        selected.parents().eq(3).find('label.ido-custom-label').text('Oui');
      }
      else { selected.parent().find('label').text('Oui'); }
    }
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



  set_pre_assignment_view(){
    var self = this;
    $(document).on('show.bs.modal', '#create-customer.modal', function () {
      self.show_ibiza_customer();
      self.show_next();
      self.show_previous();
      self.do_submit_customer();

      self.set_ckeck_box_state();

      if ($('#personalize_subscription_package_form').length > 0 ) {
        self.update_price();
        self.check_input_number();
        self.show_subscription_option();
        self.set_ckeck_box_state();
      }
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


  select_journals(){
    this.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + this.organization_id + '/customers/' + $('input:hidden[name="customer_id"]').val() + '/journals/select' }).then((result)=>{
      this.create_customer_modal.find('.accounting-plan-base-form .copy-select-journals').html($(result).find('#journals.select').html());
      this.set_custom_remove_class('.next', 'do-submit');
      this.set_custom_add_class('.next', 'load-journal-form');
      this.create_customer_modal.find('.modal-footer .previous').attr('disabled','disabled');
      $('#create-customer.modal.show .modal-title').text('Paramètrage: journaux comptables');
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

      this.create_customer_modal.find('.modal-content').html($(result).find('#book_type .modal-content').html());
      $('select#copy-journals-into-customer').searchableOptionList({
        'noneText': 'Selectionner un/des journaux',
        'allText': 'Tous séléctionnés'
      });
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
      self.create();
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