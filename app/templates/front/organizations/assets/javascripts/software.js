class Software {
  constructor() {}

  useSoftware() {
    if ($('.use-software').length > 0) {
      $('img.use-software, span.use-software').unbind('click');
      $('img.use-software, span.use-software').bind('click', function(){
        if (!$(this).parent().hasClass('selected')) { $(this).parent().addClass('selected'); }

        $('#use-software-' + $(this).parent().attr('id')).modal('show');
      });
    }
  }

  setSearchableOptionList() {
    if ($('#organizations .edit_software_users .searchable-option-list').length > 0) {
      $('#organizations .edit_software_users .searchable-option-list').searchableOptionList({
        showSelectionBelowList: true,
        showSelectAll: true,
        maxHeight: '300px',
        texts: {
          noItemsAvailable: 'Aucune entrée trouvée',
          selectAll: 'Sélectionner tout',
          selectNone: 'Désélectionner tout',
          quickDelete: '&times;',
          searchplaceholder: 'Cliquer ici pour rechercher'
        }
      });
    }
  }

}


jQuery(function() {
  var software = new Software();
  software.useSoftware();
  software.setSearchableOptionList();
});