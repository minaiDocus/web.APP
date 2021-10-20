function elements_initializer(){
  $('.searchable-option-list').asMultiSelect({ maxHeight: '300px' });

  $('.chosen-list').asChosenList({
    search_contains: true,
    no_results_text: 'Aucun résultat correspondant à',
    inherit_select_classes: true
  });

  $('.singledate').asDateRange({
    defaultBlank: true,
    "autoApply": true,
    singleDatePicker: true,
    linkedCalendars: false,
    locale: {
      format: 'YYYY-MM-DD'
    }
  })

  $('.daterange').asDateRange({
    defaultBlank: true,
    "autoApply": true,
    linkedCalendars: false,
    locale: {
      format: 'DD/MM/YYYY'
    }
  });
}

function custom_dynamic_height(){
  var can_launch = true

  const launch = ()=>{
    window.setTimeout(()=>{
      $('.heightGroups').livequery(function(){
        console.log('seeking height');
        for(var i=1; i <= 5; i++) {
          var min_height = 0;
          if($('.heightGroups.groups_'+i).length > 0){
            $('.heightGroups.groups_'+i).each(function(e){
              if( min_height < $(this).innerHeight() ) min_height = $(this).innerHeight();
            });
            $('.heightGroups.groups_'+i).css('min-height', min_height+'px');
            can_launch = false;
          }
        }

        if(can_launch){ launch(); }
      });
    }, 500);
  }

  launch();
}

function custom_dynamic_animation(){
  if( $('.animatedGroups').length > 0 ){
    $('.animatedGroups').each(function(e){
      let parent = $(this);
      let step     = 200;
      let duration = 300;

      if( $(this).hasClass('reverse') ){
        duration = (parent.find('.animatedChild').length * step) + duration;
        step = step * -1
      }

      parent.find('.animatedChild').each(function(j){
        duration = duration + step;
        setTimeout((f)=>{
          $(this).addClass('didMove');

          if($(this).hasClass('toLeft'))
            $(this).addClass('derivationLeft');
          else if($(this).hasClass('toRight'))
            $(this).addClass('derivationRight');

          $(this).removeClass('animatedChild');
        }, duration)
      })
    });
  }
}

function iDocus_event_emiter(){
  let events_list = 'click.as_idocus_emit change.as_idocus_emit keyup.as_idocus_emit';
  $('.as_idocus_emit').unbind(events_list).bind(events_list, function(e){
    if( $(this).type != 'checkbox' && $(this).type == 'radio' )
      e.preventDefault();

    let current_event = e.type;
    let authorized_events = [];
    try { authorized_events = $(this).idocus('events').split(' ') || [] }catch(r){} ;

    if( authorized_events.find((t)=>{ return t == current_event }) || authorized_events.length == 0 ){
      let emit_params = null;
      try{
        emit_params = JSON.parse( atob($(this).attr('idocus')) );
      }catch(e){
        if(VARIABLES.get('rails_env') != 'production')
          emit_params = JSON.parse( $(this).attr('idocus') );
      }

      if(emit_params.datas)
        AppEmit(emit_params.name, { obj: $(this), datas: emit_params.datas });
      else
        AppEmit(emit_params.name, { obj: $(this) });
    }
  });
}

function iDocus_ajax_links(){
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
        if(VARIABLES.get('rails_env') != 'production')
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
}

