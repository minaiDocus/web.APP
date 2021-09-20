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
//= require app_listener

var GLOBAL = {}
var VARIABLES = {}
var VARS = {}

VARIABLES.set = (var_name, value) => {
  VARS[var_name] = value;
}

VARIABLES.get = (var_name) => {
  return VARS[var_name];
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

          let target      = params.target || null;
          let destination = params.target_dest || target || null;
          if(target)
          {
            let source_html = '';
            try{
              source_html = $(result).find(target)[0].outerHTML;
            }catch(e){
              let found = false;
              if(/^[.]/.test(target)){
                if( $(result).hasClass(target.replace('.', '')) ){ found = true; source_html = $(result)[0].outerHTML; }
              }else if( /^[#]/.test(target) ){
                if( $(result).attr(id) == target.replace('#', '') ){ found = true; source_html = $(result)[0].outerHTML; }
              }

              if(!found)
                console.error(e);
            }

            if(params.mode == 'append')
              $(destination).append( source_html );
            else if(params.mode == 'prepend')
              $(destination).prepend( source_html );
            else
              $(destination).html( source_html );
          }

          if (afterUpdateContent) { afterUpdateContent(); }

          try{
            self.noticeAllMessageFrom(result);
          }catch(e){}

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

  static launch_async(idocus_params={}){
    return new Promise((success, error)=>{
      let url             = idocus_params['url'];
      let confirm_message = idocus_params['confirm'];

      if( url && url != '#' )
      {
        let type        = idocus_params['method'] || 'GET';
        let ajax_params = {
                            url: url,
                            type: type,
                          }
        //parsing content-type
          if(idocus_params['content-type']){
            ajax_params['contentType'] = idocus_params['content_type']
          }

        //parsing HTML parameter
          ajax_params['dataType'] = 'json';
          if(idocus_params['html'] && idocus_params['html']['target']){
            ajax_params['dataType'] = 'html';
            ajax_params['target']      = idocus_params['html']['target'];
            ajax_params['target_dest'] = idocus_params['html']['target_dest'] || ajax_params['target'];
            ajax_params['mode']        = idocus_params['html']['mode'];
          }

        //parsing form and datas parmeter
          let form      = $(`form#${idocus_params['form']}`);
          let form_data = {}

          if(form){
            if(ajax_params['dataType'] == 'json')
              form_data = SerializeToJson(form); //serialize as json
            else
              form_data = form.serialize(); //serialize as url params

            if(idocus_params['force_form_url'] == true){
              ajax_params['url'] = form.attr('action');

              if(form.attr('method'))
                ajax_params['type'] = form.attr('method');
            }
          }

          if(idocus_params['datas'] && ajax_params['dataType'] == 'json'){
            let new_datas = {}

            try{
              new_datas = JSON.parse(idocus_params['datas']) || {};
            }catch(e){
              new_datas = idocus_params['datas'] || {};
            }

            form_data = Object.assign( form_data, new_datas );
          }

          if(form_data){
            ajax_params['data'] = form_data;
          }

        let appJS = new ApplicationJS();
        appJS.parseAjaxResponse(ajax_params)
              .then(e => {
                //Handling modal param
                if( idocus_params['modal'] && idocus_params['modal']['id'] )
                {
                  let modal            = $(`.modal#${idocus_params['modal']['id']}`);
                  let close_on_success = (idocus_params['modal']['close_after_success'] === false)? false : true
                  let close_on_error   = idocus_params['modal']['close_after_error'] || false

                  if(e.json_flash){
                    if( close_on_success && e.json_flash.success ){ modal.modal('hide'); }
                    if( close_on_error && e.json_flash.error ){ modal.modal('hide'); }
                  }else{
                    if( close_on_success ){ modal.modal('hide'); }
                    if( close_on_error ){ modal.modal('hide'); }
                  }
                }

                //handle redirect_to param
                if( idocus_params['redirect_to'] && idocus_params['redirect_to']['url'] ){
                  ApplicationJS.launch_async( idocus_params['redirect_to'] ).then((e)=>{ success(e); }).catch(err=>{ error(err); });
                }
                else
                {
                  success(e);
                }
              })
              .catch(err => {
                //Handling modal param
                if( idocus_params['modal'] && idocus_params['modal']['id'] )
                {
                  let modal          = $(`.modal#${idocus_params['modal']['id']}`);
                  let close_on_error = idocus_params['modal']['close_after_error'] || false
                  if( close_on_error ){ modal.modal('hide'); }
                }

                success(err)
              });
      }
      else
      {
        success();
      }
    });
  }

  static set_checkbox_radio(that = null){
    let class_list = [];

    $('.input_switch').change(function() {
      class_list = $(this).attr('class').split(/\s+/);

      if ($(this).is(':checked')){
        $(this).attr('checked', true);

        if (class_list.indexOf("input_check_field") > -1) { $(this).closest('.form-check.form-switch').find('label.label_check_field').text('Oui'); }
        else { $(this).parent().find('label').text('Oui'); }

        if ((class_list.indexOf("check-software") > -1) || (class_list.indexOf("filter-customer") > -1)) { $(this).attr('value', 1); }
        else { $(this).attr('value', true); }

        if (class_list.indexOf("option_checkbox") > -1) { $(this).addClass('active_option'); }

      }
      else {
        $(this).attr('checked', false);

        if (class_list.indexOf("input_check_field") > -1) { $(this).closest('.form-check.form-switch').find('label.label_check_field').text('Non'); }
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


    if ($('.input_switch:checked').length > 0) {
      const selected = $('.input_switch:checked');

      $.each(selected, function() {
        class_list = $(this).attr('class').split(/\s+/);
        let element = $(this);

        if (class_list.indexOf("input_check_field") > -1) {
          element = $('.input_check_field.input_switch:checked');
          element.closest('.form-check.form-switch').find('label.label_check_field').text('Oui');
        }
        else {
          element.parent().find('label').text('Oui');
        }
      });
    }
  }

  static hide_submenu() {
    // ***** TO DELETE *****
  }

  static handle_submenu(){
    // ***** TO DELETE *****
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