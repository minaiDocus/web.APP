//=require './events'

class RetrievedParametersMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
    this.action_locker = false;
    this.account_select = $('#account_id');
    this.per_page_of = { 'documents-selection': 20 };
  }

  load_all(){
    this.load_datas('banks-selection');
    this.action_locker = false;
    this.load_datas('documents-selection');
    this.action_locker = false;
    this.load_datas('banks-params');
  }

  filter_page(type, action='validate'){
    if(action == 'reset')
      $(`.modal form#filter-${type}-form`)[0].reset();

    this.load_datas(type);
    $(`.modal#filter-${type}`).modal('hide');
  }

  load_datas(type='banks-selection', page=1, per_page=0){
    if(this.action_locker)
      return false;

    this.action_locker = true;
    let params = [];

    if(per_page > 0)
      this.per_page_of[type] = per_page;

    params.push(`page=${page}`);
    params.push(`account_id=${this.account_select.val()}`);

    if(this.per_page_of[type] > 0){ params.push(`per_page=${ this.per_page_of[type] }`); }

    params.push($(`.modal form#filter-${type}-form`).serialize().toString());

    let ajax_params =   {
                          'url': `/retriever/${type.replaceAll('-', '_')}?${params.join('&')}`,
                          'dataType': 'html',
                          'target': ''
                        };

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((html)=>{
                        $(`.tab-pane#${type}`).html(html);
                        $(`span#total-${type}`).text( $(`input#${type}-size`).val() );

                        this.action_locker = false;
                        bind_all_events();
                      })
                      .catch(()=>{ this.action_locker = false; });
  }
}


jQuery(function() {
  let main = new RetrievedParametersMain();
  main.load_all();

  AppListenTo('retriever_parameters_filter_page', (e)=>{ main.filter_page(e.detail.target, e.detail.action); });
  AppListenTo('retriever_parameters_reload_all', (e)=>{ main.load_all(); });

  AppListenTo('window.change-per-page', (e)=>{ main.load_datas(e.detail.name, 1, e.detail.per_page); });
  AppListenTo('window.change-page', (e)=>{ main.load_datas(e.detail.name, e.detail.page); });
});