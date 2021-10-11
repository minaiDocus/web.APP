//= require './journal'

function searchable_option_copy_journals_list() {
  let checked_count = 0;

  $('select#copy-journals-into-customer').removeClass('form-control');
  $('select#copy-journals-into-customer').asMultiSelect({
    'noneText': 'Selectionner un/des journaux',
    'allText': 'Tous séléctionnés',
    events: {
      onChange: function(sol, changedElements) {
        changedElements['0'].checked ? checked_count ++ : checked_count --;
        (checked_count > 0) ? $('.copy_account_book_type_btn').removeAttr('disabled') : $('.copy_account_book_type_btn').attr('disabled', 'disabled');
      },
    }
  });
}


jQuery(function () {
  let journal = new Journal();
  journal.main();

  AppListenTo('window.application_auto_rebind', (e)=>{ searchable_option_copy_journals_list(); });

  AppListenTo('compta_analytic.edit_journal_compta', (e)=>{
    let elem = e.detail.obj;
    let journal_id = $(elem).data('journal-id');
    let customer_id = $(elem).data('customer-id');
    let code = $(elem).data('code');

    journal.edit_analytics(journal_id, customer_id, code);
  });

  AppListenTo('compta_analytics.validate_analysis', (e)=>{ journal.update_analytics(e.detail.data) });

  AppListenTo('window.change-per-page.journales', (e)=>{ journal.load_journals(e.detail.name, 1, e.detail.per_page); });
  AppListenTo('window.change-page.journales', (e)=>{ journal.load_journals(e.detail.name, e.detail.page); });
});