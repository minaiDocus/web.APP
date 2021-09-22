//= require './journal'

jQuery(function () {
  let journal = new Journal();
  journal.main();

  $('#journal .edit_journal_analytics').unbind('click').bind('click', function(e){ 
    let journal_id = $(this).data('journal-id');
    let customer_id = $(this).data('customer-id');
    let code = $(this).data('code');
    journal.edit_analytics(journal_id, customer_id, code);
  });

  AppListenTo('compta_analytics.validate_analysis', (e)=>{ journal.update_analytics(e.detail.data) });

  AppListenTo('window.change-per-page.journales', (e)=>{ journal.load_journals(e.detail.name, 1, e.detail.per_page); });
  AppListenTo('window.change-page.journales', (e)=>{ journal.load_journals(e.detail.name, e.detail.page); });
});