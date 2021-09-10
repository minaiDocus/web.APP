function bind_account_sharings_organization_events(){
  $('#account_sharings .btn.share_account_btn').unbind('click').bind('click', function(e){ AppEmit('account_sharings_add_account'); });

  $('#guest_collaborators .btn.edit_contact').unbind('click').bind('click', function(e){ AppEmit('account_sharings_edit_contact', { id: $(this).data('id') }); });

  $('.modal#account-sharing button.validate').unbind('click').bind('click', function(e){ AppEmit('account_sharings_validate_sharing'); });
}

jQuery(function() {
  bind_account_sharings_organization_events();
});