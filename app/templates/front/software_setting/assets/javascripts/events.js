function bind_softwares_setting_events(){
  $('.btn#csv-descriptor-format').unbind('click.descriptor').bind('click.descriptor', function(e){ AppEmit('csv_descriptor_open_edition', { id: $(this).data('organization-id') }) });

  $('img.use-software, span.use-software').unbind('click');
  $('img.use-software, span.use-software').bind('click', function(){
    if (!$(this).parent().hasClass('selected')) { $(this).parent().addClass('selected'); }

    $('#use-software-' + $(this).parent().attr('id')).modal('show');
  });
}

jQuery(function() {
  bind_softwares_setting_events();
});