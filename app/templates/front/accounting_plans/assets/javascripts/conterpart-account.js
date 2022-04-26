class ConterpartAccount {
  constructor(){
    this.appJS            = new ApplicationJS;
    this.modal            = $('.modal#conterpart_accounts');
    this.account_selector = $('select.account-item-selector');
    this.type             = 'provider';
  }

  init_form(id=0){
    let self = this;
    let url  = $('input.conterpart-edition').val();
    let param = `?kind=${self.type}`;
    if(id > 0)
      param = param + `&id=${id}`;

    let aj_params =   {
                        url: url + param,
                        type: 'GET',
                        dataType: 'html',
                      }
    self.appJS.sendRequest(aj_params).then((res)=>{
      this.modal.find('.modal-body .conterpart-body-form').html(res);
    })
  }

  delete_account(id=0){
    if(!/^all-/.test(id) && id <= 0){ return false }

    let confirm_text   = 'Vous êtes sur le point de supprimer : ';
    let account_to_del = $('.account-item-selector-container .account-item-selector option:selected').text();
    if( /^all-/.test(id) ){
      account_to_del = 'Tous les comptes de charge'
    }

    if(confirm(confirm_text + account_to_del + '\nEtes vous sûr?')){
      let self  = this;
      let url   = $('input.conterpart-deletion').val();
      let param = `?id=${id}`;

      let aj_params =   {
                          url: url + param,
                          type: 'DELETE',
                          dataType: 'json',
                        }
      self.appJS.sendRequest(aj_params).then((res)=>{
        AppEmit('ca.new-conterpart-account');
        AppEmit('ca.refresh_accounts_list');
      })
    }
  }


  get_accounts_list(type, reinit_form=true){
    let self  = this;
    this.type = type;

    let url  = $('input.conterpart-accounts-list').val();
    url      = url.replace('/type', `/${type}`);

    let aj_params =   {
                        url: url,
                        type: 'GET',
                        dataType: 'json',
                      }
    self.appJS.sendRequest(aj_params).then((res)=>{
      let selector_container = $('.account-item-selector-container');
      let selector = this.account_selector.clone();
      selector.html('');
      selector.append('<option value="">Selectionnez un compte de charge</option>');

      res.accounts.forEach((account)=>{
        selector.append(`<option value='${account.id}'>${account.name} - ${account.number}</option>`);
      });

      selector.addClass('chosen-list');
      selector.unbind('change.account-selection').bind('change.account-selection', function(e){ self.init_form($(this).val()) });

      selector_container.html(selector);

      if(reinit_form){ self.init_form(0); }
    });
  }
}

jQuery(function() {
  let conterpart_account = new ConterpartAccount();

  AppListenTo('ca.new-conterpart-account', (e)=>{
    $('select.account-item-selector').val('');
    conterpart_account.init_form(0);
  });

  AppListenTo('ca.refresh_accounts_list', (e)=>{
    let type = $('.modal#conterpart_accounts').find('input#conterpart-kind').val();
    conterpart_account.get_accounts_list(type, false);
  });

  AppListenTo('ca.delete-conterpart-account', (e)=>{
    let type = e.detail.datas.type;
    let kind = $('.modal#conterpart_accounts').find('input#conterpart-kind').val();

    if(type == 'all')
      conterpart_account.delete_account(`all-${kind}`);
    else
      conterpart_account.delete_account($('select.account-item-selector').val());
  });


  AppListenTo('window.application_auto_rebind', (e)=>{
    $('button.manage-conterpart-accounts').unbind('click.manage-conterpart-accounts').bind('click.manage-conterpart-accounts', function(e){
      let type = ($(this).hasClass('customer'))? 'customer' : 'provider';
      $('.modal#conterpart_accounts').modal('show');
      $('.modal#conterpart_accounts').find('input#conterpart-kind').val(type);
      conterpart_account.get_accounts_list(type);
    });
  });
});