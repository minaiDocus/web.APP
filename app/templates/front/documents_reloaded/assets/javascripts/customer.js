//= require './events'

class DocumentsReloadedCustomer{
  constructor(){
    this.applicationJS = new ApplicationJS();
    this.action_locker = false;
    this.page = 1;
    this.ajax_params = {};

    this.export_params = {};
  }

  load_datas(serialize_form=false, append=false){
    if(this.action_locker)
      return false

    if(!append)
      this.page = 1;

    this.action_locker = true;
    let data = [];

    if(serialize_form){
      data.push($('#pack_filter_form').serialize().toString());
      if(!append)
        data.push(`activate_filter=true`);
    }
    else
    {
      let selector = "#pack_filter_form input, #pack_filter_form select, #customer_document_filter, #journal_document_filter, #search_input";
      $(selector).not('.operator').val(''); data.push( `reinit=true` );
    }

    let search_pattern = $('.search-content #search_input').val();

    if(search_pattern && search_pattern != ''){ data.push(`text=${encodeURIComponent(search_pattern)}`); }
    if(this.page > 1){ data.push(`page=${this.page}`) }

    data.push(`grid_or_list_view=${'list'}`)

    if ($('#customer_document_filter').val()){
      data.push( 'view=' + $('#customer_document_filter').val() )
    }

    if($('#journal_document_filter').val()){
      data.push( 'journal=' + $('#journal_document_filter').val() )
    }

    if($('#badge-filter').val()){
      data.push( 'badge_filter=' + $('#badge-filter').val() )
    }

    this.ajax_params['target'] = (append)? null : '.main-content';
    this.ajax_params['data']   = data.join('&');

    this.applicationJS.sendRequest(this.ajax_params, function(){ $('#more-filter.modal').modal('hide'); })
                       .then((e)=>{
                          if(append){
                            if($(e).find('.no-data-found').length > 0){
                              this.applicationJS.noticeSuccessMessageFrom(null, 'Plus aucun résultat!');
                              this.page = -1;
                            }else{
                              $('.all-results').append($(e).find('.all-results').html());
                            }
                          }

                          this.action_locker = false
                          bind_all_events();
                        })
                       .catch(()=>{ this.action_locker = false; });
  }
}

jQuery(function() {
  let main = new DocumentsReloadedCustomer();

  main.load_datas();

  AppListenTo('journal.before_rubric_addition', (e)=>{
    let customer_id = $('#customer_document').val();
    let form        = $('#edit-rubric-form');
    let base_uri    = form.attr('base_uri');

    $('#edit-rubric-form').attr('action', `${base_uri.replace('cst_id', customer_id)}`);
  }); 

  AppListenTo('refresh_customer_view', (e)=>{ main.load_customers_view(); })
});