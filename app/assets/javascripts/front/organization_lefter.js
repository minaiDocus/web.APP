//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require chart.min
//= require bootstrap
//= require searchable-option-list
//= require jquery.livequery.min

jQuery(function () {
  $(".principal li > span.link_principal, .principal .slave li > span.link_slave").unbind('click');
  $(".principal li > span.link_principal, .principal .slave li > span.link_slave").bind('click',function(e) {
    e.stopPropagation();
    $('.principal li span.link_principal').removeClass('active');
    $(this).parent().find('span.link_principal').addClass('active');
    if ($(this).parent().data('href') == "parametres"){
      $(this).parent().find('.chevron').toggle();
      $(this).parent().find('ul').slideToggle();
      $('.principal li span.link_slave').removeClass('active');
    }
    else{
      $(".organizations .content").html('');
      if ($(this).hasClass('link_slave')){
        $('.parameters').addClass('active')
      }
    }
  });
});