function searchable_option_copy_journals_list() {
  let checked_count = 0;

  $('select#copy-journals-into-customer').removeClass('form-control');
  $('select#copy-journals-into-customer').asMultiSelect({
    'noneText': 'Selectionner un/des journaux',
    'allText': 'Tous séléctionnés',
    events: {
      onChange: function(sol, changedElements) {
        changedElements['0'].checked ? checked_count ++ : checked_count --;
        (checked_count > 0) ? $('.copy_account_book_type_btn').removeAttr('disabled') : $('.copy_account_book_type_btn').attr('disabled', 'disabled');
      },
    }
  });
}

function bind_customer_events() {
  $('.close_customer, .reopen_customer').unbind('click').bind('click',function(e) {
    e.preventDefault();

    let target = 'close';

    if ($(this).hasClass('reopen_customer')) { target = 'reopen'; }

    const url = $(this).attr('href');

    AppEmit('close_or_reopen_confirm_view', { url: url, target: target });
  });

  $('.close_or_reopen_confirm').unbind('click').bind('click', function(e) {
    e.preventDefault();
    e.stopPropagation();

    let form_data = {};
    let url = '';
    let attr = $(this).attr('link');

    if ($(this).hasClass('close')) {
      const form = $('form#account_close_confirm');
      form_data = form.serialize();
      url = form.attr('action');
    }
    else if (typeof attr !== 'undefined' && attr !== false)
    {
      url = attr;
    }

    AppEmit('close_or_reopen_confirm', { url: url, data: form_data });
  });


  $('input.required_field').unbind('keypress input')
  .bind('keypress input', function(e) {
    AppEmit('validate_first_slide_form');
  });

  $('.search-content #search_input')
  .unbind('keyup').bind('keyup', function(e){
    e.stopPropagation();

    if(e.key == 'Enter'){
      AppEmit('search_text');
    } 
  });

  $('.search-content .input-group-text')
  .unbind('click').bind('click', function(e){
    e.preventDefault();
    AppEmit('search_text');
  });


  $('form.subscription_option_form .valid_subscription_edit, .submit_customer').unbind('click').bind('click', function(e){
    e.preventDefault();

    AppToggleLoading('show');

    $('form.subscription_option_form').find('.clonable_fields').remove();
    $('form.subscription_option_form').submit();
  });

  $('.td-popover').mouseover(function() {
    $(this).find('.popover_content_customer').show();
  })
  .mouseout(function() {
    $(this).find('.popover_content_customer').hide();
  });
}


jQuery(function() {
  AppListenTo('window.application_auto_rebind', (e)=>{ bind_customer_events(); }) ;
});