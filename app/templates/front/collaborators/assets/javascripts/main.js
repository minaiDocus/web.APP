//= require './events'

class Main{
  constructor () {
    this.applicationJS   = new ApplicationJS;
    this.member_modal    = $('#add_edit_collaborator.modal');
    this.group_modal     = $('#add_edit_group');
    this.member_filter_modal = $('#search_collaborator_filter');
    this.organization_id = $('input:hidden[name="organization_id"]').val();
    this.action_locker   = false;
  }


  show_modal(target, params){
    if (target === 'collaborators') {
      this.applicationJS.parseAjaxResponse(params).then((element)=>{
        this.member_modal.find('.modal-body').html($(element).find('.form_content').html());
        this.member_modal.find('.modal-title').html($(element).find('.form_content').attr('text'));
        apply_searchable_option('collaborators');
        this.member_modal.modal('show');
      });
    }
    else if (target === 'groups') {
      this.applicationJS.parseAjaxResponse(params).then((element)=>{
        this.group_modal.find('.modal-body').html($(element).find('.form_content').html());
        this.group_modal.find('.modal-title').html($(element).find('.form_content').attr('text').html());
        apply_searchable_option('groups')
        this.group_modal.modal('show');
      });
    }
  }

  new_edit(target, action_name, id=0){
    if (id === 0) {
      let params =  { 'url': `/organizations/${this.organization_id}/${target}/${action_name}` };

      this.show_modal(target, params);
      $('.modal-footer .create_update').text('Ajouter');
    }
    else{
      let params =  { 'url': `/organizations/${this.organization_id}/${target}/${id}/${action_name}` };

      this.show_modal(target, params);
      $('.modal-footer .create_update').text('Éditer');
    }

    bind_collaborator_events();
    ApplicationJS.handle_submenu();
    ApplicationJS.hide_submenu();
  }

  create_update(url, data){
    this.applicationJS.parseAjaxResponse({
      'url': url,
      'data': data,
      'type': 'POST',
      'dataType': 'html',
    }).then((response)=>{
      $('.collaborators.page-content').html($(response).find('.collaborators.page-content').html());
      this.member_modal.modal('hide');
      bind_collaborator_events();
      ApplicationJS.handle_submenu();
      ApplicationJS.hide_submenu();
    }).catch((response)=>{ this.member_modal.modal('hide'); });
  }


  load_data(search_pattern=false, type='members', page=1, per_page=0){
    if(this.action_locker) { return false; }

    this.action_locker = true;
    let params = [];

    let search_text = '';

    if (search_pattern) {
      search_text = $('.search-content #search_input').val();
      if(search_text && search_text != ''){ params.push(`user_contains[text]=${encodeURIComponent(search_text)}`); }
    }

    if (type === 'members') { type = 'collaborators'; }

    params.push(`page=${page}`);

    if (per_page > 0) { params.push(`per_page=${ per_page }`); }

    let ajax_params =   {
                          'url': `/organizations/${this.organization_id}/${type}?${params.join('&')}`,
                          'dataType': 'html',
                          'target': ''
                        };

    this.applicationJS.parseAjaxResponse(ajax_params)
                      .then((html)=>{
                        this.action_locker = false;
                        bind_collaborator_events();
                        ApplicationJS.handle_submenu();
                        ApplicationJS.hide_submenu();
                      })
                      .catch(()=>{ this.action_locker = false; });
  }


  search_contains_filter(url, data){
    this.applicationJS.parseAjaxResponse({
      'url': url,
      'data': data,
      'type': 'GET',
      'dataType': 'html',
    }).then((response)=>{
      $('.collaborators.page-content').html($(response).find('.collaborators.page-content').html());
      this.member_filter_modal.modal('hide');
      bind_collaborator_events();
      ApplicationJS.handle_submenu();
      ApplicationJS.hide_submenu();
    }).catch((response)=>{ this.member_filter_modal.modal('hide'); });
  }
}


jQuery(function() {
  var main = new Main();

  AppListenTo('new_edit', (e)=>{ main.new_edit(e.detail.target, e.detail.action_name, e.detail.id); });
  AppListenTo('create_update', (e)=>{ main.create_update(e.detail.url, e.detail.data); });

  AppListenTo('user_contains_search_text', (e)=>{ main.load_data(true); });
  AppListenTo('search_contains_filter', (e)=>{ main.search_contains_filter(e.detail.url, e.detail.data); });
  
  AppListenTo('window.change-per-page.members', (e)=>{ main.load_data(true, e.detail.name, 1, e.detail.per_page); });
  AppListenTo('window.change-page.members', (e)=>{ main.load_data(true, e.detail.name, e.detail.page); });
});