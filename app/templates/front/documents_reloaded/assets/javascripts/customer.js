//= require './events'
//= require './tags'

class DocumentsReloadedCustomer{
  constructor(){
    this.applicationJS   = new ApplicationJS();
    this.edit_tags_modal = $('#tags-edit');

    this.ajax_params =  {
                      'url': '/documents_reloaded',
                      'type': 'GET',
                    }
  }

  load_temp_documents(serialize_form=false){
    if(this.action_locker)
      return false

    this.action_locker = true;
    let data = [];

    if(serialize_form){
      data.push($('#pack_filter_form').serialize().toString());
    }
    else
    {
      let selector = "#pack_filter_form input, #pack_filter_form select, #customer_document_filter, #journal_document_filter, #search_input";
      $(selector).not('.operator').val(''); data.push( `reinit=true` );
    }

    let search_pattern = $('.search-content #search_input').val();

    if(search_pattern && search_pattern != ''){ data.push(`text=${encodeURIComponent(search_pattern)}`); }
    if(this.page > 1){ data.push(`page=${this.page}`) }

    if ($('#customer_document_filter').val()){
      data.push( 'view=' + $('#customer_document_filter').val() )
    }

    if($('#journal_document_filter').val()){
      data.push( 'journal=' + $('#journal_document_filter').val() )
    }

    this.ajax_params['data'] = data.join('&');

    this.applicationJS.sendRequest(this.ajax_params, function(){ $('#more-filter.modal').modal('hide'); })
                       .then((e)=>{
                          $('.box#table_pieces').html($(e).find(".box#table_pieces").html());
                          bind_all_events();
                        })
                       .catch(()=>{ this.action_locker = false; });
  }
}

jQuery(function() {
  let main = new DocumentsReloadedCustomer();

  AppListenTo('journal.before_rubric_addition', (e)=>{
    let customer_id = $('#customers').val();
    let form        = $('#edit-rubric-form');
    let base_uri    = form.attr('base_uri');

    $('#edit-rubric-form').attr('action', `${base_uri.replace('cst_id', customer_id)}`);
  });

  AppListenTo('refresh_customer_view', (e)=>{ windows.location.reload });

  AppListenTo('documents_load_datas', (e)=>{ main.load_temp_documents(true); });
  AppListenTo('documents_reinit_datas', (e)=>{ main.load_temp_documents(false); });

  AppListenTo('documents_search_text', (e)=>{ main.load_temp_documents(true); window.location.replace(window.location.href);});
});