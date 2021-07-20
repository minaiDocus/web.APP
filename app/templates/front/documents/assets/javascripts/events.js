function bind_all_events(){
  $('#delivery-date.datepicker').datepicker();
  $('#invoice-date.datepicker').datepicker();  

  $('.more-filter').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $('#more-filter').modal('show');
  });

  $('.select-all').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    if($(this).is(':checked')){
      $('.select-document').prop('checked', true);
      $('.action-selected-hide').addClass('hide');
      $('.action-selected').removeClass('hide');
    }
    else{
      $('.select-document').prop('checked', false);
      $('.action-selected-hide').removeClass('hide');
      $('.action-selected').addClass('hide');
    }    
  });

  $('.select-document').unbind('click').bind('click',function(e) {
    e.stopPropagation(); 
    if($(this).is(':checked')){
      $('.action-selected-hide').addClass('hide');
      $('.action-selected').removeClass('hide');

      $(this).closest('.box').addClass('border-green');
    }
    else
    {
      if ($('.select-all').is(':checked')) {$('.select-all').prop('checked', false);}
      $('.action-selected-hide').removeClass('hide');
      $('.action-selected').addClass('hide');

      $(this).closest('.box').removeClass('border-green');
    }    
  });

  $('.more-filter').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $('#more-filter').modal('show');
  });

  $('.change-view').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    if($('.to-list').is(':visible')){
      $('.to-list').addClass('hide');
      $('.to-grid').removeClass('hide');

      $('.grid').removeClass('hide');
      $('.list').addClass('hide');
    }
    else{
      $('.to-list').removeClass('hide');
      $('.to-grid').addClass('hide');

      $('.grid').addClass('hide');
      $('.list').removeClass('hide');
    }
  });

  $('.grid .stamp-content').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    if ($(this).hasClass('active')){
      $(this).removeClass('active');

      if ($('.grid .stamp-content.active').length == 0) {
        $('.action-selected-hide').removeClass('hide');
        $('.action-selected').addClass('hide');
      }
    }
    else
    {
      $(this).addClass('active');

      if ($('.grid .stamp-content.active').length > 0) {
        $('.action-selected-hide').addClass('hide');
        $('.action-selected').removeClass('hide');
      }
    }
  });

  $('.grid .stamp-content').unbind('dblclick').bind('dblclick',function(e) {
    e.stopPropagation();
    $('#view-document-content .modal-body').html($('#document_1').clone().removeClass('hide').html());
    $('#view-document-content .modal-body .for-dismiss-modal').html($('.dismiss-modal').clone().removeClass('hide').html());
    $('#view-document-content').modal('show');
  });

  $('.add-document').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $('#add-document').modal("show");    
  });

  $('.preseizures_export').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    VARIABLES.set('preseizures_export_params', { id: $(this).attr('data-id'), type: $(this).attr('data-type'), multi: ($(this).attr('data-multi') || false) });
    $('#preseizures_export').modal('show');
  });

  $('#more-filter .modal-footer .btn-add').unbind('click').bind('click', function(){ AppEmit('documents_load_datas'); });
  $('#more-filter .modal-footer .btn-reinit').unbind('click').bind('click', function(){ AppEmit('documents_reinit_datas'); });

  $('.search-content #search_input').unbind('keyup').bind('keyup', function(e){ if(e.key == 'Enter'){ /*e.keyCode == 13*/ AppEmit('documents_search_text'); } });

  $('.download_pack_archive').unbind('click').bind('click', function(){ AppEmit('download_pack_archive', {'obj': this}); });
  $('.download_pack_bundle').unbind('click').bind('click', function(){ AppEmit('download_pack_bundle', {'obj': this}); });
}

jQuery(function() {
  bind_all_events();

  $(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
      AppEmit('documents_next_page');
    }
  });
});