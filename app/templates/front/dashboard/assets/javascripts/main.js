//= require jquery
//= require searchable-option-list

function bind_favorite_clicks(){
  $('.favorite-link').unbind('click');
  $('.favorite-link').bind('click',function(e) {
    e.stopPropagation();
    var id = $(this).attr('id');
    
    if ($(this).children().hasClass('rotate')){      
      $(this).children().removeClass('rotate').addClass('rotate-reset');
      $('#details_'+id).hide('');
    }
    else{
      $(this).children().removeClass('rotate-reset').addClass('rotate');
      $('#details_'+id).show('');
    }    
  });
}

jQuery(function() {
  let applicationJS = new ApplicationJS();

  $('#select-customer-to-favorite').searchableOptionList();
  bind_favorite_clicks();

  $('#add-customer-to-favorite.btn-add').unbind('click').bind('click',function(e) {
    e.stopPropagation();
    $(this).attr('disabled', true);

    let params =  {
                    'url': '/dashboard/add_customer_to_favorite',
                    'type': 'POST',
                    'data': $('#send_customer_to_favorite').serialize(),
                    'target': '#container-box',
                  }
    applicationJS.parseAjaxResponse(params, function(){ $('#add-to-favorite').modal('hide'); }, bind_favorite_clicks);

    $(this).attr('disabled', false);
  });
});