class FileSendingKit{

  constructor(){
    this.applicationJS      = new ApplicationJS();
    this.organization_id    = $('input:hidden[name="organization_id"]').val();
    this.add_new_rule_modal = $('#add-new-rule.modal');
    this.action_locker      = false;
  }

  generate_manual_paper_set_order(url, data){
    this.applicationJS.sendRequest({
      'url': url,
      'data': data,
      'type': 'POST',
      'dataType': 'json',
    }).then((result)=>{
      $(".manual-paper-set-loading-content").remove();
      $('#download-manual-paper-set-order .show-notify-content').hide('fade', 100);
      $('#download-manual-paper-set-order .pending-generation').addClass('hide');
      $('#download-manual-paper-set-order .error-generation').addClass('hide');
      $('#download-manual-paper-set-order .success-generation').removeClass('hide');
      $('#download-manual-paper-set-order .download-manual-paper-set-order-folder-pdf').show();
      $("#generate-manual-paper-set-order").removeAttr("disabled");
      $(".canceling-manual-order").removeAttr("disabled");
     }).catch((result)=>{ 
      this.action_locker = false;

      console.error(result);
      let message = 'Une erreur a été rencontré lors de la régénération de votre commande ... veuillez réessayer svp'
      if(result.status == '603'){
        message = result.responseText;
      }

      $(".manual-paper-set-loading-content").remove();
      $('#download-manual-paper-set-order .pending-generation').addClass('hide');
      $('#download-manual-paper-set-order .success-generation').addClass('hide');
      $('#download-manual-paper-set-order .error-generation').html(message);
      $("#generate-manual-paper-set-order").attr('disabled', 'disabled');
      $("#generate-manual-paper-set-order").removeAttr('disabled');
      $(".canceling-manual-order").removeAttr("disabled");
    });

     /*file_sending_kits_main_events();*/
  }
}