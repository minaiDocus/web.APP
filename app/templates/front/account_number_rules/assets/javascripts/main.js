//=require './events'

class AccountNumberRule{
  constructor(){
    this.applicationJS      = new ApplicationJS();
    this.organization_id    = $('input:hidden[name="organization_id"]').val();
    this.add_new_rule_modal = $('#add-new-rule.modal');
    this.action_locker      = false;
  }


  load_data(type='account_number_rules', page=1, per_page=0){
    if(this.action_locker) { return false; }

    this.action_locker = true;
    let params = [];

    params.push(`page=${page}`);

    if (per_page > 0) { params.push(`per_page=${ per_page }`); }

    let ajax_params =   {
                          'url': `/organizations/${this.organization_id}/account_number_rules?${params.join('&')}`,
                          'dataType': 'html',
                          'target': ''
                        };

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((html)=>{
                        this.action_locker = false;
                        bind_all_events_account_number_rules();
                      })
                      .catch(()=>{ this.action_locker = false; });
  }


  get_account_number_rule_view(id=0){
    let url  = `/organizations/${this.organization_id}/account_number_rules/new`;

    if (id > 0) { url  = `/organizations/${this.organization_id}/account_number_rules/${id}/edit`; }

    this.applicationJS.parseAjaxResponse({ 'url': url }).catch((error)=> { 
      console.log(error)
    }).then((element)=>{
      let from        = '#account_number_rule.new';
      let modal_title = 'Ajouter une règle';

      if (id > 0) { 
        from        = '#account_number_rule.edit';
        modal_title = 'Éditer une règle';
      }

      this.add_new_rule_modal.find('.modal-body').html($(element).find(from).html());
      this.add_new_rule_modal.find('.modal-title').text(modal_title);

      bind_all_events_account_number_rules();
    });
  }

  validate_account_number_rule_fields(){
    let required_fields_count = 0;

    $('.required_field').each(function() {
      if ($(this).val() !== '') {
        required_fields_count += 1;
      }
    });

    if (required_fields_count === 6) { 
      this.add_new_rule_modal.find('.validate-account-number-rule').removeAttr('disabled');
      bind_all_events_account_number_rules();
    }
  }

  add_account_number_rule(){
    this.get_account_number_rule_view();
  }

  edit_account_number_rule(id){
    this.get_account_number_rule_view(id);
  }

  skip_accounting_plan(url, account_list, account_validation){
    this.applicationJS.parseAjaxResponse({
        'url': url,
        'data': { account_list: account_list, account_validation: account_validation },
        'type': 'POST',
        'dataType': 'json',
      }).then((e)=>{ /*this.applicationJS.noticeFlashMessageFrom(null, e.message);*/ })
  }
}

jQuery(function() {

  let account_number_rule = new AccountNumberRule();

  AppListenTo('add_account_number_rule', (e)=>{ account_number_rule.add_account_number_rule(); });
  AppListenTo('edit_account_number_rule', (e)=>{ account_number_rule.edit_account_number_rule(e.detail.id); });
  AppListenTo('validate_account_number_rule_fields', (e)=>{ account_number_rule.validate_account_number_rule_fields(); });

  AppListenTo('skip_accounting_plan', (e)=>{ account_number_rule.skip_accounting_plan(e.detail.url, e.detail.account_list, e.detail.account_validation); });

  AppListenTo('window.change-per-page', (e)=>{ account_number_rule.load_data(e.detail.name, 1, e.detail.per_page); });
  AppListenTo('window.change-page', (e)=>{ account_number_rule.load_data(e.detail.name, e.detail.page); });
});