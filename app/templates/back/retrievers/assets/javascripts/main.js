class AdminRetriever {
  constructor(){
    this.applicationJS      = new ApplicationJS;    
    this.retriever_filter_modal  = $('#filter-retriever');
  }

  load_events(){
    let self = this;

    $('.retrievers-filter').unbind('click').bind('click',function(e) {
      e.preventDefault();      

      self.retriever_filter_modal.modal('show');
    });

  }

  main() {
    this.load_events();    
  }
}

jQuery(function() {
  let retriever = new AdminRetriever();
  retriever.main();

  bind_globals_events();
});

