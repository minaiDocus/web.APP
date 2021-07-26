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
//= require moment
//= require daterangepicker
//

var GLOBAL = {}
var VARIABLES = {}
var VARS = {}

VARIABLES.set = (var_name, value) => {
  VARS[var_name] = value;
}

VARIABLES.get = (var_name) => {
  return VARS[var_name];
}

AppListenTo = (event_name, callback={}) => {
  document.addEventListener(event_name, callback, false);
}

AppEmit = (event_name, params=null) => {
  const event = new CustomEvent(event_name, {'detail': params});
  event.initEvent(event_name, true, true);

  document.dispatchEvent(event);
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

  noticeFlashMessageFrom(page=null, message = null){
    var html = message;
    var is_present = null;
    if(message)
    {
      is_present = 'true';
    }
    else
    {
      html = $(page).find('.notice-internal-success').html();
      is_present = $(page).find('.notice-internal-success .msg_present');
    }

    if(is_present.length > 0){
      $('#idocus_notifications_messages .notice-internal-success').html(html);

      $('#idocus_notifications_messages .notice-internal-success').show('');
      setTimeout(function(){$('.notice-internal-success').fadeOut('');}, 5000);
    }
  }

  noticeInternalErrorFrom(page=null, message = null){
    var html = message;
    if(page)
      html = $(page).find('.notice-internal-error').html();

    if(html)
    {
      $('#idocus_notifications_messages .notice-internal-error').html(html);
      $('#idocus_notifications_messages .notice-internal-error').show('');
    }
  }

  parseAjaxResponse(params={}, beforeUpdateContent=function(e){}, afterUpdateContent=function(e){}){
    var self = this

    return new Promise((success, error) => {
      var target = params.target;

      $.ajax({
        url: params.url,
        type: params.type || 'GET',
        data: params.data,
        contentType: params.contentType || 'application/x-www-form-urlencoded; charset=UTF-8',
        dataType: params.dataType || 'html',
        beforeSend: function(){
          $('div.loading_box').removeClass('hide');
        },
        success: function(result) {
          $('div.loading_box').addClass('hide');
          if (beforeUpdateContent) { beforeUpdateContent(); }

          if(target){ $(target).html($(result).find(target).html()); }

          if (afterUpdateContent) { afterUpdateContent(); }

          self.noticeFlashMessageFrom(result);

          if(success)
            success(result);
        },
        error: function(result){
          $('div.loading_box').addClass('hide');
          self.noticeInternalErrorFrom(result);

          if(success)
            success(result);
        }
      });
    });
  }


  displayListPer(params={}, afterUpdateContent=function(e){}){
    if (afterUpdateContent !== null) { this.parseAjaxResponse(params, null, afterUpdateContent); }
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