//=require './events'

class RetrievedDatasMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
    this.action_locker = false;
    this.account_select = $('#account_id');
    this.opearations_page = 1;
    this.documents_page = 1;
  }

  load_all(){
    this.load_datas('operations');
    this.action_locker = false;
    this.load_datas('documents');
  }

  force_preseizures(){
    if(confirm('Voulez vous vraiment lancer la pré-afféctation des opérations'))
    {
      this.applicationJS.parseAjaxResponse({
        'url': '/retrieved/force_operations',
        'type': 'POST',
        'dataType': 'json',
      }).then((e)=>{ this.applicationJS.noticeFlashMessageFrom(null, e.message); });

      this.load_datas('operations');
    }
  }

  load_datas(type='operations', target_page='one'){
    if(this.action_locker)
      return false;

    this.action_locker = true;
    let params = [];
    var per_page = $(`.${type}.per-page`).val();

    if(target_page == 'next_page')
      this.page += 1
    else if(target_page == 'previous_page' && this.page > 1)
      this.page -= 1
    else if(target_page == 'one')
      this.page = 1

    if(this.page < 0){ 
      this.action_locker = false;
      return false
    }

    params.push(`page=${this.page}`)
    params.push(`account_id=${this.account_select.val()}`);

    if(per_page){ params.push(`per_page=${ per_page }`); }

    params.push($(`.modal #filter-${type}-form`).serialize().toString());

    let ajax_params =   {
                          'url': `/retrieved/${type}?${params.join('&')}`,
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
  let main = new RetrievedDatasMain();
  main.load_all();

  AppListenTo('retrieved_datas_reload_all', (e)=>{ main.load_all(); });
  AppListenTo('retrieved_datas_per_page', (e)=>{ main.load_datas(e.detail.type); });
  AppListenTo('retrieved_datas_previous_page', (e)=>{ main.load_datas(e.detail.type, 'previous_page'); });
  AppListenTo('retrieved_datas_next_page', (e)=>{ main.load_datas(e.detail.type, 'next_page'); });
  AppListenTo('retrieved_datas_force_preseizures', (e)=>{ main.force_preseizures(); });
  AppListenTo('retrieved_datas_filter', (e)=>{ $(`.modal#filter-${e.detail.type}`).modal('hide'); main.load_datas(e.detail.type); });
  AppListenTo('retrieved_datas_reset_filter', (e)=>{ $(`.modal#filter-${e.detail.type}`).modal('hide'); $(`.modal #filter-${e.detail.type}-form`)[0].reset(); main.load_datas(e.detail.type); });
});