function bind_all_events(){
  $('ul.nav.nav-tabs li.nav-item').unbind('click.filter').bind('click.filter', function(e){
    if( $(this).hasClass('no-filter') )
      $('.filter_button').addClass('hide');
    else
      $('.filter_button').removeClass('hide')
  })

  $('.piece-errors-filter').unbind('click')
  $(".piece-errors-filter").bind('click',function(e) {
    e.stopPropagation();

    $('#filter-'+ $(".tab-pane.active").attr('id')).modal('show');
  });

  $('.action.sub-menu-piece-ignored').unbind('click')
  $(".action.sub-menu-piece-ignored").bind('click',function(e) {
    e.stopPropagation();

    if ($(this).find('.sub_menu').hasClass('hide')){
      $(this).find('.sub_menu').removeClass('hide')
    }
    else {
      $(this).find('.sub_menu').addClass('hide')
    }
  });

  $('.check-all-piece-ignored').unbind('click')
  $(".check-all-piece-ignored").bind('click',function(e) {
    e.stopPropagation();

    if ($(this).is(':checked')){
      $(".check-piece-ignored").prop('checked', true);
    }
    else{
      $(".check-piece-ignored").prop('checked', false);
    }
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