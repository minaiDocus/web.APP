function efs_bind_all_events(){
  $('.storage_form button.validate_edition').unbind('click').bind('click', function(e){ AppEmit('efs_update_storage', { class_name: $(this).data('class-name') }); });

  $('.use_service').unbind('change').bind('change', function(e){ AppEmit('efs_use_service', { service: $(this).attr('id').split("_")[1], is_used: $(this).is(":checked") }); });
}

jQuery(function() {
  efs_bind_all_events();
});