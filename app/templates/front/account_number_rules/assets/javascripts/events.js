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
        'noneText': 'Selectionner un/des affectations',
        'allText': 'Tous séléctionnés'
      });

      $('select#filter-rule-type').searchableOptionList({
        'noneText': 'Selectionner un/des types de règles',
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

    let elements = $(this).attr('href').split('/');

    AppEmit('edit_account_number_rule', { id: elements[elements.length - 2] });

    multi_select_for('add-modal');

    $('#add-new-rule').modal('show');
  });

  $('.required_field')
  .unbind('keypress keyup keydown input change').bind('keypress keyup keydown input change', function(e) {
    AppEmit('validate_account_number_rule_fields');
  });

  $('.validate-account-number-rule').unbind('click').bind('click', function(e) {
    e.stopPropagation();

    $('form.account-number-rule-form').submit();
  });

  
  show_affect_to($('select#affect-to').val());
  $('#affect-to').unbind('change').bind('change',function(e) {
    e.stopPropagation();

    show_affect_to($(this).val());
  });

  
  multi_select_for('download-modal');
  $('.sub_rule_menu li.download')
  .unbind('click').bind('click',function(e) {
    e.stopPropagation();

    multi_select_for('download-modal');

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

  ApplicationJS.set_checkbox_radio();
  ApplicationJS.hide_submenu();
}

jQuery(function() {
  bind_all_events_account_number_rules();
});