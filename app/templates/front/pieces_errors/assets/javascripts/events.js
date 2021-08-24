function bind_all_events(){
  $('.piece-errors-filter').unbind('click')
  $(".piece-errors-filter").bind('click',function(e) {
    e.stopPropagation()

    $('#filter-'+ $(".tab-pane.active").attr('id')).modal('show');
  });

  $('.modal#filter-ignored-pre-assignment button.validate').unbind('click').bind('click', (e)=>{ AppEmit('pieces_errors_filter_page', { target: 'ignored-pre-assignment', action: 'validate'}); });
  $('.modal#filter-duplicated-pre-assignment button.validate').unbind('click').bind('click', (e)=>{ AppEmit('pieces_errors_filter_page', { target: 'duplicated-pre-assignment', action: 'validate'}); });

  $('.modal#filter-ignored-pre-assignment button.cancel').unbind('click').bind('click', (e)=>{ AppEmit('pieces_errors_filter_page', { target: 'ignored-pre-assignment', action: 'reset'}); });
  $('.modal#filter-duplicated-pre-assignment button.cancel').unbind('click').bind('click', (e)=>{ AppEmit('pieces_errors_filter_page', { target: 'duplicated-pre-assignment', action: 'reset'}); });

  $('#resend-to-pre-assignment').unbind('click').bind('click', function(e){ AppEmit('pieces_errors_update_ignored_pieces', { type: 'force_pre_assignment' }) });
  $('#confirm-ignorance').unbind('click').bind('click', function(e){ AppEmit('pieces_errors_update_ignored_pieces', { type: 'confirm_ignorance' }) });

  $('#unlock-preseizures').unbind('click').bind('click', function(e){ AppEmit('pieces_errors_update_duplicated_preseizures', { type: 'unlock_preseizures' }) });
  $('#confirm-duplication').unbind('click').bind('click', function(e){ AppEmit('pieces_errors_update_duplicated_preseizures', { type: 'confirm_duplication' }) });
}

jQuery(function() {
  bind_all_events();
});