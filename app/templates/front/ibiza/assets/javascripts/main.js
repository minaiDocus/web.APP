class Ibiza {
  constructor() {}

  openModal(listener, modalId) {
    $(listener).unbind('click');
    $(listener).bind('click',function(e) {
      e.preventDefault();
      $(modalId).modal('show');
    });
  }

  sortBy(software, _items='li.btn-light') {
    $(software).sortable({
      items: _items,
      start: function(event, ui) {
        ui.item.unbind("click");
      },
      stop: function(event, ui) {
        ui.item.bind('click', function(){});
      }
    });
  }

  editPieceName(){
    this.openModal('#piece-name-edit', '#softwares-piece-modal');
  }

  editPreseizureName() {
    this.openModal('#preseizure-name-edit', '#softwares-preseizure-modal');
  }
}


jQuery(function() {
  var ibiza = new Ibiza();
  ibiza.editPieceName();
  ibiza.editPreseizureName();
  ibiza.sortBy('#sortable-software');
  ibiza.sortBy('#sortable-software-preseizures');
});