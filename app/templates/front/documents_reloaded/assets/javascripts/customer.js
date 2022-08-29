//= require './events'

class DocumentsReloadedCustomer{
  constructor(){
    this.applicationJS = new ApplicationJS();

  }

  show_temp_document(e){
    console.log(e)
  }
}

jQuery(function() {
  let main = new DocumentsReloadedCustomer();

  AppListenTo('journal.before_rubric_addition', (e)=>{
    let customer_id = $('#customer_document').val();
    let form        = $('#edit-rubric-form');
    let base_uri    = form.attr('base_uri');

    $('#edit-rubric-form').attr('action', `${base_uri.replace('cst_id', customer_id)}`);
  });

  AppListenTo('show_temp_document', (e)=>{ main.show_temp_document(e); })
});