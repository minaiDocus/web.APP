function addCustomerToMyFavorite() {
  const applySearchableOptionList = () => {
    if ($('#add-to-favorite #send_customer_to_favorite .searchable-option-list').length > 0) {
      $('#add-to-favorite #send_customer_to_favorite .searchable-option-list').searchableOptionList({
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

   $(".add-to-favorite").click(function(){
    var result = $(this).data('original-value');
    var _result = result.split(',')
    var element = $('select#select-customer-to-favorite');
    var option_html = '';

    for (var i = 0; i < _result.length; i++) {
      option_html += '<option value="' + _result[i] + '">' + _result[i] + '</option>';
      element.append(option_html);
    }
    element.html(option_html);
    $( "#select-customer-to-favorite option:first" ).attr('selected', 'selected');

    applySearchableOptionList();
  });


  var html_element = '';
  $("#add-customer-to-favorite").click(function(){
    var selectedOption = $( "#select-customer-to-favorite option:selected" ).text();
    var count = $('#my-favorite-customers-list').children().length;
    var data = $("#select-customer-to-favorite option:selected").map(function(i, el) {
        return $(el).val();
    }).get();

    // $("#send_customer_to_favorite").submit();

    var dataString = JSON.stringify({ my_favorite_customers: data});

    $.ajax({
      type: "POST",
      url: "front/add_customer_to_favorite/",
      data: dataString,
      contentType: "application/json; charset=utf-8",
      dataType: "json",
      success: function(result)
      {
         insertSuccessResponse(result);

         // TODO ... Customize this content ...
         noticeFlashMessage('success', 'Dossiers a été bien ajouté');
         noticeInternalError('error rencontre test');
      }
    });
  });
}

function showFavoriteCustomersDetails(target_id, button_id){
  $(document).on('click', button_id, function() {
    var classList = $(target_id).get(0).className.split(/\s+/);
    for (var i = 0; i < classList.length; i++) {
      if (classList[i] === 'd-none') {
         $(target_id).removeClass('d-none');
      } else {
        $(target_id).addClass('d-none');
      }
    }

  })
}

GLOBAL.DashboardMain = class DashboardMain extends ApplicationJS {
  constructor(){
    super();
  }

  loadFavoriteCustomers(){
    this.getFrom("/dashboard/my_favorite_customers", '.dashboardmain_loadfavoritecustomers');
  }
}

jQuery(function() {
  main = new GLOBAL.DashboardMain();
});
