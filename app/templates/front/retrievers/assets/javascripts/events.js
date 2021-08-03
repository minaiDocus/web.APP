function bind_all_events(){
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

  $('.retriever-filter').unbind('click')
  $(".retriever-filter").bind('click',function(e) {
    e.stopPropagation()

    $('#filter-retriever').modal('show');
  });

  $('.add-retriever').unbind('click')
  $(".add-retriever").bind('click',function(e) {
    e.stopPropagation()

    $('#add-retriever').modal('show');
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

  $('.list-retriever').unbind('click');
  $(".list-retriever").bind('click',function(e) {
    e.stopPropagation()

    $('#list-retrievers').modal('show');
  });

  $('select#account_id').unbind('change');
  $('select#account_id').bind('change', function(e){ AppEmit('retriever_reload_all') });

  $('#filter-retriever #filter_button').unbind('click');
  $('#filter-retriever #filter_button').bind('click', function(e){ $('#filter-retriever').modal('hide'); AppEmit('retriever_reload_all') });

  $('#filter-retriever #filter_cancel').unbind('click');
  $('#filter-retriever #filter_cancel').bind('click', function(e){ $('#filter-retriever').modal('hide'); $('#filter-retriever #search_name').val(''); $('#filter-retriever #search_state').val(''); AppEmit('retriever_reload_all') });
}

jQuery(function() {
  bind_all_events();
});