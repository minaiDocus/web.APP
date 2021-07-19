jQuery(function() {
  $('#sortable').sortable({
    items: "li.btn-light.active",
    start: function(event, ui) {
      ui.item.unbind("click");
    },
    stop: function(event, ui) {
      ui.item.bind('click', function(){});
    }
  });

  // $('#element-separator').multiSelect();


  $('li.btn-light.click').unbind('click');
  $('li.btn-light.click').on('click',function(e) {
    e.preventDefault();
    $(this).hasClass('active') ? $(this).removeClass('active') : $(this).addClass('active');
  });
});