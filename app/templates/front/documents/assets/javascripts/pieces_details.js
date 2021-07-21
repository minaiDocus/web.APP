//= require './main'

class DocumentsDetails extends DocumentsMain{
  constructor(){
    super();

    this.pack_id = $('#current_pack').attr('data-id');
    this.ajax_params =  {
                          'url': `/documents/${this.pack_id}`,
                          'type': 'GET',
                        }
  }

  load_pieces(serialize_form=false, append=false){
    this.load_datas(serialize_form, append);
  }
}


jQuery(function() {
  let main = new DocumentsDetails();

  AppListenTo('documents_load_datas', (e)=>{ main.load_pieces(true) });
  AppListenTo('documents_reinit_datas', (e)=>{ main.load_pieces(false) });

  AppListenTo('documents_search_text', (e)=>{ main.load_pieces(true); });

  AppListenTo('documents_next_page', (e)=>{ main.load_next_page(); });
});