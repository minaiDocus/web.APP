//= require jquery
//= require searchable-option-list

jQuery(function() {
  $('#state_piece').multiSelect({
    'noneText': 'Séléctionner état',
    'allText': 'Tous séléctionnés'
  });  

  $('#delivery').multiSelect({
    'noneText': 'Séléctionner statut',
    'allText': 'Tous séléctionnés'
  });  

  $('#compare').multiSelect({
    'noneText': 'Choisir filre montant',
    'allText': 'Tous séléctionnés'
  });

  $('#delivery-date.datepicker').datepicker();
  $('#invoice-date.datepicker').datepicker();  

  $('.more-filter').unbind('click');
  $('.more-filter').bind('click',function(e) {
    e.stopPropagation();
    $('#more-filter').modal('show');
  });

  $('.select-all').unbind('click');
  $('.select-all').bind('click',function(e) {
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

  $('.select-document').unbind('click');
  $('.select-document').bind('click',function(e) {
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

  $('.more-filter').unbind('click');
  $('.more-filter').bind('click',function(e) {
    e.stopPropagation();
    $('#more-filter').modal('show');
  });

  $('.change-view').unbind('click');
  $('.change-view').bind('click',function(e) {
    e.stopPropagation();
    if($('.to-list').is(':visible')){
      $('.to-list').addClass('hide');
      $('.to-grid').removeClass('hide');

      $('.list').removeClass('hide');
      $('.grid').addClass('hide');
    }
    else{
      $('.to-list').removeClass('hide');
      $('.to-grid').addClass('hide');

      $('.list').addClass('hide');
      $('.grid').removeClass('hide');
    }
  });


  $('.list .stamp-content').unbind('click');
  $('.list .stamp-content').bind('click',function(e) {
    e.stopPropagation();
    if ($(this).hasClass('active')){
      $(this).removeClass('active');

      if ($('.list .stamp-content.active').length == 0) {
        $('.action-selected-hide').removeClass('hide');
        $('.action-selected').addClass('hide');
      }
    }
    else
    {
      $(this).addClass('active');

      if ($('.list .stamp-content.active').length > 0) {
        $('.action-selected-hide').addClass('hide');
        $('.action-selected').removeClass('hide');
      }
    }
  });

  $('.list .stamp-content').unbind('dblclick');
  $('.list .stamp-content').bind('dblclick',function(e) {
    e.stopPropagation();
    $('#view-document-content .modal-body').html($('#document_1').clone().removeClass('hide').html());
    $('#view-document-content .modal-body .for-dismiss-modal').html($('.dismiss-modal').clone().removeClass('hide').html());
    $('#view-document-content').modal('show');
  });

  $('.add-document').unbind('click');
  $('.add-document').bind('click',function(e) {
    e.stopPropagation();
    $('#add-document').modal("show");    
  });

  $('#customer_code').multiSelect({
    'noneText': 'Séléctionner état',
    'allText': 'Tous séléctionnés'
  });  

  $('#book-type').multiSelect({
    'noneText': 'Séléctionner statut',
    'allText': 'Tous séléctionnés'
  });  

  $('#periods').multiSelect({
    'noneText': 'Choisir filre montant',
    'allText': 'Tous séléctionnés'
  });
});