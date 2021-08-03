//= require '../application'

jQuery(function () {
  $(".body_content").scroll(function(e){
    var sTop = $(this).scrollTop();

    if (sTop > 200)
    {
      $('.scroll-on-top').show('slow');
    }
    else
    {
      $('.scroll-on-top').hide('slow');
    }
  });

  /* AS USER */
  $('a.as_user').unbind('click').bind('click', function(e){
    e.preventDefault();

    $('.as-user-with-overlay').show();    
    setTimeout(function(){$('.as-user-notification').slideDown('fast');}, 100);
  });

  $('.close_as_user_modal').unbind('click').bind('click', function(e){
    e.preventDefault();

    $('.as-user-notification').slideUp('fast');  
    setTimeout(function(){$('.as-user-with-overlay').hide();}, 300);
  });
  /* AS USER */

  /* SCROLL ON TOP */
  $('.scroll-on-top').unbind('click').bind('click', function(e){
    e.preventDefault();

    let body = $(".body_content");
    body.stop().animate({scrollTop:0}, 500, 'swing', function() {});
  });
});