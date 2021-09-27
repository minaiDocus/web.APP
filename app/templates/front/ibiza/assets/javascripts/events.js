function bind_ibizabox_documents_events() {
  $('.ibizabox_documents').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    const url = $(this).attr('link');
    let target = '.historic_content';

    if ($(this).hasClass('select')) { target = '.select_content'; }

    AppEmit('show_ibizabox_documents_page', { url: url, target: target });
  });

  $('.open_ibizabox_documents_filter').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    $('#ibizabox_documents_filter_modal').modal('show');
  });

  if ($('#ibizabox_documents.select').length > 0){
    $('#master_checkbox').unbind('change').bind('change', function(e) {
      if ($(this).is(':checked'))
        $('.checkbox').attr('checked', true);
      else
        $('.checkbox').attr('checked', false);
    });
  }
}

jQuery(function() {
  bind_ibizabox_documents_events();
});