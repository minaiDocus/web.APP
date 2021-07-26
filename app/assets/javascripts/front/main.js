//= require '../application'


jQuery(function () {  
  /* LOGIN */
  $('input.form-control').unbind('focusout');
  $('input.form-control').bind('focusout',function(e) {
    e.stopPropagation();

    if ($(this).val() != '')
    {
      $(this).removeClass('not-completed').addClass('completed');
    }
    else
    {
      $(this).removeClass('completed').addClass('not-completed');
    }

    if ($('.login #identification').val() != '' && $('.login #password').val() != '')
    {
      $('.btn.connexion').removeClass('btn-light-secondary').addClass('btn-primary');
    }
    else
    {
      $('.btn.connexion').removeClass('btn-primary').addClass('btn-light-secondary');
    }

    if ($('.login #email').val() != '')
    {
      $('.btn.valid').removeClass('btn-light-secondary').addClass('btn-primary');
    }
    else
    {
      $('.btn.valid').removeClass('btn-primary').addClass('btn-light-secondary');
    }

    if ($('#password').val() != ''){
      $('.see').removeClass('hide');
      $('.not-see').addClass('hide');
    }
    else
    {
      $('.not-see').removeClass('hide');
      $('.see').addClass('hide');
    }
  });

  $('.see').unbind('mouseover');
  $('.see').bind('mouseover',function(e) {
    e.stopPropagation();

    $('input#password').attr('type','text');
  }).bind('mouseout',function(e) {
    e.stopPropagation();

    $('input#password').attr('type','password');
  });

  /* LOGIN */

  /* AS USER */
  $('a.as_user').unbind('click').bind('click', function(e){
    e.preventDefault();

    $('.as-user-with-overlay').show();    
    setTimeout(function(){$('.as-user-notification').show('');}, 100);
  });

  $('.close_as_user_modal').unbind('click').bind('click', function(e){
    e.preventDefault();

    $('.as-user-notification').hide('');    
    setTimeout(function(){$('.as-user-with-overlay').hide();}, 200);
  });

  /* AS USER */
});