class AdminDematbox {
  constructor(){
    this.applicationJS    = new ApplicationJS;    
    this.dematbox_modal  = $('#filter-demat-file.modal');    
  }

  load_events(){
    let self = this;

    $('.filter-dematbox').unbind('click').bind('click',function(e) {
      e.preventDefault();      

      self.dematbox_modal.modal('show');
    }); 
  }

  main() {
    this.load_events();    
  }  
}

jQuery(function() {
  let dematbox = new AdminDematbox();
  dematbox.main();

  bind_globals_events();

  AppListenTo('show_dematbox', (e)=>{ if (e.detail.response.success) { window.location.href = e.detail.response.url } });
});