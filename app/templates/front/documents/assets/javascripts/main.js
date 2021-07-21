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

    this.applicationJS.parseAjaxResponse(this.ajax_params, function(){ $('#more-filter.modal').modal('hide'); }, bind_all_events)
                 .then((e)=>{
                    $('.datas_size').html($(e).find('.datas_size').html());

                    if(append){
                      if($(e).find('.no-data-found').length > 0){
                        this.page = -1;
                      }else{
                        $('.main-content').append($(e).find('.main-content').html());
                      }
                    }
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
}

jQuery(function() {
  let main = new DocumentsMain();

  AppListenTo('download_pack_archive', (e)=>{ main.download_pack_archive($(e.detail.obj).attr('data-id')); });
  AppListenTo('download_pack_bundle', (e)=>{ main.download_pack_bundle($(e.detail.obj).attr('data-id')); });

  $('#preseizures_export.modal').unbind('show.bs.modal').bind('show.bs.modal', function(){ main.fetch_export_options(); });
  $('#preseizures_export.modal #export_button').unbind('click').bind('click', function(){ main.launch_export(); });
});