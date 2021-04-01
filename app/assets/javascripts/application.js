//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.livequery.min

//***GLOBALS***

// function bind_click(router){
//   $('a.goto_button').livequery(function(){
//     $('a.goto_button').unbind('click')
//     $('a.goto_button').bind('click', function(a){
//       a.preventDefault();

//       url = $(this).attr('data-href');
//       router.go_to(url);
//     });
//   });
// }

class Router{
  constructor(){
  }

  go_to(url, method='GET'){
    let me = this
    $.ajax({
      url: url,
      type: method,
      success: function(data){
        $(".body_content").html(data);
      }
    });
  }
}

jQuery(function () {
  router = new Router()
  router.go_to("/dashboard")

  $('a.goto_button').livequery(function(){
    $('a.goto_button').unbind('click')
    $('a.goto_button').bind('click', function(a){
      a.preventDefault();

      url = $(this).attr('data-href');
      router.go_to(url);
    });
  });
});