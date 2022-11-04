//= require ckeditor/config

class AdminAccountSharing {
  constructor(){
    this.applicationJS      = new ApplicationJS;    
    this.account_sharing_filter_modal  = $('#filter-account-sharing');
  }

  load_events(){
    let self = this;

    $('.filter-account-sharing').unbind('click').bind('click',function(e) {
      e.preventDefault();      

      self.account_sharing_filter_modal.modal('show');
    });

  }

  main() {
    this.load_events();    
  }
}

jQuery(function() {
  let account = new AdminAccountSharing();
  account.main();

  bind_globals_events();

  AppListenTo('update_email_content', (e)=>{
    for ( instance in CKEDITOR.instances )
    {
      CKEDITOR.instances[instance].updateElement();
    }
  });
});

