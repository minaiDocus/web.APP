//= require './main'
//= require './uploader'

class DocumentsPieces extends DocumentsMain{
  constructor(){
    super();

    this.ajax_params =  {
                          'url': '/documents',
                          'type': 'GET',
                        }
  }

  load_packs(serialize_form=false, append=false){
    this.load_datas(serialize_form, append);
  }
}

jQuery(function() {
  let main = new DocumentsPieces();

  AppListenTo('documents_load_datas', (e)=>{ main.load_packs(true); });
  AppListenTo('documents_reinit_datas', (e)=>{ main.load_packs(false); });

  AppListenTo('documents_search_text', (e)=>{ main.load_packs(true); });

  AppListenTo('documents_next_page', (e)=>{ main.load_next_page(); });
});