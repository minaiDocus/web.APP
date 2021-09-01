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
    self.select_entry_type();
    self.required_fields();
    self.update_form();

    $('#carousel-journal-form').on('slide.bs.carousel', function (event) {
      switch (event.to) {
        case 0:
          // do something for .journal-first-step-form
          self.journal_form_modal.find('.previous').addClass('hide');
          self.journal_form_modal.find('.next').text('Suivant');
          self.required_fields();
          self.validate_first_slide_form();
          self.select_entry_type();
          break;
        case 1:
          // do something for .knowings-configuration .pre-assignment-attributes ...
          self.journal_form_modal.find('.previous-next-controls .next').removeAttr('disabled');
          self.journal_form_modal.find('.previous').removeClass('hide');
          self.journal_form_modal.find('.next').text('Suivant');
          self.show_vat_account_field();

          $('.add_vat_account_field').unbind('click').bind('click', function(e) {
            e.stopPropagation();

            self.add_vat_account_field(10, 445660);

            self.remove_vat_account_field();
          });

          self.remove_vat_account_field();
          $('input[name="account_book_type[account_type]"]').unbind('click').bind('click', function(e) {
            if ($(this).is(":checked")){
              $(this).attr('checked', 'checked');
            }

            self.update_form();
          });
          break;
        case 2:
          // do something for .ido-instruction, .default-options
          self.journal_form_modal.find('.previous-next-controls .next').removeAttr('disabled');
          self.serialize_vat_accounts('#journal-form.modal form .account_book_type_vat_accounts');
          self.journal_form_modal.find('.next').addClass('hide');
          self.journal_form_modal.find('.validate').removeClass('hide');
          $('.previous-next-controls .validate').unbind('click').bind('click', function(e) {
            e.stopPropagation();

            $('form#new-journal-form, form#edit-journal-form').submit();
            self.journal_form_modal.modal('hide');
          });
          break;
        default:
          //Default
      }
    });
  }

  select_entry_type(){
    let self = this;
    $('#account_book_type_entry_type').unbind('change').bind('change', function(e) {
      e.stopPropagation();
      self.update_form();
    });
  }



  add_vat_account_field(rate, vat_account){
    let self = this;

    let cloned_field = '.account_book_type_vat_accounts_field';

    $(cloned_field + ' input[name="account_book_type[vat_accounts_label]"]').attr('value', rate);
    $(cloned_field + ' input[name="account_book_type[vat_accounts_rate]"]').attr('value', vat_account);

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
      let field = vat_account.find('input[type="text"].vat_accounts').val();

      if (label === self.default_vat_accounts_label){
        label = '0';
      }

      if (!(/undefined/.test(field) || /undefined/.test(label) || label === null || label === undefined || label === '' || field === null || field === '' || field === undefined)){
        vat_accounts[label] = field;
      }
    });

    vat_accounts = JSON.stringify(vat_accounts);
    $('input[type=hidden]#account-book-type-vat-accounts-hidden').attr('value', vat_accounts);
  }

  show_vat_account_field(){
    let self = this;
    let vat_accounts = $('input[type=hidden]#account-book-type-vat-accounts-hidden').val();

    if (!(vat_accounts === '' || vat_accounts === null || vat_accounts === 'undefined' || vat_accounts === undefined)) {
      try {
        vat_accounts = JSON.parse(vat_accounts);
        for(let rate in vat_accounts){
          let vat_account = vat_accounts[rate];
          if ((rate.indexOf(self.default_vat_accounts_label) >= 0) || (rate === '0')){
            $('input[type="text"]#account_book_type_default_vat_accounts').attr('value', vat_account);

            if ($('.account_book_type_vat_accounts.error').length > 0){
              $('input[type="text"]#account_book_type_default_vat_accounts').css('border', '1px solid #b94a48');
              $('input[type="text"]#account_book_type_default_vat_accounts').attr('value', '');
            }
          }
          if (!(rate === '' || rate === 'undefined' || rate === null || rate === undefined || vat_account === '' || vat_account === 'undefined' || vat_account === null || vat_account === undefined || (rate.indexOf(self.default_vat_accounts_label) >= 0) || rate === '0')){
            self.add_vat_account_field(rate, vat_account);
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

    if (required_fields_count === 2) { self.journal_form_modal.find('.previous-next-controls .next').removeAttr('disabled'); }
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


  add_journal(){
    let self = this;
    $('.new-journal').unbind('click').bind('click', function(e) {
      e.stopPropagation();

      self.get_journal_view_of();

      self.journal_form_modal.modal('show');
      ApplicationJS.set_checkbox_radio();
      self.select_entry_type();
      self.set_carousel_content_on_slide();
    });
  }


  edit_journal(){
   let self = this;
   
    $('.sub_menu.edit-journal .edit').unbind('click').bind('click', function(e) {
      e.stopPropagation();
      e.preventDefault();

      self.get_journal_view_of($(this).attr('journal_id'));

      self.journal_form_modal.modal('show');
      ApplicationJS.set_checkbox_radio();
      self.select_entry_type();
      self.set_carousel_content_on_slide();
    });
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

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((html)=>{
                        this.action_locker = false;
                        this.main();
                      })
                      .catch(()=>{ this.action_locker = false; });
  }


  main() {
    let self = this;
    self.add_journal();
    self.edit_journal();

    self.handle_edit_delete_submenu();
    ApplicationJS.set_checkbox_radio();
    self.select_entry_type();
    self.set_carousel_content_on_slide();
    ApplicationJS.hide_submenu();
  }


  get_journal_view_of(journal_id=null){
    let self = this;
    let url  = '/organizations/' + self.organization_id + '/journals/new';

    if (journal_id !== null) { url  = '/organizations/' + self.organization_id + '/journals/' + journal_id + '/edit'; }

    self.applicationJS.parseAjaxResponse({ 'url': url }).then((element)=>{
      let from        = '#journal.new';
      let modal_title = 'Nouveau journal comptable';

      if (journal_id !== null) { 
        from        = '#journal.edit';
        modal_title = 'Édition de journal comptable';
      }

      self.journal_form_modal.find('.modal-body').html($(element).find(from).html());
      self.journal_form_modal.find('.modal-title').text(modal_title);

      self.journal_form_modal.find('.previous-next-controls .next').attr('disabled', 'disabled');

      self.required_fields();
      self.validate_first_slide_form();

      ApplicationJS.set_checkbox_radio();

      self.set_carousel_content_on_slide();
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


  handle_edit_delete_submenu(){
    $('.action.sub-menu-book').unbind('click').bind('click',function(e) {
      e.stopPropagation();

      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).parent().find('.sub_menu').removeClass('hide');
    });
  }
}



jQuery(function () {
  let journal = new Journal();
  journal.main();

  AppListenTo('window.change-per-page.journales', (e)=>{ journal.load_journals(e.detail.name, 1, e.detail.per_page); });
  AppListenTo('window.change-page.journales', (e)=>{ journal.load_journals(e.detail.name, e.detail.page); });
});