function bind_all_events(){
  $('#delivery-date.daterange').daterangepicker({
    "autoApply": true,
    linkedCalendars: false,
    locale: {
      format: 'DD/MM/YYYY'
    }
  });

  $('#invoice-date.daterange').daterangepicker({
    "autoApply": true,
    linkedCalendars: false,
    locale: {
      format: 'DD/MM/YYYY'
    }
  });

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
    AppEmit('documents_show_preseizures_details', {'obj': this});
  });

  $('.add-document').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $('#add-document').modal("show");    
  });

  $('#more-filter .modal-footer .btn-add').unbind('click').bind('click', function(){ AppEmit('documents_load_datas'); });
  $('#more-filter .modal-footer .btn-reinit').unbind('click').bind('click', function(){ AppEmit('documents_reinit_datas'); });

  $('.search-content #search_input').unbind('keyup').bind('keyup', function(e){ if(e.key == 'Enter'){ /*e.keyCode == 13*/ AppEmit('documents_search_text'); } });

  $('.download_pack_archive').unbind('click').bind('click', function(){ AppEmit('download_pack_archive', {'obj': this}); });
  $('.download_pack_bundle').unbind('click').bind('click', function(){ AppEmit('download_pack_bundle', {'obj': this}); });

  $('.preseizures_export').unbind('click').bind('click',function(e) { AppEmit('documents_export_preseizures', {'obj': this}) });

  $('.update_tags').unbind('click').bind('click', function(){ AppEmit('documents_update_tags', {'obj': this}); });

  $('.delete_piece').unbind('click').bind('click', function(){ AppEmit('documents_delete_piece', {'obj': this}); });

  $('.edit_preseizures').unbind('click').bind('click', function(){ AppEmit('documents_edit_preseizures', {'obj': this}); });

  $('.deliver_preseizures').unbind('click').bind('click', function(){ AppEmit('documents_deliver_preseizures', {'obj': this}); });

  $('table.entries .content_amount').unbind('click').bind('click', function(){ AppEmit('documents_edit_entry_amount', {'obj': this}); });
  $('table.entries .content_account').unbind('click').bind('click', function(){ AppEmit('documents_edit_entry_account', {'obj': this}); });

  $('table.entries td.entry').mouseover(function(){ $(this).find('.content_amount span').show(); }).mouseout(function(){ $(this).find('.content_amount span').hide(); });
  $('table.entries .debit_or_credit').unbind('click').bind('click', function(){ AppEmit('documents_change_entry_type', {'obj': this}); });

  $(".zoom.pdf-viewer").unbind('click').bind('click', function(){ 
    var url = $(this).attr('data-content-url');
    
    $("#PdfViewerDialog .modal-body .view-content iframe.src-piece").attr("src", url);
    $("#PdfViewerDialog").modal('show');
  });
}

jQuery(function() {
  bind_all_events();
});