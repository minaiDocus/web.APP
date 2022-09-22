//= require '../application'
//= require '../dynamic_events'

function bind_globals_events(){
  AppParseVars();
  custom_dynamic_animation();
  custom_dynamic_height();
  elements_initializer();
  iDocus_event_emiter();
  iDocus_ajax_links();
  iDocus_dynamic_modals();
  iDocus_pagination();
}

jQuery(function () {
  bind_globals_events();
});
