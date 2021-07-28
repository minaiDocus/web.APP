//=require './events'

class RetrieverMain{
  constructor(){
    this.account_select = $('#account_id');
    this.search_name    = $('#filter-retriever #search_name');
    this.search_state   = $('#filter-retriever #search_state');
    this.applicationJS = new ApplicationJS();
    this.page = 1;
  }

  load_retrievers(target_page='one'){
    let params = [];

    if(target_page == 'next_page' && this.page > 0)
      this.page += 1
    else if(target_page == 'one')
      this.page = 1

    if(this.page < 0){ return false }

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
                        $('.total-count').text($(e).find('.total-count').text());

                        if(this.page > 1)
                        {
                          if($(e).find('.no-data-found').length == 0)
                            $('.retrievers-list').append( $(e).find('.retrievers-list').html() );
                          else
                            this.page = -1
                        }

                        bind_all_events();
                      });
  }
}

jQuery(function() {
  let main = new RetrieverMain();

  AppListenTo('retriever_reload_all', (e)=>{ main.load_retrievers('one'); });

  $(window).scroll(function() {
    if($(window).scrollTop() + $(window).height() >= $(document).height()) {
      main.load_retrievers('next_page');
    }
  });
});