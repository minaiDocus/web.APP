function bind_all_events(){
  $('select#account_id').unbind('change');
  $('select#account_id').bind('change', function(e){ AppEmit('retriever_parameters_reload_all') });

  $('.action.sub-menu-bank-param').unbind('click');
  $(".action.sub-menu-bank-param").bind('click',function(e) {
    e.stopPropagation();

    if ($(this).find('.sub_menu').hasClass('hide')){
      $(this).find('.sub_menu').removeClass('hide')
    }
    else {
      $(this).find('.sub_menu').addClass('hide')
    }
  });

  $('.create-manual-bank-account').unbind('click')
  $(".create-manual-bank-account").bind('click',function(e) {
    e.stopPropagation()

    $('#create-bank-account').modal('show');
  });

  $('.retriever-filter-others').unbind('click')
  $(".retriever-filter-others").bind('click',function(e) {
    e.stopPropagation()

    $('#filter-'+ $(".tab-pane.active").attr('id')).modal('show');
  });

  $('.sub-menu-bank-param li.edit').unbind('click');
  $(".sub-menu-bank-param li.edit").bind('click',function(e) {
    e.stopPropagation()

    $('#edit-bank-account').modal('show');
  });

  $('span.chevron-show').unbind('click');
  $('span.chevron-show').bind('click',function(e) {
    e.stopPropagation();
    var id = $(this).attr('id');
    
    if ($(this).children().hasClass('rotate')){      
      $(this).children().removeClass('rotate').addClass('rotate-reset');
      $('.more-'+id).hide('');
    }
    else{
      $(this).children().removeClass('rotate-reset').addClass('rotate');
      $('.more-'+id).show('');
    }
  });

  $('.modal#filter-banks-selection button.validate').unbind().bind('click', (e)=>{ AppEmit('retriever_parameters_filter_page', { target: 'banks-selection', action: 'validate'}); });
  $('.modal#filter-documents-selection button.validate').unbind().bind('click', (e)=>{ AppEmit('retriever_parameters_filter_page', { target: 'documents-selection', action: 'validate'}); });
  $('.modal#filter-banks-params button.validate').unbind().bind('click', (e)=>{ AppEmit('retriever_parameters_filter_page', { target: 'banks-params', action: 'validate'}); });

  $('.modal#filter-banks-selection button.cancel').unbind().bind('click', (e)=>{ AppEmit('retriever_parameters_filter_page', { target: 'banks-selection', action: 'reset'}); });
  $('.modal#filter-documents-selection button.cancel').unbind().bind('click', (e)=>{ AppEmit('retriever_parameters_filter_page', { target: 'documents-selection', action: 'reset'}); });
  $('.modal#filter-banks-params button.cancel').unbind().bind('click', (e)=>{ AppEmit('retriever_parameters_filter_page', { target: 'banks-params', action: 'reset'}); });

}

jQuery(function() {
  bind_all_events();
});