function iDocus_dynamic_modals(){
  $('.as_idocus_modal').unbind('click.as_idocus_modal').bind('click.as_idocus_modal', function(e){
    if( $(this).type != 'checkbox' && $(this).type == 'radio' )
      e.preventDefault();

    let element = $(this);
    let params  = null;
    try{
      params = JSON.parse( atob($(this).attr('idocus')) );
    }catch(e){
      if(VARIABLES.get('rails_env') != 'production')
        params = JSON.parse( $(this).attr('idocus') );
    }

    let modal  = $(`#${params.id || 'general_idocus_main_modal'}`);
    if(modal.length > 0){
      modal.find('.modal-title').html(params.title);
      if(params.style){
        modal.find('.modal-dialog').attr('style', params.style);
      }

      const get_content = ()=>{
        let can_get_content = true
        if(params.refresh === false){
          let c_url = modal.find('.modal-body .associated_modal_url');

          if( c_url.length > 0 && c_url.val() == params.url ){
            can_get_content = false;
            set_buttons();
          }
        }
        
        if(can_get_content)
        {
          modal.find('.modal-body').html('');

          if( params.url ){
            let content_html = ''
            try{ content_html = $(params.url); }catch(e){}

            if( content_html.length > 0 ){
              content_html.removeClass('hide');

              modal.find('.modal-body').html( content_html[0].outerHTML );
              modal.find('.modal-body .associated_modal_url').remove();
              modal.find('.modal-body').append(`<input type="hidden" class="associated_modal_url" value="${params.url}">`);

              content_html.replaceWith('<div id="last_place_of_content"></div>');

              set_buttons();
            }else{
              let app = new ApplicationJS();
              let aj_params = {
                                url: params.url,
                                type: params.method || 'GET',
                                data: params.datas,
                                dataType: 'HTML',
                              }
              app.sendRequest(aj_params).then((res)=>{
                let content = res;
                if(params.target)
                  content = $(content).find(params.target)[0].outerHTML;

                modal.find('.modal-body').html(content);
                modal.find('.modal-body .associated_modal_url').remove();
                modal.find('.modal-body').append(`<input type="hidden" class="associated_modal_url" value="${params.url}">`);

                set_buttons();
              })
            }
          }
        }
      }

      const set_buttons = ()=>{
        let buttons = params.buttons || [];
        let footer  = modal.find('.modal-footer');
        if(params.with_cancel === false)
          footer.find('.btn.cancel').addClass('hide');
        else
          footer.find('.btn.cancel').removeClass('hide');

        footer.find('.appendable_elements').html('');

        if( buttons.length > 0 ){
          buttons.forEach((bt)=>{
            let template      = footer.find('.btn.template').clone();
            template.text(bt.label || 'valider');

            if(bt.id)
              template.attr('id', bt.id);

            if(bt.class){
              let btn_classes = ['btn-primary', 'btn-light', 'btn-secondary'];
              if( btn_classes.find(e => { return e.test(bt.class) }) )
              {
                btn_classes.forEach((a)=>{ template.removeClass(a); })
              }

              template.addClass(bt.class);
            }

            if(bt.action){
              if( /^\[.+\]$/.test(bt.action) ){
                template.addClass('as_idocus_emit');
                template.attr('emit', { name: bt.action.replace('[', '').replace(']', '' ), events: 'click' });
              }else{
                template.addClass('as_idocus_ajax');
                template.attr('idocus', bt.action);
              }
            }

            footer.find('.appendable_elements').append( template );
          });
        }
        else
        {
          let buttons = modal.find('.modal-body .idocus_modal_buttons');
          if(buttons.length > 0){
            footer.find('.appendable_elements').append( buttons.html() );
            buttons.addClass('hide');
          }
        }

        finalize_showing();
      }

      const finalize_showing = ()=>{
        if(params.static)
          modal.modal({ backdrop: 'static' });

        modal.modal('show');

        window.setTimeout(()=>{ 
          if(params.after_show)
            AppEmit(params.after_show, { obj: element });

          bind_globals_events() 
        }, 500 );

        modal.on('hidden.bs.modal', (e)=>{
          if(params.after_hide)
            AppEmit(params.after_hide, { obj: element });

          let last_content = $('#last_place_of_content');
          if(last_content.length > 0){
            let content_html = ''
            try{ content_html = $(params.url); }catch(e){}
            if( content_html.length > 0 ){
              content_html.addClass('hide');
            }

            last_content.replaceWith( modal.find('.modal-body').html() );
            modal.find('.modal-body').html('');
          }
        });
      }

      if(params.before_show){
        AppEmit(params.before_show, { obj: element }).then((e)=>{ get_content(); });
      }else{
        get_content();
      }
    }else{
      console.error(`Impossible de trouvé le modal: ${params.id}`)
    }
  });
}