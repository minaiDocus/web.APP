//= require '../application'
//= require './router'

function handleClickedMenu() {
  $(".nav-item").click(function () {
    $(".nav-item").removeClass("active");
    $(this).addClass("active");
  });
}


function getMyFavoriteCustomers() {
  $.ajax({
      url: "front/my_favorite_customers/",
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        insertSuccessResponse(result);

        var data = [];
        $.each(result['my_favorite_customers'], function(i, item) {
          data.push(item.name);
        });
        $('button.add-to-favorite').attr('data-original-value', data);
      }
  });
}

function insertSuccessResponse(result) {
  var data = []
  var count = result['my_favorite_customers'].length
  $.each(result['my_favorite_customers'], function(i, item) {
      raw_html = '';
      if (i % 2 == 0) {
        raw_html += '<div class="row my-favorite-customers-list">';
        raw_html += appendCustomers(item);
        if (i == (count -1))
          raw_html += '</div>';
      }
      else {
        raw_html += appendCustomers(item);
        raw_html += '</div>';
      }

      data.push(raw_html);
  });

  $('.my-favorite-customers-count').text(count);
  $('#my-favorite-customers-list').html(data.join('\n'));
}

function appendCustomers(data) {
  var raw_html = '';
  raw_html += '<div class="col-md-6">';
  raw_html += '<div class="favorite-list">';
  raw_html += '<div class="float-left">'
  raw_html += '<span>' + data["name"] + '</span>';
  raw_html += '<br>';
  raw_html += '<i class="text-muted">';
  raw_html += data["name"]
  raw_html += '<span class="text-muted-light">' + data["info"] + '</span>';
  raw_html += '</i>';
  raw_html += '</div>';
  raw_html += '<div class="float-right">';
  raw_html += '<span class="badge badge-success status-'+ data["badge"] + '">' + data["note"] + '</span>';
  raw_html += '&nbsp;';
  raw_html += '<svg viewBox="0 0 8 8" class="oi-icon  colored" style="width: 17px; height: 17px;fill: #b5a6a6;"><use xlink:href="/assets/open-iconic.min.svg#chevron-right" class="icon icon-chevron-right"></use></svg>';
  raw_html += '</div>';
  raw_html += '</div>';
  raw_html += '</div>';

  return raw_html;
}


function getNofication() {
  $.ajax({
      url: "front/notifications/",
      type: 'GET',
      dataType: 'json',
      success: function(result) {
        console.log(result);
        var raw_li = '';
        $.each(result['notifications'], function(i, item) {
          raw_li += '<li class="notification-list" id="li-id-'+ item.id + '">';
          raw_li += '<div class="row">';
          raw_li += '<div class="col-md-11">';
          raw_li += '<a class="dropdown-item notification-link" href="#notification-link">' + item.title + '</a>';
          raw_li += '<div class="text-muted-light">';
          raw_li += '<span class="notification-date">';
          raw_li += '<i class="text-muted">'+ item.date +'</i>';
          raw_li += '</span>';
          raw_li += '<br>';
          raw_li += '<span class="notification-content">';
          raw_li += '<i class="text-muted">' + item.content + '</i>';
          raw_li += '</span>';
          raw_li += '</div>';
          raw_li += '</div>';
          raw_li += '<div class="col-md-1 notification-state" id="notif-id-' + item.id + '">';
          raw_li += '<div class="m-0 text-right"></div>';
          raw_li += '</div>';
          raw_li += '</div>';
          raw_li += '</li>';
        });
        $('ul.dropdown-notif-items').html(raw_li);
        $('.notif-badge').text(result['notifications'].length);
      }
  });
}


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

function noticeFlashMessage(type, message) {
  raw_element = '<div class="alert alert-' + type + ' alert-dismissible fade show" role="alert">';
  raw_element += message;
  raw_element += '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
  raw_element += '<span aria-hidden="true">&times;</span>';
  raw_element += '</button>'
  raw_element += '</div>'
  $('#idocus_notifications_messages .notice-flash-message').html(raw_element);
}

function noticeInternalError(message) {
  raw_element = '<i class="bi bi-exclamation-triangle"></i>';
  raw_element += '<div class="alert alert-danger alert-dismissible fade show" role="alert">';
  raw_element += '<h4 class="alert-heading">iDocus rencontre de bug!</h4>';
  raw_element += '<hr>';
  raw_element += '<p class="mb-0">'+ message +'.</p>';
  raw_element += '<button type="button" class="close" data-dismiss="alert" aria-label="Close">';
  raw_element += '<span aria-hidden="true">&times;</span>';
  raw_element += '</button>'
  raw_element += '</div>'
  $('#idocus_notifications_messages .notice-internal-error').html(raw_element);
}


jQuery(function () {
  handleClickedMenu();
  getNofication();

  window.router.init_window();
});

// jQuery(function () {
//   handleClickedMenu();
//   getNofication();
//   showFavoriteCustomersDetails('#c-details-id-1', '#f-customer-details-id-1'); // TODO ... MAKE Dynamically
//   getMyFavoriteCustomers();
//   addCustomerToMyFavorite();
// });
