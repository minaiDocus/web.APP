//= require '../application'
//= require './router'

GLOBAL.BaseFront = class BaseFront extends ApplicationJS {
  constructor(){
    super();
  }

  async getNotifications(){
    let self = this;
    let html = '';

    await this.getFrom("front/notifications").then((result)=>{
      html = result;
      window.setTimeout(function(){ $('.notif-badge').text(VARIABLES.get('notifications_length')); }, 1000);
    });

    return html;
  }
}

jQuery(function () {
  GLOBAL.router.initWindow();
});