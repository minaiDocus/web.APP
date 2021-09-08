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
//= require custom_popover

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

// Type must be 'show' or 'hide'
AppToggleLoading = (type='show') => {
  if(type == 'show'){
    $('div.loading_box').addClass('force');
    $('div.loading_box').removeClass('hide');
  }
  else{
    $('div.loading_box').removeClass('force');
    $('div.loading_box').addClass('hide');
  }
}

SerializeToJson = (form) => {
  let data = form.serializeArray();
  let result = {};

  data.forEach((obj)=>{
    if(obj.name.match(/\[\]/)){
      let obj_index = obj.name.replace(/\[\]/g, '');
      let obj_val = result[obj_index];

      if(obj_val != '' && obj_val != undefined && obj_val != null){
        if(obj.value != undefined && obj.value != '' && obj.value != null)
          result[obj_index].push(obj.value)
      }else{
        if(obj.value != undefined && obj.value != '' && obj.value != null)
          result[obj_index] = [obj.value];
      }
    }else{
      if(obj.value != undefined && obj.value != '' && obj.value != null)
        result[obj.name] = obj.value
    }
  });

  return result
}

SetCache = (name, value, lifeTime) => {
  localStorage[name] = JSON.stringify({ dataSet: value, timeSet: new Date().getTime(), lifeTime: (lifeTime || 30) }) //lifeTime in minutes
}

GetCache = (name) => {
  if(localStorage[name] == undefined || localStorage[name] == '' || localStorage[name] == null){
    console.log('init')
    return ''
  }else{
    let dataCache = JSON.parse(localStorage[name])
    let dataSet = dataCache.dataSet
    let lifeTime = dataCache.lifeTime
    let timeSet = dataCache.timeSet

    if( (dataSet == undefined || dataSet == '' || dataSet == null) || (lifeTime == undefined || lifeTime == '' || lifeTime == null) ){
      return ''
    }else{
      let endTime = new Date().getTime()
      let timeDiff = ((endTime - timeSet) / 1000) / 60 //timeDiff in minutes

      if(timeDiff >= lifeTime){
        console.log('reset')
        return ''
      }else{
        console.log('cache')
        return dataSet
      }
    }
  }
}

class ApplicationJS {
  constructor(){
    this.parseJsVar();

    console.log( VARIABLES.get('controller_path') );
    this.parseJsVar = this.parseJsVar.bind(this);
  }

  parseJsVar(){
    $('span.js_var_setter').each(function(e){
      let name  = $(this).attr('id').replace('js_var_', '').trim();
      let value = $(this).text().trim();

      VARIABLES.set(name, atob(value));
    });
  }

  noticeAllMessageFrom(page=null){
    this.noticeFlashMessageFrom(page);
    this.noticeInternalErrorFrom(page);
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

      $('#idocus_notifications_messages .notice-internal-success').slideDown('fast');
      setTimeout(function(){$('.notice-internal-success').fadeOut('');}, 5000);
    }
  }

  noticeInternalErrorFrom(page=null, message = null){
    var html = message;
    var is_present = null;
    if(message)
    {
      is_present = 'true';
    }
    else
    {
      html = $(page).find('.notice-internal-error .message-alert').html();
      is_present = $(page).find('.notice-internal-error .msg_present');
    }

    if(is_present.length > 0){
      $('#idocus_notifications_messages .notice-internal-error .message-alert').html(html);

      $('#idocus_notifications_messages .notice-internal-error').slideDown('fast');
      setTimeout(function(){$('.notice-internal-error').fadeOut('');}, 10000);
    }
  }

  parseAjaxResponse(params={}, beforeUpdateContent=function(e){}, afterUpdateContent=function(e){}){
    var self = this

    return new Promise((success, error) => {
      var target = params.target || null;

      $.ajax({
        url: params.url,
        type: params.type || 'GET',
        data: params.data,
        contentType: params.contentType || 'application/x-www-form-urlencoded; charset=UTF-8',
        dataType: params.dataType || 'html',
        beforeSend: function(){
          if(params.no_loading !== true){
            if( !($('div.loading_box').hasClass('force')) )
              $('div.loading_box').removeClass('hide');
          }
        },
        success: function(result) {
          if (beforeUpdateContent) { beforeUpdateContent(); }

          if(target){ $(target).html($(result).find(target).html()); }

          if (afterUpdateContent) { afterUpdateContent(); }

          self.noticeAllMessageFrom(result);         

          try{
            if(result.json_flash.success){
              self.noticeFlashMessageFrom(null, result.json_flash.success)
            }
          }catch(e){}

          try{
            if(result.json_flash.error){
              $('#idocus_notifications_messages .notice-internal-error .error_title').text('Attention');
              self.noticeInternalErrorFrom(null, result.json_flash.error)
            }
          }catch(e){}


          if(success)
            success(result);

          window.setTimeout((e)=>{ 
            if(params.no_loading !== true){
              if( !($('div.loading_box').hasClass('force')) )
                $('div.loading_box').addClass('hide');
            }
            bind_globals_events();
          }, 1000);
        },
        error: function(result){          
          self.noticeInternalErrorFrom(null, result.responseText);

          if(success)
            success(result);

          window.setTimeout((e)=>{
            if(params.no_loading !== true){
              if( !($('div.loading_box').hasClass('force')) )
                $('div.loading_box').addClass('hide');
            }
            bind_globals_events();
          }, 1000);
        }
      });
    });
  }

  displayListPer(params={}, afterUpdateContent=function(e){}){
    if (afterUpdateContent !== null) { this.parseAjaxResponse(params, null, afterUpdateContent); }
  }

  static set_checkbox_radio(that = null){
    let class_list = [];

    $('.input-toggle').change(function() {
      class_list = $(this).attr('class').split(/\s+/);

      if ($(this).is(':checked')){
        $(this).attr('checked', true);

        if (class_list.indexOf("ido-custom-checkbox") > -1) { $(this).parents().eq(3).find('label.ido-custom-label').text('Oui'); }
        else { $(this).parent().find('label').text('Oui'); }

        if ((class_list.indexOf("check-software") > -1) || (class_list.indexOf("filter-customer") > -1)) { $(this).attr('value', 1); }
        else { $(this).attr('value', true); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).addClass('active_option'); }

      }
      else {
        $(this).attr('checked', false);

        if (class_list.indexOf("ido-custom-checkbox") > -1) { $(this).parents().eq(3).find('label.ido-custom-label').text('Non'); }
        else { $(this).parent().find('label').text('Non'); }

        if ((class_list.indexOf("check-software") > -1) || (class_list.indexOf("filter-customer") > -1)) { $(this).attr('value', 0); }
        else { $(this).attr('value', false); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).removeClass('active_option'); }
      }

      if (that !== null) {
        if(class_list.indexOf("option_checkbox") > -1){
          that.check_input_number();
          that.update_price();
        }
      }
    });


    if ($('.input-toggle:checked').length > 0) {
      const selected = $('.input-toggle:checked');

      $.each(selected, function() {
        class_list = $(this).attr('class').split(/\s+/);
        let element = $(this);

        if (class_list.indexOf("ido-custom-checkbox") > -1) {
          element = $('.ido-custom-checkbox.input-toggle:checked');
          element.parents().eq(3).find('label.ido-custom-label').text('Oui');
        }
        else {
          element.parent().find('label').text('Oui');
        }
      });
    }
  }

  static hide_submenu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.sub_menu').addClass('hide');
      }

      if ($('.sub_rule_menu').is(':visible')) { $('.sub_rule_menu').addClass('hide'); }
    });
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