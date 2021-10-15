//= require '../application'
//= require '../dynamic_events'

function calculate_footer_marginer(){
  let window_h = $(window).outerHeight();
  let margin     = parseFloat($('.body_content').css('margin-top').replace('px', ''));
  let footer_h   = $('footer').outerHeight();
  let customer_h = 0;

  if( $('.customer_header').length > 0 ){
    customer_h = $('.customer_header').outerHeight();
  }

  $('.body_content').css('max-height', (window_h - margin - footer_h) + customer_h);
}

function init_menu_animation(){
  let to_animate = GetCache('menu_animation');

  //special menu animation : keep it here
  $('nav.navbar.main_menu').unbind('click.animation').bind('click.animation', function(){ SetCache('menu_animation', 'yes', 1); })

  if(to_animate != 'no'){
    let organization_lefter = $('.organizations .lefter');
    organization_lefter.find('ul li.direct_links').addClass('hide');
    $('.navbar.main_menu').addClass('showMenu');
    $('footer.main_footer').addClass('showFooter');

    if(organization_lefter.length > 0){
      let duration = 500;
      organization_lefter.find('ul li.direct_links').each(function(e){
        duration = duration + 150
        setTimeout((f)=>{
          $(this).addClass('derivationLeft');
          $(this).removeClass('hide');
        }, duration);
      });
    }

    SetCache('menu_animation', 'no', 60);
  }
}

