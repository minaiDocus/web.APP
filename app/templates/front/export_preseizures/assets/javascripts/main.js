jQuery(function() {

  $('#document_filter').asMultiSelect({
    "texts" : { "searchplaceholder": "Choix dossier", "noItemsAvailable": 'Aucun dossier trouvé'},
    "resultsContainer": '.result-sol-document',
    "maxHeight": "500px",
    "noneText": "Choix dossier",
    "showSelectAll": false
  });

    $('#journal_filter').asMultiSelect({
    "texts" : { "searchplaceholder": "Choix journal", "noItemsAvailable": 'Aucun journal trouvé'},
    "resultsContainer": '.result-sol-journal',
    "maxHeight": "500px",
    "noneText": "Choix journal",
    "showSelectAll": false
  });

    $('#period_filter').asMultiSelect({
    "texts" : { "searchplaceholder": "Choix période", "noItemsAvailable": 'Aucune période trouvée'},
    "resultsContainer": '.result-sol-period',
    "maxHeight": "500px",
    "noneText": "Choix période",
    "showSelectAll": false
  });


  $('#export-filter').unbind('click').bind('click',function(e) {
    let applicationJS = new ApplicationJS();
    let datas         = $('form#preseizure-export-filter-form').serializeObject();

    let ajax_params =  {
                          'url': '/preseizures_export',
                          'type': 'GET',
                          'data': datas,
                          'dataType': 'html'
                        }

    applicationJS.sendRequest(ajax_params).then((element)=>{
      $('#table_preseizure_export').parent().html($(element).find('#table_preseizure_export'));
    });
  });



    $('#launch-reinit').unbind('click').bind('click',function(e) {
    let applicationJS = new ApplicationJS();

    let ajax_params =  {
                          'url': '/preseizures_export',
                          'type': 'GET',
                          'dataType': 'html'
                        }

    applicationJS.sendRequest(ajax_params).then((element)=>{
      $('#table_preseizure_export').parent().html($(element).find('#table_preseizure_export'));
    });

  });


});

