//=require './events'

class BoxDocument{
  constructor(){
    this.applicationJS = new ApplicationJS;
  }

  show_ibizabox_documents_page(url, target){
    this.applicationJS.sendRequest({ 'url': url }).then((element)=>{
      $(target).html($(element).find('.ibizabox_documents').html());

      bind_ibizabox_documents_events();
    }).catch((error)=> { 
      console.error(error);
    });
  }
}

jQuery(function() {
  let box_document = new BoxDocument();

  let load_historic = false
  let load_select = false

  if ($('#ibizabox_documents_historic').length > 0 && !load_historic){
    const url = $('#ibizabox_documents_historic').attr('link');
    box_document.show_ibizabox_documents_page(url, '.historic_content');
    load_historic = true
  }

  if ($('#select_ibizabox_documents').length > 0 && !load_select){
    const url = $('#select_ibizabox_documents').attr('link');
    box_document.show_ibizabox_documents_page(url, '.select_content');
    load_select = true
  }
})