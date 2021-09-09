function apply_searchable_option(target) {
  if (target === 'collaborators') {
    $('#select-collaborator-role').removeClass('form-control');
    $('#select-organization-group-list').removeClass('form-control');
    $('#select-collaborator-role').searchableOptionList();
    $('#select-organization-group-list').searchableOptionList();
  }

  else if (target === 'groups') {
    $('#select-collaborators-list').removeClass('form-control');
    $('#select-customers-collaborators-list').removeClass('form-control');
    $('#select-collaborators-list').searchableOptionList();
    $('#select-customers-collaborators-list').searchableOptionList();
  }
}

function bind_collaborator_events(){
  if ($('#information.active.show').length > 0) { apply_searchable_option('collaborators'); }

  $('.new_edit').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    let target      = '';
    let action_name = '';
    let id          = 0;

    if ($(this).hasClass('collaborator')) { target = 'collaborators'; }
    else if ($(this).hasClass('group')) { target = 'groups'; }

    if ($(this).hasClass('create')) { action_name = 'new'; }
    else if ($(this).hasClass('edit')) {
      id          = $(this).parent().attr('id').split('-')[1];
      action_name = 'edit';
    }

    AppEmit('new_edit', { target: target, action_name: action_name, id: id });
  });


  $('.create_update').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    const form = $('form.create_update_form');

    AppEmit('create_update', { url: form.attr('action'), data: form.serialize()});
  })


  $('.search-content #search_input').unbind('keyup').bind('keyup', function(e){ if(e.key == 'Enter'){ /*e.keyCode == 13*/ AppEmit('user_contains_search_text'); } });
  $('.collaborators-content #basic-addon1').unbind('click').bind('click', function(e){ AppEmit('user_contains_search_text'); });

  $('.more-filter').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    $('#search_collaborator_filter').modal('show');
  });

  $('.search_filter').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    const form = $('form.search_contains_filter');

    AppEmit('search_contains_filter', { url: form.attr('action'), data: form.serialize()});
  });
}

jQuery(function() {
  bind_collaborator_events();
});