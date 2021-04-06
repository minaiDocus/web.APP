class Router{
  constructor(){
  }

  rebind_goto_buttons(){
    $('a.goto_button').unbind('click');
    $('a.goto_button').bind('click', function(a){
      a.preventDefault();

      let url = $(this).attr('data-href');
      window.router.go_to(url);
    });
  }

  finalize_redirection(url){
    window.history.replaceState("target", "Title", url);
    window.setTimeout(window.router.rebind_goto_buttons, 100);
  }

  go_to(url, method='GET'){
    $.ajax({
      url: url,
      type: method,
      success: function(data){
        $(".body_content").html(data);

        window.router.finalize_redirection(url);
      },
      error: function(data){
        //TODO : personalize errors
        console.log(data);
        if(data.status == '404'){
          alert('404 : Tsy koboko oe aiza zany page zany a!!');
        }
        else
        {
          alert(`Misy blem ${data.status}!!`);
          $(".body_content").append('<span>'+ data.responseText + '</span>');
        }

        window.router.finalize_redirection(url);
      },
    });
  }
}

window.router = new Router()