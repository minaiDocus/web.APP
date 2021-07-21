class DocumentsUploader{
  constructor(){
    this.input_user = $('#add-document #file_code');
    this.input_period = $('#add-document #file_prev_period_offset');
    this.input_journal = $('#add-document #file_account_book_type');
    this.start_button = $('#add-document .btn-add');
    this.base_modal = $('#add-document');
  }

  fetch_url(url, data, method = 'GET'){
    return new Promise((success, error)=>{
      $.ajax({
        url: url,
        type: method,
        data: data,
        dataType: 'json',
        success: function(result){ success(result); },
        error: function(result){ error(result); }
      });
    });
  }

  reload_packs(){
    if(VARIABLES.get('can_reload_packs')){
      VARIABLES.set('can_reload_packs', false);
      let main = new DocumentsMain;
      main.load_packs(true);
    }
  }

  fill_journals_and_periods(){
    this.fill_journals();
    this.fill_periods();
  }

  fill_periods(){
    this.fetch_url(`/documents/uploader/periods/${ encodeURIComponent(this.input_user.val()) }`)
        .then((result)=>{
          let options = '';
          result.forEach((opt)=>{ options += `<option value="${opt[1]}">${opt[0]}</option>` });
          this.input_period.html(options);
        })
  }

  fill_journals(){
    this.fetch_url(`/documents/uploader/journals/${ encodeURIComponent(this.input_user.val()) }`)
        .then((result)=>{
          let options = '';
          result.forEach((opt)=>{ options += `<option compta-processable="${opt[2]}" value="${opt[1]}">${opt[0]}</option>` });
          this.input_journal.html(options);

          this.input_journal.unbind('change').bind('change', function(e){ 
            let option_processable = $(this).find('option[value="'+$(this).val()+'"]').attr('compta-processable');
            if( option_processable == '1' )
              $('#add-document #compta_processable').css('display', 'none');
            else
              $('#add-document #compta_processable').css('display', 'inline');
          });
        })
  }
}

jQuery(function() {
  let uploader = new DocumentsUploader;
  VARIABLES.set('can_reload_packs', false);

  uploader.input_user.unbind('change').on('change', function(e){ uploader.fill_journals_and_periods(); });

  //first loading
  if(uploader.input_user.val())
    uploader.fill_journals_and_periods();


  uploader.start_button.livequery(function(){ 
    $('#add-document .btn-add').unbind('click.addition').bind('click.addition', function(e){ VARIABLES.set('can_reload_packs', true); });
  });

  uploader.base_modal.on('hide.bs.modal', function(e){ uploader.reload_packs(); });
});