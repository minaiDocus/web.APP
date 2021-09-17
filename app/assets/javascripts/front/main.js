//= require '../application'

function bind_globals_events(){
  if( $('.searchable-option-list').css('display') != 'none' )
    $('.searchable-option-list').searchableOptionList({ maxHeight: '300px' });

  /************************************************************************************/ 
  /******* IMPORTANT : USE ONLY UNBIND AND BIND FORMAT EVENTS IN THIS METHODS *********/
  /************************************************************************************/
  /* Notice flash */
    $('span.close_error').unbind('click').bind('click', function(e){ $('.notice-internal-error').fadeOut('fast'); });

  /* AS AJAX LINK */
    let events_list = 'click.as_idocus_ajax change.as_idocus_ajax keyup.as_idocus_ajax';
    $('.as_idocus_ajax').unbind(events_list).bind(events_list, function(e){
      if( $(this).type != 'checkbox' && $(this).type == 'radio' )
        e.preventDefault();

      $(this).attr('disabled', 'disabled');

      let current_event = e.type;
      let authorized_events = [];
      try { authorized_events = $(this).idocus('events').split(' ') || [] }catch(r){} ;

      if( authorized_events.find((t)=>{ return t == current_event }) || authorized_events.length == 0 ){
        let idocus_params = null;
        try{
          idocus_params = JSON.parse( atob($(this).attr('idocus')) );
        }catch(e){
          idocus_params = JSON.parse( $(this).attr('idocus') );
        }

        let confirm_message = idocus_params['confirm'];
        let can_continue    = true;
        if( confirm_message && !confirm(confirm_message) )
          can_continue = false;

        if( can_continue )
        {
          const launch_ajax = ( _params={} )=>{
            let next_param = Object.assign(idocus_params, _params);

            ApplicationJS.launch_async( next_param )
                         .then((e)=>{
                            if( next_param['after_send'] ){
                              AppEmit( next_param['after_send'], { response: e, element: $(this) } );
                            }

                            $(this).removeAttr('disabled');
                          })
                         .catch(e=>{ $(this).removeAttr('disabled'); })
          }

          if( idocus_params['before_send'] ){
            AppEmit( idocus_params['before_send'], { element: $(this), idocus_params: idocus_params } )
                   .then((i)=>{ launch_ajax(i) });
          }else{
            launch_ajax();
          }
        }
        else
        {
          $(this).removeAttr('disabled');
        }
      }else{
        $(this).removeAttr('disabled');
        console.log(`Unauthorized event : ${current_event}`);
      }
    });

  /* PAGINATIONS */
    $('.pagination .per-page').unbind('change').bind('change', function(e){
      let name = $(this).data('name');
      let target = $(this).data('target');
      let current_page = $(this).data('current-page');

      AppEmit(`window.change-per-page.${name}`, { name: name, target: target, page: current_page, per_page: $(this).val() });
      if(target != name)
        AppEmit(`window.change-per-page.${target}`, { name: name, target: target, page: current_page, per_page: $(this).val() });
    });
    $('.pagination .previous-page').unbind('click').bind('click', function(e){
      let name         = $(this).data('name');
      let target       = $(this).data('target');
      let per_page     = $(this).data('per-page');
      let current_page = $(this).data('current-page');
      let next_value   = current_page - 1;

      if(next_value >= 1){
        AppEmit(`window.change-page.${name}`, { name: name, target: target, page: next_value, per_page: per_page, trigger: 'previous' });
        if(target != name)
          AppEmit(`window.change-page.${target}`, { name: name, target: target, page: next_value, per_page: per_page, trigger: 'previous' });
      }
    });
    $('.pagination .next-page').unbind('click').bind('click', function(e){
      let name          = $(this).data('name');
      let target        = $(this).data('target');
      let current_page  = $(this).data('current-page');
      let total_pages   = $(this).data('total-pages');
      let next_value = current_page + 1;

      if(next_value <= total_pages){
        AppEmit(`window.change-page.${name}`, { name: name, target: target, page: next_value, trigger: 'next' });
        if(target != name)
          AppEmit(`window.change-page.${target}`, { name: name, target: target, page: next_value, trigger: 'next' });
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

  /* SCROLL */
  $('span[class^="auto-scroll-span"]').click(function(e){    
    var class_name = $(this).attr('class').split(' ')[0];
    var direction  = class_name.split('-')[3];
    ApplicationJS.generate_auto_scroll_for_div($(this), direction);
  });
  /* SCROLL */

  $('table tbody .action, .action.submenu_action').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    $('.sub_menu').not(this).each(function(){
      $(this).addClass('hide');
    });

    $(this).parent().find('.sub_menu').removeClass('hide');
  });

  $(document).unbind('click.organizations').bind('click.organizations',function(e){
    if ($('.sub_menu').is(':visible')) {
      $('.sub_menu').addClass('hide');
    }

    if ($('.sub_rule_menu').is(':visible')) { $('.sub_rule_menu').addClass('hide'); }
  });
}

function check_flash_messages(){
  let app = new ApplicationJS();
  app.noticeAllMessageFrom(document);
}

jQuery(function () {
  bind_globals_events();

  ApplicationJS.handle_submenu();
  ApplicationJS.set_checkbox_radio();
  ApplicationJS.hide_submenu();

  check_flash_messages();

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