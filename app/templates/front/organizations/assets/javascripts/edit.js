console.log('aaa')
jQuery(function () {
  /* Général */ 
  $('.valid-modification').unbind('click');
  $(".valid-modification").bind('click', function(e) {
    e.stopPropagation();
    $('#general-modal').modal('show');
    $('#general-modal button.valid').unbind('click');
    $('#general-modal button.valid').bind('click', function(event) {
      event.stopPropagation();
      console.log("AV....");
      $('form#edit-organization').submit();
    });
  });
  /* Général */

  /* Nommage PDF */
  $('#sortable').sortable({
    items: "li.btn-light.active",
    start: function(event, ui) {      
      ui.item.unbind("click");
    },
    stop: function(event, ui) {      
      ui.item.bind('click', function(){});  
    }
  });
  $('#element-separator').multiSelect();


  $('li.btn-light.click').unbind('click');
  $('li.btn-light.click').on('click',function(e) {
      e.preventDefault();
      $(this).hasClass('active') ? $(this).removeClass('active') : $(this).addClass('active');
  })
  /* Nommage PDF */


  /* Email rappel */
  $('.action.sub_integration').unbind('click');
  $(".action.sub_integration").bind('click',function(e) {
    e.stopPropagation();

    if ($(this).parent().find('div.sub_menu').length > 0){
      $(this).parent().find('div.sub_menu').remove();
    }
    else {
      if ($('.action .sub_menu').length > 0){
        $('.action .sub_menu').remove();
      }

      $(this).append($('.sub_integration_append').html());
    }
  });

  $('.new-mail-rappel').unbind('click');
  $(".new-mail-rappel").bind('click',function(e) {
      e.stopPropagation();
      $('#mail-rappel-modal').modal('show');
  });
  /* Email rappel */

  /* Logiciel Compta */
  $('#piece-name-edit').unbind('click');
  $("#piece-name-edit").bind('click',function(e) {
    e.stopPropagation();
    $('#softwares-piece-modal').modal('show');
  });


  $('#preseizure-name-edit').unbind('click');
  $("#preseizure-name-edit").bind('click',function(e) {
    e.stopPropagation();
    $('#softwares-preseizure-modal').modal('show');
  });

  $('#sortable-software').sortable({
    items: "li.btn-light",
    start: function(event, ui) {      
      ui.item.unbind("click");
    },
    stop: function(event, ui) {      
      ui.item.bind('click', function(){});  
    }
  });

  $('#sortable-software-preseizures').sortable({
    items: "li.btn-light",
    start: function(event, ui) {      
      ui.item.unbind("click");
    },
    stop: function(event, ui) {      
      ui.item.bind('click', function(){});  
    }
  });
  /* Logiciel Compta */
});