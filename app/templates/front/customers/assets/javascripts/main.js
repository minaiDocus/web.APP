//= require './events'

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
    this.filter_customer();
    this.show_ibiza_customer();
    this.show_exact_online_customer();
    this.show_my_unisoft_customer();
    this.show_sage_gec_customer();
    this.check_commitment_pending();

    if ($('.packages_list').length > 0 ) {
      // this.check_input_number();
      this.show_subscription_option();

      this.update_price();
    }

    if ($('#journals select#copy-journals-into-customer').length > 0) { searchable_option_copy_journals_list(); }

    ApplicationJS.set_checkbox_radio(this);
  }

  check_commitment_pending(){
    if( $('.form-check-input.radio-button.main-option.commitment_pending').length > 0 ){
      $('.form-check-input.radio-button.main-option').attr('disabled', 'disabled');
      $('.form-check-input.radio-button.main-option.commitment_pending').each(function(e){
        if($(this).is(':checked')){
          ($(this).removeAttr('disabled'));
        }
      });
    }
  }


  check_input_number(){
    let self = this;
    let special_input = $('.subscription_number_of_journals input[type="number"].special_input');
    let current_value = special_input.val();

    special_input.focus();

    special_input.unbind('change.account_book_type').bind('change.account_book_type', function(e) {
      current_value += $(this).val();

      self.update_price();
    });

    special_input.unbind('keypress').bind('keypress', function(e) {
      e.preventDefault();
      return false;
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
    if ($('#subscription_subscription_option_ido_plus_micro').is(':checked')) {
      options.push('ido_micro_plus');
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

    if (class_list.indexOf("ido_plus_micro") > -1) {
      email_option.find('.option_checkbox').addClass('ido_plus_micro_option');
      retriever_option.find('.option_checkbox').addClass('ido_plus_micro_option');
      digitization_option.find('.option_checkbox').addClass('ido_plus_micro_option');
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

    $('.packages_list .main-option').unbind('click').bind('click', function(e){
      e.stopPropagation();

      $('.options').addClass('hide').removeClass('active')
      $(this).closest('.package').find('.options').removeClass('hide').addClass('active')
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

  add_customer(){
    var self = this;
    $('.new-customer').unbind('click.open_new_customer').bind('click.open_new_customer',function(e) {
      e.stopPropagation();
      self.get_customer_first_step_form();
    });
  }


  set_customer_carousel_on_slide(){
    let self = this;
    self.show_ibiza_customer();

    ApplicationJS.set_checkbox_radio(self);

    $('#carousel_customer_form').on('slide.bs.carousel', function (event) {
      switch (event.to) {
        case 0:
          // customer basic form

          self.create_customer_modal.find('.modal-title').text('Créer un nouveau client');
          self.create_customer_modal.find('.next').removeClass('hide');
          self.create_customer_modal.find('.previous').addClass('hide');
          self.create_customer_modal.find('.submit_customer').addClass('hide');

          self.show_ibiza_customer();

          ApplicationJS.set_checkbox_radio(self);

          break;
        case 1:
          // package subscription form

          self.create_customer_modal.find('.modal-title').text('Sélectionner un abonnement');
          self.create_customer_modal.find('.previous').removeClass('hide');
          self.create_customer_modal.find('.next').addClass('hide');
          self.create_customer_modal.find('.submit_customer').removeClass('hide');

          if ($('#personalize_subscription_package_form').length > 0 ) {
            self.update_price();
            self.check_input_number();
            self.show_subscription_option();
            ApplicationJS.set_checkbox_radio(self);
          }

          bind_customer_events();

          ApplicationJS.set_checkbox_radio(self);
          break;
        default:
          //Default
      }
    });
  }


  show_ibiza_customer(){
    let ibiza_softwares_section = $('#create-customer-form-data .softwares-section');
    const show_ibiza_list = (selector) => {
      if ($(selector).is(':checked')) {
        ibiza_softwares_section.css('display', 'block');
        ibiza_softwares_section.attr('load', 'YES');
      } else {
        ibiza_softwares_section.css('display', 'none');
        ibiza_softwares_section.attr('load', 'NO');
      }

      if ( (ibiza_softwares_section.attr('load') === 'YES') && $('#create-customer-form-data .softwares-section .ibiza-customers-list').length > 0) {
        get_ibiza_customers_list($('#create-customer-form-data .softwares-section .ibiza-customers-list'));
      }
    };

    const get_ibiza_customers_list = (selector) => {
      AppLoading('show');
      this.applicationJS.sendRequest({
        'url': selector.data('users-list-url'),
        'type': 'GET',
        'dataType': 'json'
      }).then((result)=>{
        if(result['message'] === undefined || result['message'] === null)
        {
          let original_value = selector.data('original-value') || '';
          for (let iterator = 0; iterator < result.length; iterator++) {
            let _element = result[iterator];
            let option_html = '';
            if (original_value.length > 0 && original_value === _element['id']) {
              option_html = '<option value="' + _element['id'] + '" selected="selected">' + _element['name'] + '</option>';
            } else {
              option_html = '<option value="' + _element['id'] + '">' + _element['name'] + '</option>';
            }
            selector.append(option_html);
          }

          AppLoading('hide');
          selector.chosen({
            search_contains: true,
            no_results_text: 'Aucun résultat correspondant à'
          });
        }
      });
    }

    const ibiza_checkbox_selector = $('#create-customer-form-data input[type="checkbox"].check-ibiza');

    show_ibiza_list(ibiza_checkbox_selector);

    ibiza_checkbox_selector.change(function() {
      show_ibiza_list(this);
    });

    if ($('#edit_ibiza_form').length > 0 ) {
      get_ibiza_customers_list($('#user_ibiza_attributes_ibiza_id'));

      let update_ibiza_btn = $('button[type=button].update_ibiza_organization_users');
      if (update_ibiza_btn.length > 0){
        update_ibiza_btn.removeAttr('disabled');
      }
    }
  }

  show_exact_online_customer(){
    if ($('#exact-online-form').length > 0 ) {
      $('.check-api-value').change(function() {        
        if ($('#user_exact_online_attributes_client_id').val() != '' && $('#user_exact_online_attributes_client_secret').val() != ''){
          $('button[type=button].exact_online_validation').removeAttr('disabled');
        }
        else{
          $('button[type=button].exact_online_validation').attr('disabled', true);
        }
      });
    }
  }

  show_my_unisoft_customer(){
    if ($('#my-unisoft-form').length > 0 ) {
      $('.key-my-unisoft').change(function() {        
        if ($(this).val() != ''){
          $('button[type=button].my_unisoft_validation').removeAttr('disabled');
        }
        else{
          $('button[type=button].my_unisoft_validation').attr('disabled', true);
        }
      });
    }
  }

  show_sage_gec_customer(){
    if ($('#sage-gec-form').length > 0 ) {
      $('.key-sage-gec').change(function() {        
        if ($(this).val() != ''){
          $('button[type=button].sage_gec_validation').removeAttr('disabled');
        }
        else{
          $('button[type=button].sage_gec_validation').attr('disabled', true);
        }
      });
    }
  }

  show_acd_customer(){
    if ($('#acd-form').length > 0 ) {
      $('.key-acd').change(function() {        
        if ($(this).val() != ''){
          $('button[type=button].acd_validation').removeAttr('disabled');
        }
        else{
          $('button[type=button].acd_validation').attr('disabled', true);
        }
      });
    }
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

      this.set_customer_carousel_on_slide();
    });
  }


  filter_customer(){
    let self = this;
    $('.customer-filter').unbind('click').bind('click',function(e) {
      e.stopPropagation();

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

      this.rebind_customer_all_events();
    });
  }

  close_or_reopen_confirm(url, data={}){
    let params = {};
    let redirect_to = `/organizations/${(url.split('organizations/')[1].split('/customers')[0] || this.organization_id)}/customers`;

    if (url.indexOf("reopen_account") >= 0) {
      params = {'url': url, 'type': 'POST', data: { _method: 'PATCH' }, 'dataType': 'html'};
      let raw_customer_ids = url.split('/');
      let  customer_id = raw_customer_ids[raw_customer_ids.length - 2]
      redirect_to = `${redirect_to}/${customer_id}`;
    }
    else if (url.indexOf("close_account") >= 0) {
      params = {'url': url, 'data': data, 'type': 'POST', 'dataType': 'html'};
    }

    this.applicationJS.sendRequest(params).then((response)=>{
      this.account_close_confirm_modal.modal('hide');

      window.location.replace(redirect_to);
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

    if (required_fields_count >= 3) { this.create_customer_modal.find('.carousel-item-action .next').removeAttr('disabled'); }
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
 
      this.rebind_customer_all_events();
    })
    .catch(()=>{ this.action_locker = false; });
  }

  rebind_customer_all_events(){
    this.main();
    bind_customer_events();
    ApplicationJS.set_checkbox_radio();
  }
}


jQuery(function () {
  var customer = new Customer();

  AppListenTo('validate_first_slide_form', (e)=>{ customer.validate_first_slide_form(); });

  AppListenTo('search_text', (e)=>{ customer.load_data(true); });

  AppListenTo('close_or_reopen_confirm_view', (e)=>{ customer.close_or_reopen_confirm_view(e.detail.url, e.detail.target); });
  AppListenTo('close_or_reopen_confirm', (e)=>{ customer.close_or_reopen_confirm(e.detail.url, e.detail.data); });

  AppListenTo('bind_api_user_events', (e)=>{ customer.rebind_customer_all_events(); });
  
  customer.main();

  AppListenTo('show_new_customer', (e)=>{ if (e.detail.response.json_flash.success) { window.location.href = e.detail.response.url } });  
});