class DocumentsPreseizures{
  constructor(){
    this.applicationJS = new ApplicationJS;
    this.edit_modal    = $('#edit_preseizures.modal');

    this.id = 0;
  }

  refresh_view(preseizure_id){
    let params =  {
                    'url': `/preseizures/${preseizure_id}`,
                    'data': { view: 'by_type' },
                    'dataType': 'html'
                  }

    this.applicationJS.parseAjaxResponse(params).then((e)=>{
      let dynamic_box = $(e).find('.dynamic_box');

      $('.dynamic_box').each((e, self)=>{
        let tmp_id = $(self).attr('data-preseizure-id');
        let tmp_type = $(self).attr('data-type');

        if(parseInt(preseizure_id) == parseInt(tmp_id)){
          $(self).html(dynamic_box.html());
          bind_all_events();
        }
      });
    });
  }

  edit_preseizures(elem){
    this.id  = elem.attr('data-id');

    let params =  {
                    'url': `/preseizures/${this.id}`,
                    'dataType': 'html'
                  }

    this.applicationJS.parseAjaxResponse(params).then((e)=>{
      this.edit_modal.find('.modal-body').html(e);
      this.edit_modal.modal('show');
    });
  }

  update_preseizures(){
    let datas = this.edit_modal.find('#preseizure_edition_form').serialize();
    datas += `&id=${this.id}`;

    let params =  {
                    'url': '/preseizures/update',
                    'type': 'POST',
                    'data': datas,
                    'dataType': 'json'
                  }

    this.applicationJS.parseAjaxResponse(params).then((e)=>{
      if(e.error.toString() == '')
      {
        this.refresh_view(this.id);
        this.applicationJS.noticeFlashMessageFrom(null, 'Modifié avec succès');
        this.edit_modal.modal('hide');
      }
      else
      {
        this.applicationJS.noticeInternalErrorFrom(null, e.error);
      }
    });
  }
}

jQuery(function() {
  let main = new DocumentsPreseizures();

  AppListenTo('documents_edit_preseizures', (e)=>{ main.edit_preseizures($(e.detail.obj)); });

  $('#edit_preseizures.modal').on('shown.bs.modal', function(e){ $('.datepicker').datepicker(); });
  $('#edit_preseizures.modal #preseizures_edit').unbind('click').bind('click', function(e){ main.update_preseizures(); });
});