function bind_globals_events() {
  elements_initializer();
  iDocus_ajax_links();

  $('.create-organization').unbind('click').bind('click',function(e) {
    e.preventDefault();

    AppEmit('create_organization');
  });

  $('.organization-filter').unbind('click').bind('click',function(e) {
    e.preventDefault();

    $("#filter-organizations.modal").modal('show');
  });
}