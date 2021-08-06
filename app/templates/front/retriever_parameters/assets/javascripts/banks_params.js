class RPBanksParams{
  constructor(mainJS){
    this.applicationJS = new ApplicationJS();
    this.modal         = $('#form-bank-account.modal');
    this.main          = mainJS;
    this.bank_id       = 0;
  }

  bank_activation(id, type='disable'){
    let action = (type == "disable")? "supprimer" : "activer";

    if(confirm(`Voulez-vous vraiment ${action} ce compte bancaire?`)){
      let ajax_params = {
                          'url': '/retriever/bank_activation',
                          'data': { id: id, type: type },
                          'type': 'POST',
                          'dataType': 'json'
                        };

      this.applicationJS.parseAjaxResponse(ajax_params).then((e)=>{ this.main.load_datas('banks-params'); this.applicationJS.noticeFlashMessageFrom(null, e.message); });
    }
  }

  edit_bank_account(id=0){
    this.bank_id = id;

    let url = '/retriever/new/bank'
    let title = 'Création de compte bancaire';

    if(this.bank_id > 0){
      url   = `/retriever/bank/${this.bank_id}`;
      title = 'Editon de compte bancaire';
    }
    

    let ajax_params = {
                        'url': url,
                        'dataType': 'html'
                      };

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((e)=>{ 
                        this.modal.modal('show');
                        this.modal.find('.modal-title').text(title);
                        this.modal.find('.modal-body').html(e);
                      });
  }

  update_bank_account(){
    let url = '/retriever/new/bank'

    if(this.bank_id > 0){
      url = `/retriever/bank/${this.bank_id}`
    }

    let datas = $(`#form-bank-params`).serialize();

    let ajax_params = {
                        'url': url,
                        'type': 'PATCH',
                        'data': datas,
                        'dataType': 'json'
                      };

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((e)=>{ 
                        if(e.success){
                          this.main.load_datas('banks-params');
                          this.modal.modal('hide');
                          this.applicationJS.noticeFlashMessageFrom(null, e.message);
                        }else{
                          this.applicationJS.noticeInternalErrorFrom(null, e.message);
                        }
                      });
  }
}