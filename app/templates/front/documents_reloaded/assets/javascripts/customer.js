//= require './events'
//= require './tags'
//= require './uploader'

class DocumentsReloadedCustomer{
  constructor(){
    this.applicationJS   = new ApplicationJS();
    this.edit_tags_modal = $('#tags-edit');

    this.ajax_params =  {
                      'url': '/documents_reloaded',
                      'type': 'GET',
                    }
  }

  load_temp_documents(serialize_form=false, load_rubric=false, load_customer=false){
    if(this.action_locker)
      return false

    this.action_locker = true;
    let data       = [];
    let journal_id = $('#hidden-journal-id').val();
    let advanced_search    = $('#form_' + journal_id);
    let form_serialization = '';

    //PARSE PREVIOUS SEARCH
    if(load_rubric)
    {
      $('#customer_filter_form')[0].reset();
      let datas = JSON.parse(advanced_search.val() || '[]');

      datas.forEach(function(data){
        $('#customer_filter_form #' + data['name']).val(data['value']);
      });
    }

    if(serialize_form || load_rubric){
      form_serialization = encodeURIComponent($('#customer_filter_form').serialize());
      advanced_search.val(JSON.stringify($('#customer_filter_form').serializeArray()));
    }
    else
    {
      let selector   = "#customer_filter_form input, #search_input";
      $(selector).not('.operator').val('');      
      if (!load_rubric)
        advanced_search.val('');
    }

    data.push(`${decodeURIComponent(form_serialization)}`);

    if(this.page > 1){ data.push(`page=${this.page}`) }

    data.push( 'uid=' + $('#customers').val() );

    if (!load_customer)
      data.push( 'journal_id=' + $('#hidden-journal-id').val() );

    this.ajax_params['data'] = data.join('&');

    this.applicationJS.sendRequest(this.ajax_params, function(){ $('#more-filter.modal').modal('hide'); })
                       .then((e)=>{
                          if (load_customer){
                            $(".customer-document-content").html($(e).find(".customer-document-content").html());

                            $("#hidden-journal-id").val($('.rubric').first().data('id'));
                            $("#hidden-customer-id").val($('#customers').val());

                            $('select#file_code_customer').val($('#customer_code').val()).trigger("chosen:updated");
                            $('select#file_code_customer').change();
                          }
                          else{
                            $('.box#table_pieces').html($(e).find(".box#table_pieces").html());
                          }

                          $('select#l_journal').val(journal_id).trigger("chosen:updated");

                          if ( $('.filter_active').length > 0 ){
                            $('.filter-info').removeClass('hide');
                          }
                          else{
                            $('.filter-info').addClass('hide');
                          }
                          bind_all_events();
                          this.action_locker = false;
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

  AppListenTo('refresh_customer_view', (e)=>{ setTimeout(()=>{ window.location.reload(true) }, 2000);    });

  AppListenTo('documents_load_datas', (e)=>{ main.load_temp_documents(true); });
  AppListenTo('documents_reinit_datas', (e)=>{ main.load_temp_documents(false); });

  AppListenTo('documents_search_text', (e)=>{ main.load_temp_documents(true); });
  AppListenTo('load_rubric', (e)=>{ main.load_temp_documents(false, true); });
  AppListenTo('load_customer', (e)=>{ main.load_temp_documents(false, false ,true); });
});