//= require '../application'

class Router extends ApplicationJS{
  constructor(){
    super();
  }

  initWindow(){
    this.parseJsVar();

    const query_string = window.location.search;
    const url_params = new URLSearchParams(query_string);
    let path = url_params.get('r');

    if(path)
      path = atob(path);
    else
      path = '/dashboard';

    this.handleClickedMenu();
    window.router.goTo(path); //Main page
  }

  handleClickedMenu() {
    $(".nav-item").unbind('click');
    $(".nav-item").bind('click', function (){
      $(".nav-item").removeClass("active");
      $(this).addClass("active");
    });
  }

  rebindGotoButtons(){
    $('a.goto_button').unbind('click.goto_button');
    $('a.goto_button').bind('click.goto_button', function(a){
      a.preventDefault();

      let url = $(this).attr('data-href');
      window.router.goTo(url);
    });
  }

  finalizeRedirection(url){
    window.router.parseJsVar();
    window.history.replaceState("target", "Title", url);
    window.setTimeout(window.router.rebindGotoButtons, 100);
  }

  goTo(url){
    this.getFrom(url)
        .then((html)=>{ $(".body_content").html(html); window.router.finalizeRedirection(url); })
        .catch((err)=>{ window.router.finalizeRedirection(url); })
  }
}

window.router = new Router();