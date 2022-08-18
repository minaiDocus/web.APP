//= require './main'
//= require './tags'
//= require './uploader'
//= require './preseizures'

class DocumentsReloadedPieces extends DocumentsReloadedMain{
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
  let main = new DocumentsReloadedPieces();

  AppListenTo('documents_load_datas', (e)=>{ main.load_packs(true); });
  AppListenTo('documents_reinit_datas', (e)=>{ main.load_packs(false); });

  AppListenTo('documents_search_text', (e)=>{ main.load_packs(true); });

  AppListenTo('documents_next_page', (e)=>{ main.load_next_page(); });

  AppListenTo('document_customer_filter', (e)=>{ main.load_packs(true); });
  AppListenTo('filter_pack_badge', (e)=>{ main.load_packs(true); });

  AppListenTo('document_reloaded.toggle_piece_detail', (e)=>{
    let obj = e.detail.element;
    let piece_id  = $(obj).attr('datas-piece-id');
    let container = $(`.tr_piece_${piece_id}`);
    
    container.toggle('');

    if( container.find('.preseizures_box').length > 0 ){
      e.set_key('skip_ajax', true);
    }
  });
});