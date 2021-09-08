//= require './events'

class ProfilesMain{
  constructor(){
    this.applicationJS= new ApplicationJS();
  }

  change_password(){
    let data = SerializeToJson( $('.modal#change-password').find('form.edit_user') );
    let ajax_params = {
                        url: '/profiles',
                        type: 'PUT',
                        dataType: 'json',
                        data: data,
                      }
    this.applicationJS.parseAjaxResponse(ajax_params).then((e)=>{ $('.modal#change-password').modal('hide'); })
  }

  change_notifications(){
    let data = SerializeToJson( $('form#subscription_options') );
    let ajax_params = {
                        url: '/profiles',
                        type: 'PUT',
                        dataType: 'json',
                        data: data,
                      }
    this.applicationJS.parseAjaxResponse(ajax_params);
  }
}


jQuery(function() {
  let main = new ProfilesMain();

  AppListenTo('profiles_change_password', (e)=>{ main.change_password(); });
  AppListenTo('profiles_change_notifications', (e)=>{ main.change_notifications(); });
});