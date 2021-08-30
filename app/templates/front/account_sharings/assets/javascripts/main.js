//=require './events'

class AccountSharingsMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
  }

  account_sharings_new(){
    let data = this.applicationJS.serializeToJson( $(`.modal#account-sharing-new form#new_user`) );
    let ajax_params = {
                        url: '/account_sharings',
                        type: 'POST',
                        dataType: 'json',
                        data: data
                      }

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((e)=>{
                        try{
                          if(!e.json_flash.error){
                            this.finalize_action( $('.modal#account-sharing-new') );
                          };
                        }catch(a){
                          this.finalize_action( $('.modal#account-sharing-new') );
                        };
                      });
  }

  account_sharings_new_request(){
    let data = this.applicationJS.serializeToJson( $(`.modal#account-sharing-new-request form#new_account_sharing_request`) );
    let ajax_params = {
                        url: '/account_sharings/create_request',
                        type: 'POST',
                        dataType: 'json',
                        data: data
                      }

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((e)=>{
                        try{
                          if(!e.json_flash.error){
                            this.finalize_action( $('.modal#account-sharing-new-request') );
                          };
                        }catch(a){
                          this.finalize_action( $('.modal#account-sharing-new-request') ); 
                        };
                      });
  }

  finalize_action(modal){
    modal.modal('hide');
    window.location.href = '/profiles';
  }
}

jQuery(function() {
  let main = new AccountSharingsMain();

  AppListenTo('account_sharings_new', (e)=>{ main.account_sharings_new() });
  AppListenTo('account_sharings_new_request', (e)=>{ main.account_sharings_new_request() });
});