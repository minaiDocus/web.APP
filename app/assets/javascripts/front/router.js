class Router{
  constructor(){
    this.parseJsVar();
  }

  parseJsVar(){
    window.GLOBALS = {}

    $('span.js_var_setter').each(function(e){
      let name  = $(this).attr('id').replace('js_var_', '').trim();
      let value = $(this).text().trim();

      window.GLOBALS[name] = atob(value);
    });
  }

  init_window(){
    this.parseJsVar();

    const query_string = window.location.search;
    const url_params = new URLSearchParams(query_string);
    let path = url_params.get('r');

    if(path)
      path = atob(path);
    else
      path = '/dashboard';

    window.router.go_to(path); //Main page
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
    window.router.parseJsVar();
    window.history.replaceState("target", "Title", url);
    window.setTimeout(window.router.rebind_goto_buttons, 100);
  }

  go_to(url){
    $.ajax({
      url: url,
      header: { Accept: 'application/html' },
      data: { xhr_token: window.GLOBALS.XHR_TKN },
      type: 'GET',
      success: function(data){
        $(".body_content").html(data);

        window.router.finalize_redirection(url);
      },
      error: function(data){
        //TODO : personalize errors
        if(data.status == '404')
        {
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