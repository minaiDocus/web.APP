function bind_all_events(){
  $('#get_retriever').unbind('click').bind('click', function(e){
    let action = "get_retriever";
    let type   = "POST";
    let datas  = { user_code: $('input.user_code').val() };

    AppEmit('get_retriever', { 'action': action, "type": type, "datas": datas });
  });

  $('#user_reset_password').unbind('click').bind('click', function(e){
    let action = "user_reset_password";
    let type   = "POST";
    let datas  = { user_code: $('input.user_code').val() };

    if (confirm('Voulez-vous vraiment efféctuer cette action ? ')){
      AppEmit('user_reset_password', { 'action': action, "type": type, "datas": datas });
    }
  });

  $('.resume_me').unbind('click').bind('click', function(e){
    let action = "resume_me";
    let type   = "POST";
    let datas  = { retriever_id: $(this).data('retriever-id') };

    if (confirm('Voulez-vous vraiment efféctuer cette action ? ')){
      AppEmit('resume_me', { 'action': action, "type": type, "datas": datas });
    }
  });

  $('.toggle').unbind('click').bind('click', function(e){
    let action = $(this).data('action');

    $('.box .result.' + action).toggle('');
  });

  $('.view_bank_accounts').unbind('click').bind('click', function(e){
    let retriever_id = $(this).data('retriever-id');
    let title        = $(this).data('title');
    let action       = "get_bank_accounts";
    let type         = "POST";
    let datas        = { retriever_id: retriever_id };

    AppEmit('get_bank_accounts', {'action': action, "type": type, "datas": datas, "title": title });
  });

  $('#get_operations').unbind('click').bind('click', function(e){
    let action = "get_operations";
    let type   = "GET";
    let datas  = { ope_label: $('input.ope_label').val(), ope_user_code: $('input.ope_user_code').val(), ope_bank_id: $('input.ope_bank_id').val(), ope_date: $('input.ope_date').val() };

    if ($('input.ope_label').val() != "" || $('input.ope_user_code').val() != "" || $('input.ope_bank_id').val() != "" || $('input.ope_date').val() != ""){
      AppEmit('get_operations', { 'action': action, "type": type, "datas": datas });
    }    
  });

  $('#get_bank_accounts_bridge').unbind('click').bind('click', function(e){
    let action = "get_bank_accounts_bridge";
    let type   = "GET";

    AppEmit('get_bank_accounts_bridge', { 'action': action, "type": type, "datas": {} });
  });

  $('.switch').unbind('click').bind('click', function(e){
    let action = "switch";
    let type   = "POST";
    let datas  = { user_code: $('input.user_code').val(), to: $(this).data('action') };

    if (confirm('Voulez-vous vraiment efféctuer cette action ? ')){
      AppEmit('switch', { 'action': action, "type": type, "datas": datas });
    }
  });

  $('.check-all-operation').bind('click', function(e){
    let checked = $(this).is(':checked');

    $('.check-operation').prop('checked', checked);

    if (checked){
      $("#force_locked").show('');
    }
    else{
      $("#force_locked").hide();
    }

  });
}

class AdminBankUtilities {
  constructor(){
    this.applicationJS        = new ApplicationJS;    
    this.bank_utilities_modal = $('#bank_utlities.modal');   
  }

  bank_utilities(action, type, datas, modal_title=""){
    let self = this;

    action = action.selector;
    type   = type.selector;
    datas  = datas[0];

    $('.result').addClass('hide');
    $('.box .result.' + action).removeClass('hide');    

    self.ajax_params =  {
                          url: "/admin/bank_utilities/" + action,
                          type: type,
                          datatype: 'html',
                          data: datas,
                        }

    self.applicationJS.sendRequest(self.ajax_params)
                       .then((data)=>{
                          if (modal_title != ""){
                            $('#bank_utlities.modal').find('.modal-title').html(modal_title);

                            $('#bank_utlities.modal').find('.modal-body').html(data);

                            $('#bank_utlities.modal').modal('show');
                          }
                          else{
                            $('.box .result.' + action).html(data).show('');
                          }

                          bind_all_events();
                        })
                       .catch((e)=>{ console.log(e); });
  }
}

jQuery(function() {
  let abu = new AdminBankUtilities();

  bind_all_events();

  AppListenTo('get_retriever', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas) ); });
  AppListenTo('user_reset_password', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas) ); });
  AppListenTo('resume_me', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas) ); });
  AppListenTo('get_bank_accounts', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas), $(e.detail.title) ); });
  AppListenTo('get_operations', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas) ); });
  AppListenTo('switch', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas) ); });
  AppListenTo('get_bank_accounts_bridge', (e)=>{ abu.bank_utilities( $(e.detail.action), $(e.detail.type), $(e.detail.datas) ); });

});