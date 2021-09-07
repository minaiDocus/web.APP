function bind_all_events_account_number_rules(){
  function multi_select_for(target= 'add-modal') {
    if (target === 'add-modal') {
      $('select#customers-list').searchableOptionList({
        'noneText': 'Selectionner un/des clients affectés par la règle',
        'allText': 'Tous séléctionnés'
      });

      $('select#groups-list').searchableOptionList({
        'noneText': 'Selectionner un/des groupe(s) affectés par la règle',
        'allText': 'Tous séléctionnés'
      });
    }

    if (target === 'filter-modal') {
      $('select#filter-affect-to').searchableOptionList({
        'noneText': 'Selectionner une affectations',
        'allText': 'Tous séléctionnés'
      });

      $('select#filter-rule-type').searchableOptionList({
        'noneText': 'Selectionner un type de règles',
        'allText': 'Tous séléctionnés'
      });

      $('select#rule-categories').searchableOptionList({
        'noneText': 'Selectionner une catégorisation de règles',
        'allText': 'Tous séléctionnés'
      });
    }

    if (target === 'download-modal') {
      $('select#affect-rule-to').searchableOptionList({
        'noneText': 'Selectionner un/des affectations',
        'allText': 'Tous séléctionnés'
      });
    }

  }


  function show_affect_to(current_value) {
    if (current_value === 'user'){
      $('.head_affect_to').removeClass('hide');
      $('.customers-list').removeClass('hide');
      $('.groups-list').removeClass('hide');
    }
    else{
      $('.head_affect_to').addClass('hide');
      $('.customers-list').addClass('hide');
      $('.groups-list').addClass('hide');
    }
  }


  function set_third_party_account(selected_rule_type_value) {
    if (selected_rule_type_value === 'truncate'){
      $('.third_party_account-section').addClass('hide');
    }
    else{
      $('.third_party_account-section').removeClass('hide');
    }
  }


  $('.check-bank-rule').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    if ($('.check-bank-rule:checked').length > 0){
      $('#export-rule').removeClass('btn-light-secondary').addClass('btn-light').removeAttr('disabled');
      $('#delete-rule').removeClass('btn-light-secondary').addClass('btn-danger').removeAttr('disabled');
    }
    else{
      $('#export-rule').removeClass('btn-light').addClass('btn-light-secondary').attr('disabled', 'disabled');
      $('#delete-rule').removeClass('btn-danger').addClass('btn-light-secondary').attr('disabled', 'disabled');
    }
  });

  $('.check-all-bank-rule').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    if ($(this).is(':checked')){
      $('#export-rule').removeClass('btn-light-secondary').addClass('btn-light').removeAttr('disabled');
      $('#delete-rule').removeClass('btn-light-secondary').addClass('btn-danger').removeAttr('disabled');
      $(".check-bank-rule").prop('checked', true);
    }
    else{
      $('#export-rule').removeClass('btn-light').addClass('btn-light-secondary').attr('disabled', 'disabled');
      $('#delete-rule').removeClass('btn-danger').addClass('btn-light-secondary').attr('disabled', 'disabled');
      $(".check-bank-rule").prop('checked', false);
    }
  });

  $('button.add-rule').unbind('click').bind('click',function(e) {
    e.stopPropagation();

    if ($(this).find('.sub_rule_menu').hasClass('hide')){
      $(this).find('.sub_rule_menu').removeClass('hide')
    }
    else {
      $(this).find('.sub_rule_menu').addClass('hide')
    }    
  });

  multi_select_for('add-modal');
  $('.sub_rule_menu li.add')
  .unbind('click').bind('click',function(e) {
    e.stopPropagation();

    AppEmit('add_account_number_rule');

    multi_select_for('add-modal');      

    $('#add-new-rule').modal('show');
  });

  $('.edit-account-number-rule').unbind('click').bind('click', function(e) {
    e.stopPropagation();
    e.preventDefault();

    let elements = $(this).attr('href').split('/');

    AppEmit('edit_account_number_rule', { id: elements[elements.length - 2] });

    multi_select_for('add-modal');

    $('#add-new-rule').modal('show');
  });

  $('.required_field')
  .unbind('keypress keyup keydown input change').bind('keypress keyup keydown input change', function(e) {
    AppEmit('validate_account_number_rule_fields');
  });

  const rule_type_selector = $('select#rule-type');
  set_third_party_account(rule_type_selector.val());
  $(rule_type_selector)
  .unbind('change').bind('change', function(e) {
    e.stopPropagation();

    set_third_party_account($(this).val());
  });

  $('.validate-account-number-rule').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    $('form.account-number-rule-form').submit();
  });

  
  show_affect_to($('select#affect-to').val());
  $('select#affect-to, select#affect-rule-to').unbind('change').bind('change',function(e) {
    e.stopPropagation();

    show_affect_to($(this).val());
  });

  
  show_affect_to($('select#affect-rule-to').val());
  /*multi_select_for('download-modal');*/
  $('.sub_rule_menu li.download')
  .unbind('click').bind('click',function(e) {
    e.stopPropagation();

    /*multi_select_for('download-modal');*/

    $('#import-rule').modal('show');
  });

  
  multi_select_for('filter-modal');
  $('.more-filter').unbind('click').bind('click',function(e) {
    e.stopPropagation(); 

    multi_select_for('filter-modal');

    $('#filter-rule').modal('show');
  });

  $('.action.sub-menu-bank-affectation')
  .unbind('click').bind('click',function(e) {
    e.stopPropagation();

    $('.sub_menu').not(this).each(function(){
      $(this).addClass('hide');
    });

    $(this).parent().find('.sub_menu').removeClass('hide');
  });


  $('.skip_accounting_plan').unbind('click').bind('click', function(e) {
    e.stopPropagation();
    e.preventDefault();

    $('#skipAccountingPlan').modal('show');
  });

  $('#skipAccountingPlan #skipAccountingPlanButton')
  .unbind('click').bind('click', function(e) {
    e.stopPropagation();

    const accounts = $('#skipAccountingPlan #account_list').val();
    const account_validation = $('#skipAccountingPlan #account_validation').val();
    const url = $('#skipAccountingPlan #skipAccountingPlanForm').attr('action');

    AppEmit('skip_accounting_plan', { url: url, account_list: accounts, account_validation: account_validation });
  })


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

  $('.search-content #search_input').unbind('keyup').bind('keyup', function(e){ if(e.key == 'Enter'){ /*e.keyCode == 13*/ AppEmit('account_number_rule_contains_search_text'); } });
  $('.bank-affectation #basic-addon1').unbind('click').bind('click', function(e){ AppEmit('account_number_rule_contains_search_text'); });

  ApplicationJS.set_checkbox_radio();
  ApplicationJS.hide_submenu();
}

jQuery(function() {
  bind_all_events_account_number_rules();
});