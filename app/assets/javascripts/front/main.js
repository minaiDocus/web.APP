//= require '../application'
//= require './router'

GLOBAL.BaseFront = class BaseFront extends ApplicationJS {
  constructor(){
    super();
  }

  getNotifications(){
    let self = this;

    this.getFrom("front/notifications", ".basefront_getnotifications").then((r)=>{
      self.parseJsVar();
      $('.notif-badge').text(VARIABLES.get('notifications_length'));
    });
  }
}

jQuery(function () {
  window.router.initWindow();
});
