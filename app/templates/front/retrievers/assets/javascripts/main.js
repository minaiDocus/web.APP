//=require './events'

class RetrieverMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
    this.action_locker = false;
    this.account_select = $('#account_id');
    this.search_name    = $('#filter-retriever #search_name');
    this.search_state   = $('#filter-retriever #search_state');
    this.page = 1;
  }

  load_retrievers(target_page='one'){
    if(this.action_locker)
      return false;

    this.action_locker = true;
    let params = [];

    if(target_page == 'next_page' && this.page > 0)
      this.page += 1
    else if(target_page == 'one')
      this.page = 1

    if(this.page < 0){ 
      this.action_locker = false;
      return false
    }

    params.push(`page=${this.page}`)
    params.push(`account_id=${this.account_select.val()}`);

    if(this.search_name.val()){ params.push(`name=${encodeURIComponent(this.search_name.val())}`) }
    if(this.search_state.val()){ params.push(`state=${this.search_state.val()}`) }

    let ajax_params =   {
                          'url': `/retrievers?${params.join('&')}`,
                          'dataType': 'html',
                          'target': (this.page == 1)? '.retrievers-list' : ''
                        };

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((e)=>{
                        if(this.page > 1)
                        {
                          if($(e).find('.no-data-found').length == 0){
                            $('.total-count').text($(e).find('.total-count').text());
                            $('.retrievers-list').append( $(e).find('.retrievers-list').html() );
                          }
                          else{
                            this.page = -1
                          }
                        }

                        this.action_locker = false;
                        bind_all_events();
                      })
                      .catch(()=>{ this.action_locker = false; });
  }
}

jQuery(function() {
  let main = new RetrieverMain();

  AppListenTo('retriever_reload_all', (e)=>{ main.load_retrievers('one'); });
  AppListenTo('on_scroll_end', (e)=>{ main.load_retrievers('next_page'); });
});