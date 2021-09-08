class DocumentsUploader{
  constructor(){
    this.input_user = $('#add-document #file_code');
    this.input_period = $('#add-document #file_prev_period_offset');
    this.input_journal = $('#add-document #file_account_book_type');
    this.start_button = $('#add-document .btn-add');
    this.base_modal = $('#add-document');
  }

  initialize_params(){
    this.upload_params = JSON.parse($('#fileupload').attr('data-params'));
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

  fetch_analytics(){
    let use_analytics = false;
    if(this.upload_params[this.current_code] != undefined)
      use_analytics = this.upload_params[this.current_code]['is_analytic_used'];

    $('#add-document form#fileupload .hidden_analytic_fields').html('');
    $(".analytic_resume_box").html('');
    AppEmit('compta_analytics.main_loading', { code: this.current_code, pattern: this.input_journal.val(), type: 'journal', is_used: use_analytics });
  }

  fill_journals_and_periods(){
    this.current_code = this.input_user.val();

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
    let me = this
    this.fetch_url(`/documents/uploader/journals/${ encodeURIComponent(this.input_user.val()) }`)
        .then((result)=>{
          let options = '';
          result.forEach((opt)=>{ options += `<option compta-processable="${opt[2]}" value="${opt[1]}">${opt[0]}</option>` });
          me.input_journal.html(options);

          me.input_journal.unbind('change').bind('change', function(e, self){
            me.fetch_analytics();

            let option_processable = $(self).find('option[value="'+$(self).val()+'"]').attr('compta-processable');
            if( option_processable == '1' )
              $('#add-document #compta_processable').css('display', 'none');
            else
              $('#add-document #compta_processable').css('display', 'inline');
          });

          me.input_journal.change();
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

  uploader.base_modal.on('shown.bs.modal', function(e){ uploader.initialize_params();});
  uploader.base_modal.on('hide.bs.modal', function(e){ uploader.reload_packs(); });

  AppListenTo('compta_analytics.hide_modal', (e)=>{
    $('.analytic_resume_box').html(e.detail.resume);

    //clone all hidden analytics fields to fileupload form
    let hidden_fields = $('#comptaAnalysisEdition form#compta_analytic_form_modal .hidden_fields').html();
    $('#add-document form#fileupload .hidden_analytic_fields').html(hidden_fields);
  });

  AppListenTo('compta_analytics.after_load', function(e){
    if(e.detail.type == 'success')
    {
      if(e.detail.with_default){ $('.with_default_analysis').show(); }
      $('.with_compta_analysis').show();
    }
    else
    {
      $('.with_default_analysis, .with_compta_analysis').hide();
    }
  });
});