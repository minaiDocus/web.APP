//= require './events'

class DocumentsReloadedCustomer{
  constructor(){
    this.applicationJS   = new ApplicationJS();
    this.edit_tags_modal = $('#tags-edit');
  }
}

jQuery(function() {
  let main = new DocumentsReloadedCustomer();

  AppListenTo('journal.before_rubric_addition', (e)=>{
    let customer_id = $('#customers').val();
    let form        = $('#edit-rubric-form');
    let base_uri    = form.attr('base_uri');

    $('#edit-rubric-form').attr('action', `${base_uri.replace('cst_id', customer_id)}`);
  });

  AppListenTo('refresh_customer_view', (e)=>{ windows.location.reload })
});