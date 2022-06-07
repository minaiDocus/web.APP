jQuery(function () {
  $('.update_package').unbind('click').bind('click', function(e){
    $('.box.result').removeClass('hide')
    $.ajax({
      url: "/admin/package_setting/update_customers",
      type: "POST",
      data: {organization_code : $("#organization_code").val()},
      success: function(data){
        $('.box.result').html(data)
      }
    });
  });
});