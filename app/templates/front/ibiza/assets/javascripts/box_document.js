//=require './events'

class BoxDocument{
  constructor(){
    this.applicationJS = new ApplicationJS;
  }

  show_ibizabox_documents_page(url, target){
    this.applicationJS.sendRequest({ 'url': url }).then((element)=>{
      $(target).html($(element).find('#ibizabox_documents').html());

      bind_ibizabox_documents_events();
    }).catch((error)=> { 
      console.error(error);
    });
  }
}