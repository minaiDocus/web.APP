//= require '../application'

jQuery(function () {
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

  /* SCROLLING TO THE BOTTOM */
  $('.body_content').scroll(function() {
    let content_h  = $('.body_content').outerHeight();
    let content    = document.getElementsByClassName("body_content")[0];
    let c_position = content.scrollHeight - content.scrollTop

    if(content.scrollTop > 200)
      $('.scroll-on-top').show('slow');
    else
      $('.scroll-on-top').hide('slow');

    if(c_position == content_h)
      AppEmit('on_scroll_end');
  });
});