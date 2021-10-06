function bind_all_events(){
  $('#customer_filter').multiSelect({
    "noneText": "Filtre par dossier"
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
