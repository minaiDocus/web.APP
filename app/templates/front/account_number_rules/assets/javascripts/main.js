//=require './events'

class AccountNumberRule{
  constructor(){
    this.applicationJS      = new ApplicationJS();
    this.organization_id    = $('input:hidden[name="organization_id"]').val();
    this.add_new_rule_modal = $('#add-new-rule.modal');
    this.action_locker      = false;
  }


  get_account_number_rule_view(id=0){
    let url  = `/organizations/${this.organization_id}/account_number_rules/new`;

    if (id > 0) { url  = `/organizations/${this.organization_id}/account_number_rules/${id}/edit`; }

    this.applicationJS.parseAjaxResponse({ 'url': url }).catch((error)=> { 
      console.log(error)
    }).then((element)=>{
      console.log(element);
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
}

jQuery(function() {

  let account_number_rule = new AccountNumberRule();

  AppListenTo('add_account_number_rule', (e)=>{ account_number_rule.add_account_number_rule(); });
  AppListenTo('edit_account_number_rule', (e)=>{ account_number_rule.edit_account_number_rule(e.detail.id); });
  AppListenTo('validate_account_number_rule_fields', (e)=>{ account_number_rule.validate_account_number_rule_fields(); });
});