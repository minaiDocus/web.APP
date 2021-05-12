function update_groups() {
	var ids = '';

  $("input[name='account_number_rule[user_ids][]']").each(function(index, element) {
    if ($(element).attr('checked')) {
      ids += ' ' + $(element).val();
    }
  });

  $("input[name='account_number_rule[group][]']").each(function(index, element) {
    var i, id, results;
    if ($(element).attr('checked')) {
      ids += ' ' + $(element).val();
    } else {
      results = $(element).val().split(' ');
      for (i = 0; i < results.length; i++) {
        id = results[i];
        ids = ids.replace(id, '');
      }
    }
  });

  $("input[name='account_number_rule[user_ids][]']").attr('checked', false);

  var results_ids = ids.split(' ');
  for (var j = 0; j < results_ids.length; j++) {
    $('#account_number_rule_user_ids_' + results_ids[j]).attr('checked', true);
  }
}

jQuery(function() {
  var third_party_account = $('#account_number_rule_third_party_account').parent().parent();
  var affect_to = $('.affect_to');

  const applySearchableOptionList = () => {
    if ($('#skipAccountingPlan .searchable-option-list').length > 0) {
	    $('#skipAccountingPlan .searchable-option-list').searchableOptionList({
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

  if ($("#account_number_rule_affect_user").is(':checked')) {
    affect_to.show();
  }
  if ($('#account_number_rule_rule_type').val() == 'truncate') {
    third_party_account.hide();
  }
  $("#account_number_rule_affect_user").click(function(e) {
    affect_to.show();
  });
  $("#account_number_rule_affect_organization").click(function(e) {
    affect_to.hide();
  });
  $('#account_number_rule_rule_type').on('change', function() {
    if ($(this).val() === 'truncate') {
      third_party_account.hide();
    } else {
      third_party_account.show();
    }
  });

  $('.all_groups').click(function(e) {
    $("input[name='account_number_rule[group][]']").attr('checked', true);
    update_groups();
  });
  $('.no_groups').click(function(e) {
    $("input[name='account_number_rule[group][]']").attr('checked', false);
    update_groups();
  });
  $('.all_users').click(function(e) {
    return $("input[name='account_number_rule[user_ids][]']").attr('checked', true);
  });
  $('.no_users').click(function(e) {
    return $("input[name='account_number_rule[user_ids][]']").attr('checked', false);
  });
  $("input[name='account_number_rule[group][]']").on('change', function() {
    update_groups();
  });

  if ($('#account_number_rules.select_to_download').length > 0) {
    $('#master_checkbox').change(function() {
      if ($(this).is(':checked')) {
        $('.checkbox').attr('checked', true);
      } else {
        $('.checkbox').attr('checked', false);
      }
    });
  }

  applySearchableOptionList();

  $('#skipAccountingPlan #skipAccountingPlanButton').on('click', function() {
    var accounts = $('#skipAccountingPlan #account_list').val();
    var account_validation = $('#skipAccountingPlan #account_validation').val();
    var url = $('#skipAccountingPlan #skipAccountingPlanForm').attr('action');
    $.ajax({
      url: url,
      data: {account_list: accounts, account_validation: account_validation},
      dataType: 'json',
      type: 'POST',
      beforeSend: function() {
        $('#skipAccountingPlan .parentFeedback').show();
        $('#skipAccountingPlan #skipAccountingPlanButton').attr('disabled', 'disabled');
      },
      success: function(data) {
        $('#skipAccountingPlan .parentFeedback').hide();
        $('#skipAccountingPlan #skipAccountingPlanButton').removeAttr('disabled', 'disabled');
        $('#skipAccountingPlan').modal('hide');
      },
      error: function(data) {
        $('#skipAccountingPlan .parentFeedback').hide();
        $('#skipAccountingPlan #skipAccountingPlanButton').removeAttr('disabled', 'disabled');
      }
    });
  });

  console.log('account number rules todo ...');
});