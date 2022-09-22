
class AdminSubscription {
  constructor(){
    this.applicationJS       = new ApplicationJS;    
    this.subscription_modal  = $('#filter-subscription.modal');    
  }

  loadAccounts(type, renderer){
    $.ajax({
      url: "/admin/subscriptions/accounts",
      data: { type: type },
      type: "POST",
      success: function(data){
        renderer.find(".modal-body").html(data);
      },
      error: function(data){
        renderer.find(".modal-body").html("<p>Erreur lors du chargement des données, veuillez réessayer plus tard</p>");        
      }
    });
  }


  load_events(){
    let self = this;

    $('.filter-subscription').unbind('click').bind('click',function(e) {
      e.preventDefault();

      self.subscription_modal.modal('show');
    }); 

    $('a.do-showAccounts').unbind('click').bind('click', function(e){
      e.preventDefault();      

      let accountsDialog = $('#showAccounts');
      accountsDialog.find('h3').text($(this).attr('title'));
      accountsDialog.find(".modal-body").html("<span class='loading'>Chargement en cours ...</span>");
      accountsDialog.modal('show');
      self.loadAccounts($(this).attr('type'), accountsDialog);
    });
  }

  main() {
    this.load_events();    
  }  
}

jQuery(function() {
  let subscription = new AdminSubscription();
  subscription.main();

  bind_globals_events();

  AppListenTo('show_subscription', (e)=>{ if (e.detail.response.success) { window.location.href = e.detail.response.url } });
});