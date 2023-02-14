
jQuery(function() {
  $('.download_export').unbind('click').bind('click',function(e) { 
      var presassignment_export_id = $(this).attr('data-preassignment-export-id');
      let params = JSON.parse(JSON.stringify(presassignment_export_id)) || {};
      params['presassignment_export_id'] = presassignment_export_id;

    window.location.href = `/download_export_preseizures/${params}`;

  });
});