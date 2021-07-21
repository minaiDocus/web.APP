//= require './events'

class DocumentsMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
    this.page = 1;
    this.ajax_params = {};
  }

  load_datas(serialize_form=false, append=false){
    let search_pattern = $('.search-content #search_input').val();

    let data = [];
    if(serialize_form){ data.push($('#pack_filter_form').serialize().toString()); }
    if(search_pattern && search_pattern != ''){ data.push(`text=${encodeURIComponent(search_pattern)}`); }
    if(this.page > 1){ data.push(`page=${this.page}`) }

    this.ajax_params['target'] = (append)? null : '.main-content';
    this.ajax_params['data']   = data.join('&');

    this.applicationJS.parseAjaxResponse(this.ajax_params, function(){ $('#more-filter.modal').modal('hide'); })
                 .then((e)=>{
                    $('.datas_size').html($(e).find('.datas_size').html());

                    if(append){
                      if($(e).find('.no-data-found').length > 0){
                        this.page = -1;
                      }else{
                        $('.main-content').append($(e).find('.main-content').html());
                      }
                    }

                    bind_all_events();
                  });
  }

  load_next_page(){
    if(this.page < 0) return false;

    this.page = this.page + 1;

    if(this.page > 1)
      this.load_datas(true, true);
  }

  fetch_export_options(){
    let gl_params = VARIABLES.get('preseizures_export_params');
    let params = gl_params || {};

    if(gl_params.type == 'preseizure')
      params['ids'] = gl_params.id
    else
      params['id'] = gl_params.id

    this.applicationJS.parseAjaxResponse({ 'url': '/documents/export_options', 'type': 'POST', 'data': params, target: null, dataType: 'json' })
                      .then((e)=>{
                        let options = e.options;
                        let html = '';

                        options.forEach((opt)=>{
                          html += `<option value=${opt[1]}>${opt[0]}</options>`
                        });

                        $('#preseizures_export #export_type').html(html);
                      });
  }

  launch_export(){
    let params = VARIABLES.get('preseizures_export_params');
    params['format'] = $('#preseizures_export #export_type').val();

    let str_params = JSON.stringify(params);

    window.open(`/documents/export_preseizures/${btoa(str_params)}`)
  }

  download_pack_archive(pack_id){
    window.open(`/documents/download_archive/${pack_id}`);
  }

  download_pack_bundle(pack_id){
    window.open(`/documents/download_bundle/${pack_id}`);
  }

  deliver_preseizures(elem){
    let id   = elem.attr('data-id');
    let ids  = elem.attr('data-ids');
    let type = elem.attr('data-type');
    let confirm_message = 'Voulez vous vraiment livrer les écritures comptables non livrées du lot?';

    let datas = {type: type, id: id };
    if(ids){
      ids = JSON.parse(ids);
      confirm_message = `Voulez vous vraiment livrer (${ids.length}) écriture(s) comptable(s)?`;
      datas = { ids: ids };
    }

    let params =  {
                    'url': '/documents/deliver_preseizures',
                    'type': 'POST',
                    'data': datas,
                    'dataType': 'json'
                  }

    if(confirm(confirm_message))
      this.applicationJS.parseAjaxResponse(params).then((e)=>{ this.applicationJS.noticeFlashMessageFrom(null, 'Livraison en cours ...'); });
  }
}

jQuery(function() {
  let main = new DocumentsMain();

  AppListenTo('download_pack_archive', (e)=>{ main.download_pack_archive($(e.detail.obj).attr('data-id')); });
  AppListenTo('download_pack_bundle', (e)=>{ main.download_pack_bundle($(e.detail.obj).attr('data-id')); });

  AppListenTo('documents_deliver_preseizures', (e)=>{ main.deliver_preseizures($(e.detail.obj)); });

  $('#preseizures_export.modal').unbind('show.bs.modal').bind('show.bs.modal', function(){ main.fetch_export_options(); });
  $('#preseizures_export.modal #export_button').unbind('click').bind('click', function(){ main.launch_export(); });
});