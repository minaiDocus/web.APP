function bind_all_events(){
  $('button.change-password').unbind('click').bind('click', function(e){ $('.modal#change-password').modal('show'); });
  $('.modal#change-password button.validate').unbind('click').bind('click', function(e){ AppEmit('profiles_change_password') });

  $('button.external-file-storage').unbind('click').bind('click', function(e){ $('.modal#external-file-storage').modal('show'); });

  $('button#validate_notification_options').unbind('click').bind('click', function(e){ AppEmit('profiles_change_notifications') });
}

jQuery(function() {
  bind_all_events();
});