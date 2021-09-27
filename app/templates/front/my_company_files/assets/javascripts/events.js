function bind_mcf_customer_events() {
  $('.edit_mcf_customer').unbind('click.edit_mcf').bind('click.edit_mcf', function(e) {
    e.stopPropagation();

    const url = $(this).attr('link');

    AppEmit('show_mcf_edition', { url: url });
  });

  
  if ($('#customer.errors.mcf').length > 0) {
    $('#master_checkbox').unbind('change.mcf_checkbox').bind('change.mcf_checkbox', function(e){
      if ($(this).is(':checked')) {
        return $('.checkbox').prop('checked', true);
      } else {
        return $('.checkbox').prop('checked', false);
      }
    });
  }
}

jQuery(function() {
  bind_mcf_customer_events();
});