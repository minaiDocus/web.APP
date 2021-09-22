function bind_all_events(){
  $('#delivery-date.daterange, #invoice-date.daterange').daterangepicker({     
    "autoApply": true,
    linkedCalendars: false,
    locale: {
      format: 'DD/MM/YYYY'
    }
  });

  $('#delivery-date.daterange, #invoice-date.daterange').val('');

  $('.more-filter').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $('#more-filter').modal('show');
  });

  $('.show-calendar').unbind('click').bind('click',function(e) {
    e.stopPropagation();    
    $('#'+$(this).attr('data-ref')).click();
  });

  $('.select-all').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    if($(this).is(':checked')){
      $('.select-document').prop('checked', true);
      $('.select-document').closest('.box').addClass('selected');
      $('.action-selected-hide').addClass('hide');
      $('.action-selected').removeClass('hide');
      $('.grid .stamp-content').addClass('selected');      
    }
    else{
      $('.select-document').prop('checked', false);
      $('.select-document').closest('.box').removeClass('selected');
      $('.action-selected-hide').removeClass('hide');
      $('.action-selected').addClass('hide');
      $('.grid .stamp-content').removeClass('selected');
    }    
  });

  $('.select-document').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    var piece_id = $(this).attr('data-id');

    if($(this).is(':checked')){
      $(this).closest('.box').addClass('selected');
      $('.grid .stamp-content#document_grid_' + piece_id).addClass('selected');
    }else{
      if ($('.select-all').is(':checked')) { $('.select-all').prop('checked', false); }

      $(this).closest('.box').removeClass('selected');
      $('.grid .stamp-content#document_grid_' + piece_id).removeClass('selected');
    }

    if ($('.box.list.selected').length < 1) {
      $('.action-selected-hide').removeClass('hide');
      $('.action-selected').addClass('hide');
    }else{
      $('.action-selected-hide').addClass('hide');
      $('.action-selected').removeClass('hide');
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
    var piece_id = $(this).attr('id').split('_')[2];


    if ($(this).hasClass('selected')){
      $(this).removeClass('selected');
      $('.list-content #document_'+ piece_id).closest('.box').removeClass('selected');
      $('.list-content #document_'+ piece_id + ' input.select-document').prop('checked', false);
      if ($('.select-all').is(':checked')) {$('.select-all').prop('checked', false);}

      if ($('.grid .stamp-content.selected').length == 0) {
        $('.action-selected-hide').removeClass('hide');
        $('.action-selected').addClass('hide');
      }
    }
    else
    {
      $(this).addClass('selected');
      $('.list-content #document_'+ piece_id).closest('.box').addClass('selected');
      $('.list-content #document_'+ piece_id + ' input.select-document').prop('checked', true);

      if ($('.grid .stamp-content.selected').length > 0) {
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
  $('.search-content .glass svg').unbind('click').bind('click', function(e){ AppEmit('documents_search_text'); });

  $('.download_pack_archive').unbind('click').bind('click', function(){ AppEmit('download_pack_archive', {'obj': this}); });
  $('.download_pack_bundle').unbind('click').bind('click', function(){ AppEmit('download_pack_bundle', {'obj': this}); });

  $('.preseizures_export').unbind('click').bind('click',function(e) { AppEmit('documents_export_preseizures', {'obj': this}) });

  $('.update_tags').unbind('click').bind('click', function(){ AppEmit('documents_update_tags', {'obj': this}); });

  $('.edit_compta_analysis').unbind('click').bind('click', function(){ AppEmit('documents_edit_analysis', { 'code': $(this).data('code'), is_used: $(this).data('is-used') }); });

  $('.delete_piece').unbind('click').bind('click', function(){ AppEmit('documents_delete_piece', {'obj': this}); });
  $(".content-list-pieces-deleted .restore").unbind('click').bind('click', function(){ AppEmit('documents_restore_piece', { id: $(this).attr('data-piece-id') }); });

  $('.edit_preseizures').unbind('click').bind('click', function(){ AppEmit('documents_edit_preseizures', {'obj': this}); });

  $('.deliver_preseizures').unbind('click').bind('click', function(){ AppEmit('documents_deliver_preseizures', {'obj': this}); });

  $('table.entries .content_amount').unbind('click').bind('click', function(){ AppEmit('documents_edit_entry_amount', {'obj': this}); });
  $('table.entries .content_account').unbind('click').bind('click', function(){ AppEmit('documents_edit_entry_account', {'obj': this}); });

  $('table.entries td.entry').mouseover(function(){ $(this).find('.content_amount span.debit_or_credit').show(); }).mouseout(function(){ $(this).find('.content_amount span.debit_or_credit').hide(); });
  $('table.entries .debit_or_credit').unbind('click').bind('click', function(){ AppEmit('documents_change_entry_type', {'obj': this}); });

  $(".zoom.pdf-viewer").unbind('click').bind('click', function(){ 
    var url = $(this).attr('data-content-url');
    
    $("#PdfViewerDialog .modal-body .view-content iframe.src-piece").attr("src", url);
    $("#PdfViewerDialog").modal('show');
  });
}

jQuery(function() {
  bind_all_events();

  $(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() == $(document).height()) {
      AppEmit('documents_next_page');
    }
  });
});