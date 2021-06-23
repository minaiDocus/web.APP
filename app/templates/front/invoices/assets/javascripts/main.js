jQuery(function () {
  $('.action.sub_facture').unbind('click')
  $(".action.sub_facture, .action.sub_integration").bind('click',function(e) {
      e.stopPropagation()
      sub_menu_class = ($(this).hasClass('sub_integration')) ? 'sub_integration' : 'sub_facture'

      if ($(this).parent().find('div.sub_menu').length > 0){
        $(this).parent().find('div.sub_menu').remove()
      }
      else {
        if ($('.action .sub_menu').length > 0){
          $('.action .sub_menu').remove()
        }

        $(this).append($('.'+ sub_menu_class +'_append').html())
        $('.sub_menu .edit').unbind('click')
        $(".sub_menu .edit").bind('click',function(e) {
            e.stopPropagation()
            alert('siora')
        });
      }
    });

  $('.parameter').unbind('click')
  $(".parameter").bind('click',function(e) {
      e.stopPropagation()
        $('#select-customer').multiSelect({
          'noneText': 'Selectionner/Rechercher un dossier client'
        });
        $('#select-document').multiSelect({
          'noneText': 'Selectionner le type de document'
        });
      $('.modal .modal-footer .edit').remove();
      $('#integration').modal('show')
  });

  $('.commande').unbind('click')
  $(".commande").bind('click',function(e) {
      e.stopPropagation()
      $('#select-kit').searchableOptionList({
        'searchplaceholder': 'Selectionner / Rechercher un dossier client à qui envoyer un kit courrier'
      });

      $('#commande-courrier').modal('show')
  });
});