jQuery(function () {
  $('.valid-modification').unbind('click');
  $(".valid-modification").bind('click', function(e) {
    e.preventDefault();
    $('#general-modal').modal('show');
    $('#general-modal .valid').unbind('click');
    $('#general-modal .valid').bind('click', function(event) {
      $('form#edit-organization').submit();
    });
  });
});