class ConfigurationStep1{
  constructor(mainConfig){
    this.mainConfig = mainConfig;

    this.connectors = [];
  }

  /*** COMMON METHODS ***/
    primary_action(){
      if(this.mainConfig.current_connector){
        this.mainConfig.goto(2, this.retriever);
      }else{
        this.mainConfig.applicationJS.noticeInternalErrorFrom(null, 'Veuillez selectionnez un connecteur avant de poursuivre svp ...');
      }
    }

    secondary_action(){}
  /*** COMMON METHODS ***/

  init_form(retriever={}){
    this.retriever = retriever || {};
    let current_account = $('#account_id').val();

    if(this.retriever['id'] && this.retriever['id'] > 0){
      current_account = this.retriever['user_id'];
      $('#account_id').val(current_account);

      $('.step1 #connector-search-name').val('');
      this.mainConfig.main_modal.find('.step1 select#connectors-list').attr('disabled', 'disabled');
      $('.step1 #connector-search-name').attr('disabled', 'disabled');
    }else{
      this.mainConfig.main_modal.find('.step1 select#connectors-list').removeAttr('disabled');
      $('.step1 #connector-search-name').removeAttr('disabled');
    }
  
    if( current_account != 'all' && parseInt(current_account) > 0 ){
      this.mainConfig.main_modal.modal('show');

      this.mainConfig.budgeaApi.get_user_tokens()
                                .then((e)=>{
                                  this.fetch_connectors();
                                  this.mainConfig.budgeaApi.check_cgu();
                                });
    }else{
      this.mainConfig.applicationJS.noticeInternalErrorFrom(null, 'Veuillez selectionnez un compte avant de poursuivre svp ...');
    }
  }

  fetch_connectors(){
    if(this.connectors.length > 0)
    {
      this.fill_connectors();
    }
    else
    {
      let cache_connectors = this.mainConfig.get_cache('connectors_list');
      if(cache_connectors.length > 0)
      {
        this.connectors = cache_connectors;
        this.fill_connectors();
      }
      else
      {
        this.mainConfig.budgeaApi.get_connectors()
                                  .then((connectors)=>{
                                    this.connectors = connectors;
                                    this.mainConfig.set_cache('connectors_list', connectors);
                                    this.fill_connectors();
                                  })
                                  .catch((e)=>{ this.mainConfig.applicationJS.noticeInternalErrorFrom(null, e.toString()); })
      }
    }
  }

  fill_connectors(){
    let filter     = $('.step1 #connector-search-name').val();
    if(filter.length < 3){ filter = null };

    let type       = $('.step1 #choose-selector').val();
    let regEx      = new RegExp((`${filter}` || '.*'), 'i');
    let total_size = 0;
    let options    = '';

    let select = this.mainConfig.main_modal.find('.step1 select#connectors-list');
    select.html('');

    this.connectors.forEach((connector)=>{
      if( filter == '' || filter == null || filter == 'undefined' || regEx.test(connector['name']) ){
        if(type == 'all' || connector['capabilities'].find((e)=>{ return e == type })){
          total_size++;

          let select = '';
          if(this.retriever['budgea_connector_id'] && this.retriever['budgea_connector_id'] > 0 && this.retriever['budgea_connector_id'] == connector['id'])
            select = 'selected="selected"';

          options += `<option value="${connector['id']}" ${select}>${connector['name']}</option>`;
        }
      }
    });

    select.html(options);
    $('.step1 .connectors-size').text(total_size);

    if(this.retriever['budgea_connector_id'] && this.retriever['budgea_connector_id'] > 0){
      this.select_connector();
      this.mainConfig.goto(2, this.retriever);
    }
  }

  select_connector(){
    let connector_id = this.mainConfig.main_modal.find('select#connectors-list').val();
    this.mainConfig.current_connector = this.connectors.find((e)=>{ return e['id'] == connector_id });

    let html = '<ul>';
    this.mainConfig.current_connector['urls'].forEach((url)=>{
      html += `<li>${url}</li>`;
    })

    html += '</ul>'

    console.log(this.mainConfig.current_connector);

    this.mainConfig.main_modal.find('.step1 .urls-box').html(html);
  }
}