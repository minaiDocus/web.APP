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
      $('.modal .modal-footer .edit').remove()
      $('#integration').modal('show')
  });

  $('.action .sub_menu').livequery(function(){
    $('.sub_menu .edit').unbind('click')
    $(".sub_menu .edit").bind('click',function(e) {
        e.stopPropagation()
        alert('siora')
    });    
  })
});