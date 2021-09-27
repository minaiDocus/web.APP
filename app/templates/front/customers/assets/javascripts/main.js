//= require './events'

//**** File Sending kits JS *******/
//=require '../../../file_sending_kits/assets/javascripts/events'

//**** orders JS *******/
//=require '../../../orders/assets/javascripts/events'
//=require '../../../orders/assets/javascripts/order'

//**** journals JS *******/
//=require '../../../journals/assets/javascripts/journal'

class Customer{

  constructor(){
    this.applicationJS         = new ApplicationJS;
    this.create_customer_modal = $('#create-customer.modal');
    this.filter_customer_modal = $('#customers-filter.modal');
    this.new_edit_order_modal = $('#new_edit_order.modal');
    this.select_multiple       = $('#select_for_orders.modal');
    this.account_close_confirm_modal = $('#account_close_confirm.modal');
    this.file_sending_kits_edit = $('#file_sending_kits_edit.modal');
    this.account_book_type_view = $('#account_book_type_modal.modal');
    this.organization_id       = $('input:hidden[name="organization_id"]').val();
    this.action_locker = false;
  }

  main(){
    this.add_customer();
    this.edit_subscription_package();
    this.load_settings_options_view();    
    this.filter_customer();

    this.get_customer_edit_view();

    if ($('#customer.edit.ibiza').length > 0 ) {
      this.get_ibiza_customers_list($('#ibiza-customers-list'));
    }

    this.show_ibiza_customer();

    if ($('#personalize_subscription_package_form').length > 0 ) {
      this.check_input_number();
      this.show_subscription_option();

      this.update_price();
    }

    if ($('#journals select#copy-journals-into-customer').length > 0) { searchable_option_copy_journals_list(); }

    ApplicationJS.set_checkbox_radio(this);
  }


