function is_manual_paper_set_order_applied() {
  const manual_paper_set_order = $('#paper_set_specific_prices');
  return manual_paper_set_order.length > 0 && manual_paper_set_order.attr("data-manual") === 'true';
}


function confirm_manual_paper_set_order(){
  if (is_manual_paper_set_order_applied()){
    $('.valid-manual-paper-set-order').unbind('click').bind('click', function(e) {
      e.preventDefault();
      if (confirm("Vous êtes sur le point de commander un kit sans passer par courrier. Etes-vous sûr ?")){
        $('#valid-manual-paper-set-order').submit();
      }
    });
  }
}


function apply_searchable_option_list(target) {
  if (target=== 'select_customers') {
    $('select#select-customers-paper-set-order').removeClass('form-control');
    $('select#select-customers-paper-set-order').searchableOptionList({
      'searchplaceholder': 'Selectionner / Rechercher un dossier client à qui envoyer un kit courrier',
      'noneText': 'Selectionner un/des journaux',
      'allText': 'Tous séléctionnés'
    });
  }
}


function bind_all_events_paper_set_orders(){
  apply_searchable_option_list('select_customers');
  $('.select_for_orders').unbind('click').bind('click', function(e) {      
    e.stopPropagation();

    AppEmit('select_for_orders');
    apply_searchable_option_list('select_customers');

    $('#select_for_orders').modal('show');
  });


  $('.select.order_paper_set_casing_count i.help-block').addClass('hide');


  $('.sub_menu .add').unbind('click').bind('click', function(e) {      
    e.preventDefault();

    AppEmit('add_or_edit_paper_set_order', {url: $(this).find('a').attr('href')});

    $('#add-new-paper-set-order').modal('show');
  });


  $('.sub_menu .edit').unbind('click')
  .bind('click', function(e){
    e.stopPropagation();
    e.preventDefault();

    if ($(this).hasClass('edit-paper-set-order')) {
      AppEmit('add_or_edit_paper_set_order', {url: $(this).find('a').attr('href')});

      $('#add-new-paper-set-order').modal('show');
    }
  });


  $('.valid-paper-set-order').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    /*$('#order_multiple_paper_set').submit();*/

    let form = $('form#order_multiple_paper_set');
    let url = form.attr('action');

    AppEmit('order_multiple_paper_set', { url: url, data: form.serialize() });

    $('#select_for_orders').modal('hide');
    $('#create_order_multiple').modal('show');
  });


  $('.action.sub-menu-box, .action.sub-menu-kit')
  .unbind('click').bind('click', function(e) {
    e.stopPropagation();

    $('.sub_menu').not(this).each(function(){
      $(this).addClass('hide');
    });

    $(this).parent().find('.sub_menu').removeClass('hide');
  });

  if ($('form.paper_set_order_form').length > 0){
    AppEmit('update_casing_counts');
    AppEmit('update_price');

    $('select').unbind('change').bind('change', function(e) {
      if ($(this).attr('id') === 'order_paper_set_start_date' || $(this).attr('id') === 'order_paper_set_end_date' ) {
        AppEmit('check_casing_size_and_count');
      }

      AppEmit('update_price');
    });

    $('.copy_address').unbind('click').bind('click', function(e) {
      e.stopPropagation();

      $('#order_paper_return_address_attributes_company').val($('#order_address_attributes_company').val());
      $('#order_paper_return_address_attributes_last_name').val($('#order_address_attributes_last_name').val());
      $('#order_paper_return_address_attributes_first_name').val($('#order_address_attributes_first_name').val());
      $('#order_paper_return_address_attributes_address_1').val($('#order_address_attributes_address_1').val());
      $('#order_paper_return_address_attributes_address_2').val($('#order_address_attributes_address_2').val());
      $('#order_paper_return_address_attributes_city').val($('#order_address_attributes_city').val());
      $('#order_paper_return_address_attributes_zip').val($('#order_address_attributes_zip').val());
    });

    confirm_manual_paper_set_order();
  }

  if ($('#paper_set_orders.select_to_order').length > 0){
    $('#master_checkbox').unbind('change').bind('change', function(e) {
      if ($(this).is(':checked')){
        $('.checkbox').attr('checked', true);
      }
      else{
        $('.checkbox').attr('checked', false);
      }
    });
  }

  if ($('.order_multiple form, form.order_multiple_form').length > 0){
    AppEmit('update_table_casing_counts', { index: -1});
    AppEmit('update_table_price');

    $('select').unbind('change').bind('change', function(e) { AppEmit('update_table_price'); });
    $('.date_order').unbind('change').bind('change', function(e) {
      index = $(this).attr("data-index");
      AppEmit('update_table_casing_counts', { index: index});
    });

    confirm_manual_paper_set_order();
  }

  $('.add-paper-set-order, .create-paper-set-order-multiple').unbind('click').bind('click', function(e) {
    e.stopPropagation();
    $('#valid-manual-paper-set-order.paper_set_order_form, #default.paper_set_order_form').submit();
  });

  ApplicationJS.set_checkbox_radio();
  ApplicationJS.hide_submenu();
}

jQuery(function() {
  bind_all_events_paper_set_orders();
});