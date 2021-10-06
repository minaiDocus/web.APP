function bind_all_events(){
  $('#customer_filter').multiSelect({
    "noneText": "Filtre par dossier"
  });

  $('li.reporting_links').unbind('click.reporting_view').bind('click.reporting_view', function(e){
    if( $(this).hasClass('statistics') && $(this).hasClass('need_refresh') && !$(this).hasClass('active') )
      AppEmit('reporting_load_statistics');

    $('li.reporting_links').removeClass('active');
    $(this).addClass('active');
  });

  $('.show-calendar').unbind('click').bind('click',function(e) {
    e.stopPropagation();    
    $('#'+$(this).attr('data-ref')).click();
  });

  $('#customer_filter').unbind('change').bind('change', function(e){ AppEmit('reporting_load_all'); });
  // $('#date_filter').unbind('change').bind('change', function(e){ AppEmit('reporting_load_all'); });
}

jQuery(function() {
  bind_all_events();
});