function bind_globals_events(){
  custom_dynamic_animation();
  custom_dynamic_height();
  elements_initializer();
  iDocus_event_emiter();
  iDocus_ajax_links();
  iDocus_dynamic_modals();
  /************************************************************************************/ 
  /******* IMPORTANT : USE ONLY UNBIND AND BIND FORMAT EVENTS IN THIS METHODS *********/
  /************************************************************************************/
  /* Notice flash */
    $('span.close_error').unbind('click').bind('click', function(e){ $('.notice-internal-error').fadeOut('fast'); });

  /* SORTABLE */
    $('.as_idocus_sortable').unbind('click').bind('click', function(e){
      e.preventDefault();
      let url    = $(this).attr('href');
      let target = $(this).parents('table:first').attr('id');
      let app    = new ApplicationJS();

      let ajax_params = {
                          url: url,
                          type: 'GET',
                          dataType: 'html',
                          target: `#${target}`
                        };

      if(target == '' || target == undefined || target == null){
        console.log('The sortable link doesn t have a valid target (table id is missing)');
      }
      else{
        if(url != '' && url != '#' && url != undefined && url != null)
          app.sendRequest(ajax_params);
      }
    });

  /* PAGINATIONS */
    $('.pagination .per-page').unbind('change').bind('change', function(e){
      let url          = $(this).data('url');
      let target       = $(this).data('target');
      let filter       = $(this).data('filter');
      let name         = $(this).data('name');
      let mark       = $(this).data('mark');
      let current_page = $(this).data('current-page');


      const emit_pagination_events = ()=>{
        AppEmit(`window.change-per-page.${name}`, { url: url, filter: filter, name: name, mark: mark, page: current_page, per_page: $(this).val() });
        if(mark != name)
          AppEmit(`window.change-per-page.${mark}`, { url: url, filter: filter, name: name, mark: mark, page: current_page, per_page: $(this).val() });
      }

      if( url != undefined && url != null && url != '' && url != '#'){
        let url2 = url
        let page_params = `per_page=${ $(this).val() }&page=${ current_page }`;
        if(/[?]/.test(url2))
          url2 = `${url2}&${page_params}`;
        else
          url2 = `${url2}?${page_params}`;

        if(filter){
          try{ url2 = `${url2}&${ $(`form#${filter}`).serialize() }` }catch{};
        }

        ApplicationJS.launch_async({ url: url2, method: 'GET', html: { target: target } }).then((e)=>{ emit_pagination_events() });
      }else{
        emit_pagination_events();
      }
    });

    $('.pagination .previous-page').unbind('click').bind('click', function(e){
      let url          = $(this).data('url');
      let target       = $(this).data('target');
      let filter       = $(this).data('filter');
      let name         = $(this).data('name');
      let mark         = $(this).data('mark');
      let per_page     = $(this).data('per-page');
      let current_page = $(this).data('current-page');
      let next_value   = current_page - 1;

      const emit_pagination_events = ()=>{
        AppEmit(`window.change-page.${name}`, { url: url, filter: filter, name: name, mark: mark, page: next_value, per_page: per_page, trigger: 'previous' });
        if(mark != name)
          AppEmit(`window.change-page.${mark}`, { url: url, filter: filter, name: name, mark: mark, page: next_value, per_page: per_page, trigger: 'previous' });
      }

      if( url != undefined && url != null && url != '' && url != '#'){
        if(next_value >= 1){
          let url2 = url
          let page_params = `per_page=${ per_page }&page=${ next_value }`;
          if(/[?]/.test(url2))
            url2 = `${url2}&${page_params}`;
          else
            url2 = `${url2}?${page_params}`;

          if(filter){
            try{ url2 = `${url2}&${ $(`form#${filter}`).serialize() }` }catch{};
          }

          ApplicationJS.launch_async({ url: url2, method: 'GET', html: { target: target } }).then(e=>{ emit_pagination_events(); });
        }
      }else{
        emit_pagination_events();
      }
    });

    $('.pagination .next-page').unbind('click').bind('click', function(e){
      let url           = $(this).data('url');
      let target        = $(this).data('target');
      let filter        = $(this).data('filter');
      let name          = $(this).data('name');
      let mark          = $(this).data('mark');
      let per_page      = $(this).data('per-page');
      let current_page  = $(this).data('current-page');
      let total_pages   = $(this).data('total-pages');
      let next_value = current_page + 1;

      const emit_pagination_events = ()=>{
        AppEmit(`window.change-page.${name}`, { url: url, filter: filter, name: name, mark: mark, page: next_value, per_page: per_page, trigger: 'next' });
                        if(mark != name)
                          AppEmit(`window.change-page.${mark}`, { url: url, filter: filter, name: name, mark: mark, page: next_value, per_page: per_page, trigger: 'next' });
      }

      if( url != undefined && url != null && url != '' && url != '#'){
        if(next_value <= total_pages){
          let url2 = url
          let page_params = `per_page=${ per_page }&page=${ next_value }`;
          if(/[?]/.test(url2))
            url2 = `${url2}&${page_params}`;
          else
            url2 = `${url2}?${page_params}`;

          if(filter){
            try{ url2 = `${url2}&${ $(`form#${filter}`).serialize() }` }catch{};
          }

          ApplicationJS.launch_async({ url: url2, method: 'GET', html: { target: target } }).then(e=>{ emit_pagination_events(); });
        }
      }else{
        emit_pagination_events();
      }
    });

  /* AS USER */
    $('a.as_user').unbind('click').bind('click', function(e){
      e.preventDefault();

      $('.as-user-with-overlay').show();    
      setTimeout(function(){$('.as-user-notification').slideDown('fast');}, 100);
    });

    $('.close_as_user_modal').unbind('click').bind('click', function(e){
      e.preventDefault();

      $('.as-user-notification').slideUp('fast');  
      setTimeout(function(){$('.as-user-with-overlay').hide();}, 300);
    });
  /* AS USER */

  /* SCROLL ON TOP */
    $('.scroll-on-top').unbind('click').bind('click', function(e){
      e.preventDefault();

      let body = $(".body_content");
      body.stop().animate({scrollTop:0}, 500, 'swing', function() {});
    });
  /* SCROLL ON TOP */

  $('table tbody .action, .action.submenu_action').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    $('.sub_menu').not(this).each(function(){
      $(this).addClass('hide');
    });

    $(this).parent().find('.sub_menu').removeClass('hide');
  });

  $('button.add-rule').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    if ($(this).find('.sub_rule_menu').hasClass('hide')){
      $(this).find('.sub_rule_menu').removeClass('hide')
    }
    else {
      $(this).find('.sub_rule_menu').addClass('hide')
    }    
  });

  $(document).unbind('click.organizations').bind('click.organizations',function(e){
    if ($('.sub_menu').is(':visible')) {
      $('.sub_menu').addClass('hide');
    }

    if ($('.sub_rule_menu').is(':visible')) { $('.sub_rule_menu').addClass('hide'); }
  });

  let popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  let popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
  });

  let tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  let tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  })


  AppEmit('window.application_auto_rebind');
}

function check_flash_messages(){
  let app = new ApplicationJS();
  app.noticeAllMessageFrom(document);
}

jQuery(function () {
  calculate_footer_marginer();

  init_menu_animation();

  bind_globals_events();

  ApplicationJS.set_checkbox_radio();

  check_flash_messages();

  /** Custom hide alert messages error **/
  AppListenTo('close_alert_errors', (e)=>{ $('.notice.notice-internal-error').slideUp('fast'); });

  /** Calculate footer marginer height **/
  $(window).resize(function(e){
    calculate_footer_marginer();
  })

  /* SCROLLING TO THE BOTTOM */
  $('.body_content').scroll(function() {
    let content_h  = $('.body_content').outerHeight();
    let content    = document.getElementsByClassName("body_content")[0];
    let c_position = content.scrollHeight - content.scrollTop

    if(content.scrollTop > 200)
      $('.scroll-on-top').show('slow');
    else
      $('.scroll-on-top').hide('slow');

    if(c_position == content_h)
      AppEmit('on_scroll_end');
  });
});