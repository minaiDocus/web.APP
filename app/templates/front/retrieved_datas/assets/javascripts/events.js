function bind_all_events(){
  $('.retriever-filter-historic').unbind('click')
  $(".retriever-filter-historic").bind('click',function(e) {
    e.stopPropagation()

    $('#filter-'+ $(".tab-pane.active").attr('id')).modal('show');
  });

  $('select#account_id').unbind('change');
  $('select#account_id').bind('change', function(e){ AppEmit('retrieved_datas_reload_all') });

  $('.modal button.validate-filter').unbind('click');
  $('.modal button.validate-filter').bind('click', function(e){ AppEmit('retrieved_datas_filter', { type: $(this).attr('data-target') }) });

  $('.modal button.reset-filter').unbind('click');
  $('.modal button.reset-filter').bind('click', function(e){ AppEmit('retrieved_datas_reset_filter', { type: $(this).attr('data-target') }) });

  $('button.force-preseizures').unbind('click');
  $('button.force-preseizures').bind('click', function(e){ AppEmit('retrieved_datas_force_preseizures') });

  $('select.per-page').unbind('change');
  $('select.per-page').bind('change', function(e){ AppEmit('retrieved_datas_per_page', { type: $(this).data('type') }) });

  $('span.previous_page').unbind('click');
  $('span.previous_page').bind('click', function(e){ AppEmit('retrieved_datas_previous_page', { type: $(this).data('type') }) });

  $('span.next_page').unbind('click');
  $('span.next_page').bind('click', function(e){ AppEmit('retrieved_datas_next_page', { type: $(this).data('type') }) });
}

jQuery(function() {
  bind_all_events();
});