  check_input_number(){
    let self = this;
    let special_input = $('.subscription_number_of_journals input[type="number"].special_input');
    let current_value = special_input.val();

    special_input.focus();

    special_input.unbind('click keyup keydown change').bind('click keyup keydown change', function(e) {
      e.stopPropagation();

      current_value += $(this).val();

      self.update_price();
    });

    special_input.unbind('keypress').bind('keypress', function(e) { 
      e.preventDefault();
      e.stopPropagation();
    });

    special_input.val(current_value);
    special_input.change();
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


    ApplicationJS.set_checkbox_radio(this);
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
      this.applicationJS.sendRequest({ 'url': '/organizations/' + this.organization_id + '/customers/' + $('input:hidden[name="customer_id"]').val() + '/edit' }).then((element)=>{
        $('#customer-content .tab-content .tab-pane#information').html($(element).find('.customer-form-content').html());
        $('#customer-content #customer-form-data .subscription-base-form').parent().remove();
        $('#customer-content #customer-form-data .accounting-plan-base-form').parent().remove();

        $('select#select-group-list').removeClass('form-control');
        $('select#select-group-list').asMultiSelect({
          'noneText': 'Selectionner un/des groupe(s)',
          'allText': 'Tous séléctionnés'
        });

        ApplicationJS.set_checkbox_radio(this);

        this.show_ibiza_customer();
      });
    }
  }

  get_subscription_edit_view(customer_id){
    this.applicationJS.sendRequest({ 'url': '/organizations/' + this.organization_id + '/customers/' + customer_id + '/subscription/edit' })
    .then((element)=>{
      $('#customer-content .tab-content .tab-pane#subscription').html($(element).find('#subscriptions.edit').html());
      this.main();
      bind_customer_events();
    });
  }

  edit_subscription_package(){
    let self = this;
    let customer_id = $('input:hidden[name="customer_id"]').val();

    $('#customer-content #subscription-tab').unbind('click').bind('click',function(e) {
      e.stopPropagation();
      
      self.get_subscription_edit_view(customer_id);
    });
  }

  load_settings_options_view(){
    let self = this;
    let customer_id = $('input:hidden[name="customer_id"]').val();
    $('#customer-content #compta-tab').unbind('click').bind('click',function(e) {
      e.preventDefault();
      
      self.applicationJS.sendRequest({ 'url': '/organizations/' + self.organization_id + '/customers/' + customer_id + '/edit_setting_options' }).then((element)=>{
        $('#customer-content .tab-content .tab-pane#compta').html($(element).find('#customer.edit').html());

        ApplicationJS.set_checkbox_radio(self);
      });
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


  get_ibiza_customers_list(element) {
    let params =  {
                    'url': element.data('users-list-url'),
                    'type': 'GET',
                    'dataType': 'json'
                  }

    this.applicationJS.sendRequest(params).then((result)=>{
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
        // this.applicationJS.noticeErrorMessageFrom(null, message);
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

      ApplicationJS.set_checkbox_radio(self);

      if ($('#personalize_subscription_package_form').length > 0 ) {
        self.update_price();
        self.check_input_number();
        self.show_subscription_option();
        ApplicationJS.set_checkbox_radio(self);
      }
    });
  }

  get_customer_first_step_form(){
    this.applicationJS.sendRequest({ 'url': '/organizations/' + this.organization_id + '/customers/new' }).then((element)=>{
      this.create_customer_modal.find('.modal-body').html($(element).find('.customer-form-content').html());
      this.create_customer_modal.find('.normal-form-action').remove();
      
      $('select#select-group-list').removeClass('form-control');
      $('select#select-group-list').asMultiSelect({
        'noneText': 'Selectionner un/des groupe(s)',
        'allText': 'Tous séléctionnés'
      });
      
      this.create_customer_modal.modal('show');
      this.set_custom_add_class('.next', 'do-next');
      this.create_customer_modal.find('.previous').attr('disabled','disabled');
      this.show_next();
      this.show_previous();
      this.do_submit_customer();

      bind_customer_events();
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

    this.applicationJS.sendRequest(params).then((result)=>{
      his.applicationJS.noticeSuccessMessageFrom(null, 'Ajout avec succès');

      this.create_customer_modal.find('.modal-body').html($(result).find('#journals').html());
      this.create_customer_modal.find('.modal-title').text('Paramètrage: journaux comptables');
      this.create_customer_modal.find('.footer_copy_journals').remove();
      this.create_customer_modal.find('.modal-footer .next').addClass('copy_account_book_type_btn').attr('disabled', 'disabled');
      this.create_customer_modal.modal('show');

      searchable_option_copy_journals_list();


      /* ******* NEED TO VERIFY CAROUSEL SLIDE FORM WHEN CHOOSE TO USE IT ***** */

      let journal = new Journal();
      journal.main();

      $('#journal .edit_journal_analytics').unbind('click').bind('click', function(e){
        let journal_id = $(this).data('journal-id');
        let customer_id = $(this).data('customer-id');
        let code = $(this).data('code');
        journal.edit_analytics(journal_id, customer_id, code);
      });

      AppListenTo('compta_analytics.validate_analysis', (e)=>{ journal.update_analytics(e.detail.data) });

      /* ******* NEED TO VERIFY CAROUSEL SLIDE FORM WHEN CHOOSE TO USE IT ***** */

      this.create_customer_modal.modal('hide');

      bind_customer_events();
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

      /* ******* REMOVE IT WHEN CHOOSE create METHOD ***** */

      self.create_customer_modal.find('.next').removeAttr('data-bs-slide');

     /* ******* REMOVE IT WHEN CHOOSE create METHOD ***** */

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

      /* ******* REMOVE IT WHEN CHOOSE create METHOD ***** */

      /*self.set_custom_remove_class('.previous', 'active');
      self.set_custom_remove_class('.next', 'do-submit');
      self.active_deactive_previous();
      self.create();*/

      /* ******* REMOVE IT WHEN CHOOSE create METHOD ***** */

      $('form#customer-form-data').submit();
    });
  }


  filter_customer(){
    let self = this;
    $('.customer-filter').unbind('click').bind('click',function(e) {
      e.stopPropagation();

      $('#group-filter').multiSelect({
        'noneText': 'Selectionner un/des groupes',
        'allText': 'Tous séléctionnés'
      });

      $('#customers-filter').modal('show');

      ApplicationJS.set_checkbox_radio();
    });
  }


  close_or_reopen_confirm_view(url, target_action){
    this.applicationJS.sendRequest({ 'url': url }).then((elements)=>{
      this.account_close_confirm_modal.find('.close_reopen_confirm_content').html($(elements).find('.close_or_reopen').html());

      if (target_action === 'close') {
        this.account_close_confirm_modal.find('.modal-title').text('Clôturer le dossier');
      }

      else if (target_action === 'reopen') {
        const text = $(elements).find('.close_or_reopen').attr('text');
        this.account_close_confirm_modal.find('.modal-title').text(text);
        this.account_close_confirm_modal.find('.close_or_reopen_confirm').attr('link', $(elements).find('.close_or_reopen').attr('link'));
        this.account_close_confirm_modal.find('.close_or_reopen_confirm').text(text);
        this.account_close_confirm_modal.find('.close_or_reopen_confirm').removeClass('close');
      }

      this.account_close_confirm_modal.modal('show');

      bind_customer_events();
    });
  }

  close_or_reopen_confirm(url, data={}){
    let params = {};

    if (url.indexOf("reopen_account") >= 0) {
      /*params = {'url': url, 'type': 'PATCH', 'dataType': 'html'};*/
      params = {'url': url, 'type': 'POST', data: { _method: 'PATCH' }, 'dataType': 'html'};
    }
    else if (url.indexOf("close_account") >= 0) {
      params = {'url': url, 'data': data, 'type': 'POST', 'dataType': 'html'};
    }

    this.applicationJS.sendRequest(params).then((response)=>{
      $('#customer-content').html($(response).find('#customer-content').html());
      this.account_close_confirm_modal.modal('hide');

      this.get_customer_edit_view();
      bind_customer_events();
      ApplicationJS.set_checkbox_radio();
    }).catch((response)=>{
      
    });
  }

  validate_first_slide_form(){
    let required_fields_count = 0;

    $('input.required_field').each(function() {
      if ($(this).val() !== '') {
        required_fields_count += 1;
      }
    });

    if (required_fields_count === 3) { this.create_customer_modal.find('.carousel-item-action .next').removeAttr('disabled'); }
  }


   load_data(search_pattern=false, type='customers', page=1, per_page=0){
    if(this.action_locker) { return false; }

    this.action_locker = true;
    let params = [];

    let search_text = '';

    if (search_pattern) {
      search_text = $(`.search-content input[name='user_contains[text]']#search_input`).val();
      if(search_text && search_text != ''){ params.push(`user_contains[text]=${encodeURIComponent(search_text)}`); }
    }

    params.push(`page=${page}`);

    if (per_page > 0) { params.push(`per_page=${ per_page }`); }

    let ajax_params =   {
                          'url': `/organizations/${this.organization_id}/${type}?${params.join('&')}`,
                          'dataType': 'html',
                          'target': ''
                        };

    this.applicationJS.sendRequest(ajax_params)
    .then((response)=>{
      $('.list-customers').html($(response).find('.list-customers').html());

      $(`.search-content input[name='user_contains[text]']#search_input`).val(search_text);

      this.action_locker = false;
      bind_customer_events();
      ApplicationJS.set_checkbox_radio();
    })
    .catch(()=>{ this.action_locker = false; });
  }


  update_subscription(url, data){
    if(this.action_locker) { return false; }

    this.action_locker = true;

    this.applicationJS.sendRequest({
      'url': url,
      'data': data,
      'type': 'POST',
      'dataType': 'html',
    }).then((response)=>{
      $('#customer-content .tab-content .tab-pane#subscription').html($(response).find('#subscriptions.edit').html());
      /*url = url.replace('/subscription', '?tab=subscription');
      window.location.replace(url);*/
      
      this.rebind_customer_all_events();
    }).catch((error)=>{
      
    });
  }

  new_edit_order_view(url){
    this.applicationJS.sendRequest({ 'url': url }).then((element)=>{
      this.new_edit_order_modal.find('.modal-body').html('');
      this.new_edit_order_modal.find('.modal-body').html($(element).find('#order .order-form-content').html());
      this.new_edit_order_modal.find('.modal-title').text($(element).find('#order .modal-title-text').text());
      this.new_edit_order_modal.find('.footer-form').remove();

      if (url.indexOf("new") >= 0) {
        $('.valid_new_edit_order.as_idocus_ajax').text('Commander');
      }
      else if (url.indexOf("edit") >= 0) {
        $('.valid_new_edit_order.as_idocus_ajax').text('Valider les modifications');
      }

      this.new_edit_order_modal.modal('show');
     
      bind_all_events_order();
      this.rebind_customer_all_events();
    }).catch((error)=> { 
      console.error(error);
    });
  }

  rebind_customer_all_events(){
    this.main();
    bind_customer_events();
    ApplicationJS.set_checkbox_radio();
  }

  load_csv_descriptor(user_id, organization_id){
    let ajax_params = {
                        url: `/organizations/${organization_id}/csv_descriptor/${user_id}/format_setting`,
                        type: 'GET',
                        dataType: 'HTML',
                        target: '#csv_descriptors.edit',
                        target_dest: '#edit_csv_descriptor_format'
                      };

    this.applicationJS.sendRequest(ajax_params).then((e)=>{ $('.modal#csv_descriptor_modal').modal('show'); });
  }

  select_for_orders(url){
    this.applicationJS.sendRequest({ 'url': url }).catch((error)=> {
      console.log(error)
    }).then((element)=>{
      this.select_multiple.find('.modal-body').html($(element).find('.file_sending_kits_select').html());
      this.select_multiple.find('.form-footer-content').remove();

      file_sending_kits_main_events();
      this.rebind_customer_all_events();
    });
  }

  handle_select_for_orders_result(response){
    this.select_multiple.find('.form-footer-content').remove();
    file_sending_kits_main_events();
    this.rebind_customer_all_events();
  }

  edit_file_sending_kits_view(url){
    this.applicationJS.sendRequest({ 'url': url }).then((element)=>{
      this.file_sending_kits_edit.find('.modal-body').html($(element).find('.file_sending_kits_edit').html());
      this.select_multiple.modal('hide');
      this.file_sending_kits_edit.modal('show');

      this.rebind_customer_all_events();
    }).catch((error)=> { 
      console.error(error);
    });
  }

  new_account_book_type_view(url){
    this.applicationJS.sendRequest({ 'url': url }).then((element)=>{
      this.account_book_type_view.find('.modal-body').html($(element).html());
      this.account_book_type_view.modal('show');

      this.rebind_customer_all_events();
    }).catch((error)=> { 
      console.error(error);
    });
  }
}


jQuery(function () {
  var customer = new Customer();

  let load_only_once = false;
  if ($('#subscription.tab-pane.active').length > 0 && !load_only_once) {
    load_only_once = true;
    customer.get_subscription_edit_view($('input:hidden[name="customer_id"]').val());
  }

  AppListenTo('validate_first_slide_form', (e)=>{ customer.validate_first_slide_form(); });

  AppListenTo('search_text', (e)=>{ customer.load_data(true); });

  /*AppListenTo('update_subscription', (e)=>{ customer.update_subscription(e.detail.url, e.detail.data); });*/

  AppListenTo('close_or_reopen_confirm_view', (e)=>{ customer.close_or_reopen_confirm_view(e.detail.url, e.detail.target); });
  AppListenTo('close_or_reopen_confirm', (e)=>{ customer.close_or_reopen_confirm(e.detail.url, e.detail.data); });

  AppListenTo('new_edit_order_view', (e)=>{ customer.new_edit_order_view(e.detail.url); });
  AppListenTo('change_new_edit_order_url', (e)=>{ e.set_key('url', $('form#new_edit_order_customer').attr('action')); });
  AppListenTo('rebind_customer_event_listener', (e)=>{ customer.rebind_customer_all_events(); });

  AppListenTo('select_for_orders', (e)=>{ customer.select_for_orders(e.detail.url); });
  AppListenTo('handle_select_for_orders_result', (e)=>{ customer.handle_select_for_orders_result(e.detail.response); });

  let order = new Order();

  if ($('#order form, form#new_edit_order_customer').length > 0){
    order.update_casing_counts();
    order.update_price();
  }

  AppListenTo('update_casing_counts', (e)=>{ order.update_casing_counts(); });
  AppListenTo('update_price', (e)=>{ order.update_price(); });
  AppListenTo('check_casing_size_and_count', (e)=>{ order.check_casing_size_and_count(); });

  AppListenTo('edit_file_sending_kits_view', (e)=>{ customer.edit_file_sending_kits_view(e.detail.url); });

  /*AppListenTo('new_account_book_type_view', (e)=>{ customer.new_account_book_type_view(e.detail.url); });*/

  let journal = new Journal();
  journal.main();

  $('#journal .edit_journal_analytics').unbind('click').bind('click', function(e){ 
    let journal_id = $(this).data('journal-id');
    let customer_id = $(this).data('customer-id');
    let code = $(this).data('code');
    journal.edit_analytics(journal_id, customer_id, code);
  });

  AppListenTo('compta_analytics.validate_analysis', (e)=>{ journal.update_analytics(e.detail.data) });
  
  AppListenTo('csv_descriptor_edit_customer_format', (e)=>{ customer.load_csv_descriptor(e.detail.id, e.detail.organization_id) });
 
  customer.main();
});