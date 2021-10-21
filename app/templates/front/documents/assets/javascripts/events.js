function bind_all_events(){
  $('#delivery-date.daterange, #invoice-date.daterange').val('');

  $('#customer_document_filter').multiSelect({
    "noneText": "Choix de(s) dossier(s)",
    "maxHeight": "300px",
  });

  $('#journal_document_filter').multiSelect({
    "noneText": "Choix journaux",
    "maxHeight": "300px",
  });

  $('#customer_document_filter').unbind('change').bind('change', function(e){
    let lists        = JSON.parse( $('.user_and_journals').val() );
    let current_code = $(this).val();

    if(current_code !== null && current_code !== undefined && current_code.length > 0){
      $('#journal_document_filter option').addClass('hide');
      $('#journal_document_filter').parent().find('.multi-select-container .multi-select-menuitem').addClass('hide');
      current_code.forEach((code)=>{
        let found_result = lists.find((e)=>{ return e.user == code })
        if(found_result){
          found_result.journals.forEach((journal)=>{ 
            $(`#journal_document_filter option[value=${journal}]`).removeClass('hide');
            $('#journal_document_filter').parent().find(`.multi-select-container .multi-select-menuitem input[value=${journal}]`).parent().removeClass('hide');
          });
        }
      })
    }else{
      $('#journal_document_filter option').removeClass('hide');
      $('#journal_document_filter').parent().find('.multi-select-container .multi-select-menuitem').removeClass('hide');
    }
  })

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

  $('.filter-customer-journal').unbind('click').bind('click', function(e){ AppEmit('document_customer_filter'); });

  $('.to-filter').unbind('click').bind('click', function(e){ $('#badge-filter').val($(this).attr('id')); AppEmit('filter_pack_badge'); });

  $('.grid .stamp-content').unbind('dblclick').bind('dblclick',function(e) {
    e.stopPropagation();
    AppEmit('documents_show_preseizures_details', {'obj': this});
  });

  $('.add-document').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $('#add-document').modal("show");    
  });

  $('#more-filter .modal-footer .btn-add').unbind('click').bind('click', function(){ AppEmit('documents_load_datas'); });
  $('.btn-reinit').unbind('click').bind('click', function(){ AppEmit('documents_reinit_datas'); });

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

  $(".more-result").unbind('click').bind('click', function(e){ $(this).hide('fast'); AppEmit('documents_next_page'); })
}

jQuery(function() {
  AppListenTo('window.application_auto_rebind', (e)=>{ bind_all_events() });

  /* SCROLLING TO THE BOTTOM */
  var end_reached = true;
  $('.body_content').scroll(function() {
    let content_h  = $('.body_content').outerHeight();
    let content    = document.getElementsByClassName("body_content")[0];
    let c_position = content.scrollHeight - content.scrollTop

    const show_hide_more_result = (action)=>{
      if(action == 'show'){
        //if(VARIABLES.get('has_next_page') !== false);
        $('.more-result').show('fast');
      }else{
        // $('.more_result_button').hide('slow');
        $('.more-result').hide('fast');
      }
    }

    // console.log("content_h : " + content_h);
    // console.log("c_pos : " + c_position);

    if( c_position >= (content_h + 75) ){
      end_reached = false
      show_hide_more_result('hide');
    }else if(!end_reached){
      end_reached = true;
      show_hide_more_result('show');
    }
  });
});