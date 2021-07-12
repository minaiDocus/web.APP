//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require chart.min
//= require bootstrap
//= require searchable-option-list
//= require jquery.livequery.min

jQuery(function () {
  $(".principal li > span.link_principal").unbind('click');
  $(".principal li > span.link_principal").bind('click',function(e) {
    e.stopPropagation()
    $('.principal li span.link_principal').removeClass('active')
    $(this).parent().find('span.link_principal').addClass('active')
    if ($(this).parent().data('href') == "parametres"){
      $(this).parent().find('.chevron').toggle()
      $(this).parent().find('ul').slideToggle()
    }
    else if ($(this).parent().data('href') == "organization_home") {location.reload();}
    else{
      $(".organizations .content").html('');
      let url = '/organizations/'+$(this).parent().data('href')
      $.ajax({
        url: url, 
        type: "GET",        
        success: function(data){
          $(".organizations .content").html(data);
        }
      });
    }
  });
});