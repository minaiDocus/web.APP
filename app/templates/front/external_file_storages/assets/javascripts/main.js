//= require './events'

class EFSMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
  }

  update_storage(class_name){
    let data = this.applicationJS.serializeToJson( $(`.storage_form form.edit_${class_name}`) );
    let ajax_params = {
                        url: '/external_file_storage',
                        type: 'POST',
                        dataType: 'json',
                        data: data
                      }

    this.applicationJS.parseAjaxResponse(ajax_params)
  }

  use_service(service, is_used){
    if(is_used)
      $(".service_config_"+service).show();
    else
      $(".service_config_"+service).hide();

    let data = { service: service, is_enable: is_used }
    let ajax_params = {
                        url: '/external_file_storage/use',
                        type: 'POST',
                        dataType: 'json',
                        data: data
                      }

    this.applicationJS.parseAjaxResponse(ajax_params);

  }
}

jQuery(function() {
  let main = new EFSMain();

  AppListenTo('efs_update_storage', (e)=>{ main.update_storage(e.detail.class_name) });
  AppListenTo('efs_use_service', (e)=>{ main.use_service(e.detail.service, e.detail.is_used) });
});