//= require './main'
//= require './tags'
//= require './preseizures'

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

  delete_piece(elem){
    if(confirm('Voulez vous vraiment supprimer cette(ces) pièce(s)')){
      let multi = elem.attr('multi') || false;
      let ids   = []

      if(multi == 'true'){
        ids = get_all_selected('piece');
      }
      else{
        ids.push( parseInt(elem.attr('data-id')) );
      }

      if(ids.length > 0){
        let params =  {
                        'url': '/documents/delete',
                        'data': { ids: ids },
                        'type': 'POST',
                        'dataType': 'json'
                      }

        this.applicationJS.parseAjaxResponse(params).then((e)=>{ this.load_pieces(true); this.applicationJS.noticeFlashMessageFrom(null, 'Pièce(s) supprimée(s) avec succès') });
      }
    }
  }

  show_preseizures_modal(elem){
    let preseizure_id = elem.attr('data-preseizure-id');
    if(preseizure_id){
      let params =  {
                      'url': `/preseizures/${preseizure_id}`,
                      'data': { view: 'by_type' },
                      'dataType': 'html'
                    }

      this.applicationJS.parseAjaxResponse(params).then((e)=>{
        $('#view-document-content .modal-body').html($(e).find('.preseizures_box').html());
        $('#view-document-content .modal-body .for-dismiss-modal').html($('.dismiss-modal').clone().removeClass('hide').html());
        $('#view-document-content').modal('show');
        bind_all_events();
      });
    }
  }
}


jQuery(function() {
  let main = new DocumentsDetails();

  AppListenTo('documents_show_preseizures_details', (e)=>{ main.show_preseizures_modal($(e.detail.obj)) });

  AppListenTo('documents_load_datas', (e)=>{ main.load_pieces(true) });
  AppListenTo('documents_reinit_datas', (e)=>{ main.load_pieces(false) });

  AppListenTo('documents_delete_piece', (e)=>{ main.delete_piece($(e.detail.obj)) });

  AppListenTo('documents_search_text', (e)=>{ main.load_pieces(true); });

  AppListenTo('on_scroll_end', (e)=>{ main.load_next_page(); });
});