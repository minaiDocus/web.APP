//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require popper
//= require bootstrap
//= require chart.min
//= require jquery.qtip.min
//= require help
//= require jquery.tokeninput.min
//= require jquery.livequery.min
//= require jquery_nested_form
//= require file-uploader/vendor/jquery.ui.widget
//= require file-uploader/fileupload-tpl
//= require file-uploader/fileupload-load-image
//= require file-uploader/fileupload-canvas-to-blob
//= require file-uploader/fileupload-blueimp-gallery
//= require file-uploader/jquery.iframe-transport
//= require file-uploader/jquery.fileupload
//= require file-uploader/jquery.fileupload-process
//= require file-uploader/jquery.fileupload-image
//= require file-uploader/jquery.fileupload-validate
//= require file-uploader/jquery.fileupload-ui
//= require file-uploader/cors/jquery.xdr-transport
//= require file-uploader/main
//= require shift_selectable
//= require searchable-option-list
//= require chosen.jquery
//= require bootstrap-filestyle.min
//= require bootstrap-datepicker/core
//= require retractable
//= require jquery.multi-select
//
// French translation for bootstrap-datepicker
// Lola LAI KAM <lailol@directmada.com>
var GLOBAL = {}
var VARIABLES = {}
var VARS = {}

VARIABLES.set = (var_name, value) => {
  VARS[var_name] = value;
}

VARIABLES.get = (var_name) => {
  return VARS[var_name];
}

class ApplicationJS {
  constructor(){
    this.parseJsVar();

    this.parseJsVar = this.parseJsVar.bind(this);
  }

  parseJsVar(){
    $('span.js_var_setter').each(function(e){
      let name  = $(this).attr('id').replace('js_var_', '').trim();
      let value = $(this).text().trim();

      VARIABLES.set(name, atob(value));
    });
  }

  noticeFlashMessage(type, message){
    let raw_element = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">';
    raw_element += message;
    raw_element += '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    raw_element += '<span aria-hidden="true">&times;</span>';
    raw_element += '</button>';
    raw_element += '</div>';

    $('#idocus_notifications_messages .notice-flash-message').html(raw_element);
  }

  noticeInternalError(message){
    let raw_element = '<i class="bi bi-exclamation-triangle"></i>';
    raw_element += '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
    raw_element += '<h4 class="alert-heading">iDocus rencontre de bug!</h4>';
    raw_element += '<hr>';
    raw_element += '<p class="mb-0">'+ message +'.</p>';
    raw_element += '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
    raw_element += '<span aria-hidden="true">&times;</span>';
    raw_element += '</button>';
    raw_element += '</div>';

    $('#idocus_notifications_messages .notice-internal-error').html(raw_element);
  }

  getFrom(url, success, error){
    return new Promise((success, error) => {
      let self = this

      $.ajax({
        url: url,
        header: { Accept: 'application/html' },
        data: { xhr_token: VARIABLES.get('XHR_TKN') },
        type: 'GET',
        success: function(result){
          self.parseJsVar();

          if(success)
            success(result);
        },
        error: function(data){
          //TODO : personalize errors
          if(data.status == '404')
          {
            self.noticeInternalError('<span>Page introuvable ....</span>');
          }
          else
          {
            self.noticeInternalError(data.responseText);
          }

          if(error)
            error(data);
        },
      });
    });
  }
}