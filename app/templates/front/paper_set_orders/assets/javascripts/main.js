jQuery(function () {
  $('.commande-kit').unbind('click')
  $(".commande-kit").bind('click',function(e) {      
    e.stopPropagation();

    $('#select-kit').searchableOptionList({
      'searchplaceholder': 'Selectionner / Rechercher un dossier client à qui envoyer un kit courrier'
    });

    $('#commande-courrier').modal('show')
  });

  $('.action.sub-menu-box, .action.sub-menu-kit').unbind('click')
  $(".action.sub-menu-box, .action.sub-menu-kit").bind('click',function(e) {
    e.stopPropagation();

    if ($(this).find('.sub_menu').hasClass('hide')){
      $(this).find('.sub_menu').removeClass('hide')
    }
    else {
      $(this).find('.sub_menu').addClass('hide')
    }
  });

  $('.sub_menu li.edit').unbind('click');
  $('.sub_menu li.edit').bind('click', function(e){

    $('#kit-state').multiSelect({
      'noneText': 'Selectionner le statut'
    });

    $('#edit-kit-box').modal('show')
  });

  $('.sub_menu li.delete').unbind('click');
  $('.sub_menu li.delete').bind('click', function(e){

    $(this).closest('tr').remove();
  });
});