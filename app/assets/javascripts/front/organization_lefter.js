jQuery(function () {
  $(".principal li span.link_principal, .principal .slave li span.link_slave").unbind('click.lefter').bind('click.lefter',function(e) {
    $('.principal li span.link_principal, .principal li span.link_slave').removeClass('active');
    $(this).addClass('active');
    if ($(this).parent().data('href') == "parametres"){
      $(this).parent().find('.chevron').toggle();
      $(this).parent().find('ul').slideToggle();
      $('.principal li span.link_slave').removeClass('active');
      $(this).addClass('active');
    }
    else{
      $(".organizations .content").html('');
      if ($(this).hasClass('link_slave')){
        $('.parameters').addClass('active');
      }
    }
  });
});