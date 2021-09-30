class Journal{
  constructor(){
    this.applicationJS              = new ApplicationJS;
    this.organization_id            = $('input:hidden[name="organization_id"]').val();
    this.journal_form_modal         = $('#journal-form.modal');
    this.default_vat_accounts_label = 'Compte de TVA par défaut attribué au journal comptable iDocus';
    this.action_locker              = false;
  }

  set_carousel_content_on_slide(){
    let self = this;
    const set_default_carousel_slide = () => {
      self.journal_form_modal.find('.previous').addClass('hide');
      self.journal_form_modal.find('.validate').addClass('hide');
      self.journal_form_modal.find('.next').removeClass('hide');
      self.journal_form_modal.find('.next').text('Suivant');

      self.select_entry_type();
      self.required_fields();
      self.validate_first_slide_form();
    };

    set_default_carousel_slide();
    self.update_form();

    $('#carousel-journal-form').on('slide.bs.carousel', function (event) {
      switch (event.to) {
        case 0:
          // do something for .journal-first-step-form
          set_default_carousel_slide();

          break;
        case 1:
          // do something for .knowings-configuration .pre-assignment-attributes ...
          self.journal_form_modal.find('.previous-next-controls .next').removeAttr('disabled');
          self.journal_form_modal.find('.previous').removeClass('hide');
          self.journal_form_modal.find('.validate').addClass('hide');
          self.journal_form_modal.find('.next').removeClass('hide');
          self.journal_form_modal.find('.next').text('Suivant');
          self.show_vat_account_field();

          $('.add_vat_account_field').unbind('click.more_vats').bind('click.more_vats', function(e) {
            e.stopPropagation();

            self.add_vat_account_field(10, 445660, 70054614);

            self.remove_vat_account_field();
          });

          self.remove_vat_account_field();
          $('input[name="account_book_type[account_type]"]').unbind('click.show_type').bind('click.show_type', function(e) {
            if ($(this).is(":checked")){
              $(this).attr('checked', 'checked');
            }

            self.update_form();
          });

          if (parseInt($("#account_book_type_entry_type").val()) === 0){
            $('.no_entry_selected').html($('.carousel_item_last_slide').html());
            self.journal_form_modal.find('.next').addClass('hide');
            self.journal_form_modal.find('.validate').removeClass('hide');

            self.submit_journal_form(true);
          }

          break;
        case 2:
          // do something for .ido-instruction, .default-options
          self.journal_form_modal.find('.previous-next-controls .next').removeAttr('disabled');
          self.serialize_vat_accounts('#journal-form.modal form .account_book_type_vat_accounts');
          self.journal_form_modal.find('.next').addClass('hide');
          self.journal_form_modal.find('.validate').removeClass('hide');
          self.submit_journal_form();

          break;
        default:
          //Default
      }
    });
  }


  submit_journal_form(no_entry_selected=false){
    let self = this;
    $('.previous-next-controls .validate').unbind('click.submit_journal').bind('click.submit_journal', function(e) {
      e.stopPropagation();

      if (no_entry_selected) {
        $('.carousel_item_last_slide').remove();
      }

      $('form#new-journal-form, form#edit-journal-form').submit();
      self.journal_form_modal.modal('hide');
    });
  }

  select_entry_type(){
    let self = this;
    $('#account_book_type_entry_type').unbind('change').bind('change', function(e) {
      e.stopPropagation();
      self.update_form();
    });
  }

  add_vat_account_field(rate, vat_account, conterpart_account){
    let self = this;

    let cloned_field = '.account_book_type_vat_accounts_field';

    $(cloned_field + ' input[name="account_book_type[vat_accounts_label]"]').attr('value', rate);
    $(cloned_field + ' input[name="account_book_type[vat_accounts_rate]"]').attr('value', vat_account);
    $(cloned_field + ' input[name="account_book_type[vat_accounts_conterpart]"]').attr('value', conterpart_account);

    let input_field = $(cloned_field);

    $('.pre-assignment-attributes #account_book_type_with_default_vat_accounts').after(input_field.html());

    $('.account_book_type_label_vat_accounts').focus();


    $('.account_book_type_label_vat_accounts').unbind('blur keypress input change').bind('blur keypress input change', function(e) {
      let error_message_target = $('.vat_accounts_label_error');
      let current_target       = $(this).closest('.account_book_type_vat_accounts').find(error_message_target);

      if (e.which !== 8 && e.which !== 0 && (e.which < 48 || e.which > 57) && !(e.keyCode === 46 || e.charCode === 46 || e.keyCode === 44 || e.charCode === 44) && !(e.which === 13 || e.keyCode === 13 || e.key === "Enter")){
        current_target.html('Chiffre uniquement ou avec un point ou une virgule').show().delay(5000).fadeOut('slow');
        return false;
      }

      let value = $(this).val();
      let regex = /^\d{1,2}([,.]{1}\d{1,2})?$/;

      if((e.type === 'blur' && !regex.test(value)) || (!regex.test(value) && (e.which === 13 || e.keyCode === 13 || e.key === "Enter"))){
        current_target.html('Saisie incorrecte').show().delay(5000).fadeOut('slow');
        return false;
      }

      if (e.type === 'input'){
        value = $(this).val();
        if (parseFloat(value) < 1 || parseFloat(value) > 20){
          current_target.html('Taux de TVA doit être inclus entre (1-20%)').show().delay(5000).fadeOut('slow');
          return false;
        }
      }

      current_target.css('color', '#FF4848');

    });
  }

  remove_vat_account_field(){
    let self = this;
    $('.remove_vat_accounts_field').unbind('click').bind('click', function(e) {
      e.stopPropagation();

      $('[data-toggle="tooltip"]').tooltip("hide");
      $(this).closest('.account_book_type_vat_accounts').remove();
    });
  }

  serialize_vat_accounts(form){
    let self = this;
    let vat_accounts = {};

    $(form).each(function() {
      let vat_account = $(this);
      let label = vat_account.find('input[type="text"].vat_accounts_label, input[type="number"].vat_accounts_label').val();
      let vat_accounts_field = vat_account.find('input[type="text"].vat_accounts').val();
      let conterpart_vat_accounts_field = vat_account.find('input[type="text"].vat_accounts_conterpart').val();

      if ((label === self.default_vat_accounts_label) || label === 'Compte de TVA par défaut' ){
        label = '0';
      }

      if (!(/undefined/.test(vat_accounts_field) || /undefined/.test(label) || label === null || label === undefined || label === '' || vat_accounts_field === null || vat_accounts_field === '' || vat_accounts_field === undefined)){
        vat_accounts[label] = [vat_accounts_field, conterpart_vat_accounts_field];
      }
    });

    vat_accounts = JSON.stringify(vat_accounts);
    $('input[type=hidden]#account-book-type-vat-accounts-hidden').attr('value', vat_accounts);
  }

  show_vat_account_field(){
    let vat_accounts_values      = [];
    let rate_vat_accounts_values = [];
    let conterpart_vat_accounts_values = [];

    $.map($('fieldset .more_vat_accounts input[name="account_book_type[vat_accounts_rate]"]'), (element, index) => { vat_accounts_values.push($(element).val()) });
    $.map($('fieldset .more_vat_accounts input[name="account_book_type[vat_accounts_label]"]'), (element, index) => { rate_vat_accounts_values.push($(element).val()) });
    $.map($('fieldset .more_vat_accounts input[name="account_book_type[vat_accounts_conterpart]"]'), (element, index) => { conterpart_vat_accounts_values.push($(element).val()) });

    let self = this;
    let vat_accounts = $('input[type=hidden]#account-book-type-vat-accounts-hidden').val();

    if (!(vat_accounts === '' || vat_accounts === null || vat_accounts === 'undefined' || vat_accounts === undefined)) {
      try {
        vat_accounts = JSON.parse(vat_accounts);
        for(let rate in vat_accounts){
          let raw_vat_account = vat_accounts[rate];
          let vat_account = raw_vat_account[0];
          let conterpart_vat_account = raw_vat_account[1]

          if ((rate.indexOf(self.default_vat_accounts_label) >= 0) || (rate === 'Compte de TVA par défaut') || (rate === '0')){
            vat_account = vat_account || 445660; /* SET DEFAULT VALUE TO 445660 WHEN IT IS EMPTY*/
            conterpart_vat_account = conterpart_vat_account || 70054614; // TODO ==> NEED TO SET DEFAULT VALUE HERE
            $('input[type="text"]#account_book_type_default_vat_accounts').attr('value', vat_account);
            $('input[type="text"]#account_book_type_default_conterpart_accounts').attr('value', conterpart_vat_account);

            if ($('.account_book_type_vat_accounts.error').length > 0){

              $('input[type="text"]#account_book_type_default_vat_accounts').css('border', '1px solid #b94a48');
              $('input[type="text"]#account_book_type_default_vat_accounts').attr('value', '');
              $('input[type="text"]#account_book_type_default_conterpart_accounts').attr('value', '');
            }
          }
          else if (!($.inArray(rate, rate_vat_accounts_values) > -1 || $.inArray(vat_account, vat_accounts_values) > -1) || $.inArray(conterpart_vat_account, vat_accounts_values) > -1 ){
            if (!(rate === '' || rate === 'undefined' || rate === null || rate === undefined || vat_account === '' || vat_account === 'undefined' || vat_account === null || vat_account === undefined || (rate.indexOf(self.default_vat_accounts_label) >= 0) || rate === '0')){
              self.add_vat_account_field(rate, vat_account, conterpart_vat_account);
            }
          }
        }
      } catch (error) {
        console.error(error);
        return false;
      }
    }
  }

  required_fields(){
    let self = this;
    let required_fields_count = 0;

    $('input[type="text"].required_field').each(function() {
      if ($(this).val() !== '') {
        required_fields_count += 1;
      }
    });

    if (required_fields_count >= 2) { self.journal_form_modal.find('.previous-next-controls .next').removeAttr('disabled'); }
  }

  validate_first_slide_form(){
    let self = this;

    $('input[type="text"].required_field').unbind('keypress input').bind('keypress input', function(e) { self.required_fields(); });
  }

  update_form(){
    if (parseInt($("#account_book_type_entry_type").val()) > 1 && parseInt($("#account_book_type_entry_type").val()) < 4){
      this.toggle_required_field('enable');
      $('.pre-assignment-attributes').removeClass('hide');
      $('.no_entry_selected').addClass('hide');
    }
    else if (parseInt($("#account_book_type_entry_type").val()) === 0){
      $('.pre-assignment-attributes').addClass('hide');
      $('.no_entry_selected').removeClass('hide');
    }
    else{
      this.toggle_required_field('disable');
      $('.pre-assignment-attributes').addClass('hide');
      $('.no_entry_selected').addClass('hide');
    }
  }

  edit_analytics(id, customer_id, code){
    $('#comptaAnalysisEdition.modal').modal('show');
    this.analytic_journal_id = id;
    this.analytic_customer_id = customer_id;

    AppEmit('compta_analytics.main_loading', { code: code, pattern: id, type: 'journal', is_used: true });
  }

  update_analytics(data){
    let params =  {
                    url: `/organizations/${this.organization_id}/customers/${this.analytic_customer_id}/journals/update_analytics`,
                    type: 'POST',
                    data: { id: this.analytic_journal_id, analysis: data },
                    dataType: 'json'
                  }

    this.applicationJS.sendRequest(params).then((e)=>{ $('#comptaAnalysisEdition.modal').modal('hide'); });
  }

  load_journals(type='journals', page=1, per_page=0){
    if(this.action_locker) { return false; }

    this.action_locker = true;
    let params = [];

    params.push(`page=${page}`);

    if (per_page > 0) { params.push(`per_page=${ per_page }`); }

    let ajax_params =   {
                          'url': `/organizations/${this.organization_id}/journals?${params.join('&')}`,
                          'dataType': 'html',
                          'target': ''
                        };

    this.applicationJS.sendRequest(ajax_params)
                      .then((html)=>{
                        this.action_locker = false;
                        this.main();
                      })
                      .catch(()=>{ this.action_locker = false; });
  }

  main() {
    this.new_edit_account_book_type_view()
    ApplicationJS.set_checkbox_radio();
    this.select_entry_type();
    this.set_carousel_content_on_slide();
  }

  new_edit_account_book_type_view(){
    let self = this;
   
    $('.new_edit_account_book_type').unbind('click.new_edit_jo').bind('click.new_edit_jo', function(e) {
      e.stopPropagation();

      const url = $(this).attr('link');

      self.applicationJS.sendRequest({ 'url': url }).then((element)=>{
        let from        = '#journal.new';
        let modal_title = 'Nouveau journal comptable';

        if (url.indexOf("edit") >= 0) {
          from        = '#journal.edit';
          modal_title = 'Édition de journal comptable';
        }

        self.journal_form_modal.find('.modal-body').html($(element).find(from).html());
        self.journal_form_modal.find('.modal-title').text(modal_title);
        self.journal_form_modal.find('.previous-next-controls .next').attr('disabled', 'disabled');
        self.journal_form_modal.modal('show');

        ApplicationJS.set_checkbox_radio();
        self.required_fields();
        self.validate_first_slide_form();
        self.select_entry_type();
        self.set_carousel_content_on_slide();
      });
    });
  }

  toggle_required_field(type){
    if (type === 'enable'){
      $('#new_account_book_type .can_be_required').attr('required', 'required');
    }
    else{
      $('#new_account_book_type .can_be_required').removeAttr('required');
    }
  }
}