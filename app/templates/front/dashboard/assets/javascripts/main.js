//= require jquery
//= require searchable-option-list

jQuery(function() {
  $('#select-customer-to-favorite').searchableOptionList();

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

  $('#add-customer-to-favorite.btn-add').unbind('click');
  $('#add-customer-to-favorite.btn-add').bind('click',function(e) {
    e.stopPropagation();
    if ($('#select-customer-to-favorite option:selected').length > 0){
      $(this).attr('disabled', true);
      $.ajax({
        url: '/dashboard/add_customer_to_favorite',        
        type: 'POST',
        success: function (data) {
          $('.my-favorite-customers').html(data);
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

          $('.notice-internal-success').show('');          
          setTimeout(function(){$('.notice-internal-success').fadeOut('');}, 5000);
          $('#add-to-favorite').modal('hide');
        }
      });
      $(this).attr('disabled', false);
    }
    else{
      // To delete
      $('.notice-internal-error').show('');
      $('#add-to-favorite').modal('hide');
    }
  });
});