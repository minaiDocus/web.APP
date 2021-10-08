jQuery(function() {
  AppListenTo('update_reminder_email_content', (e)=>{
    $('textarea#reminder_email_content').val($('.reminder_email_content iframe').contents().find('body').text().trim());
  });
});