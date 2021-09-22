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

  $('#edit_customer_csv_descriptor').unbind('click').bind('click', function(e){ AppEmit('csv_descriptor_edit_customer_format', { id: $(this).data('id'), organization_id: $(this).data('organization-id') }) });

  /*$('.valid_subscription_edit').unbind('click').bind('click', function(e) {
    e.preventDefault();

    const form = $('form#subscription_package_form');

    AppEmit('update_subscription', { url: form.attr('action'), data: form.serialize()});
  });*/


  $('.new_edit_order_url').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    const url = $(this).attr('link');

    AppEmit('new_edit_order_view', { url: url });
  });


  $('.select_for_orders').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    const url = $(this).attr('link');

    AppEmit('select_for_orders', { url: url });

    $('#select_for_orders').modal('show');
  });

  $('.edit-file-sending-kits').unbind('click').bind('click', function(e) {
    e.preventDefault();

    const url = $(this).attr('link');

    AppEmit('edit_file_sending_kits_view', { url: url});
  });

  $('.validate_file_sending_kits_edit').unbind('click').bind('click', function(e) {
    e.stopPropagation();
    $('form#edit_file_sending_kit_form').submit();
  });


  /*$('.add_account_book_type').unbind('click').bind('click', function(e) {
    e.preventDefault();

    const url = $(this).attr('link');

    AppEmit('new_account_book_type_view', { url: url});
  });*/

  /*$('.edit_journal_customer').unbind('click').bind('click', function(e) {
    e.preventDefault();

    const url = $(this).attr('href');

    AppEmit('new_edit_journal_view', { url: url});
  });*/
}


jQuery(function() {
 bind_customer_events();
});