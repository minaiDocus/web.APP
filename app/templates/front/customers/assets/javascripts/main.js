class Customer{

  constructor(){
    this.applicationJS = new ApplicationJS;
    this.create_customer_modal = $('#create-customer.modal');
    this.filter_customer_modal = $('#customers-filter');
    this.organization_id = $('input:hidden[name="organization_id"]').val();
  }


  main(){
    $('.action.sub_edit_delete, .edit_group').unbind('click');
    $('.action.sub_edit_delete, .edit_group').bind('click',function(e) {
      e.stopPropagation();

      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).parent().find('.sub_menu').removeClass('hide');
    });

    this.add_customer();

    this.hide_sub_menu();
  }

  add_customer(){
    var self = this;
    $('.new-customer').unbind('click');
    $(".new-customer").bind('click',function(e) {
      e.stopPropagation();
      self.get_customer_first_step_form();

      self.set_pre_assignment_view();
    });
  }

  set_pre_assignment_view(){
    var self = this;
    $(document).on('show.bs.modal', '#create-customer.modal', function () {
      $('.input-toggle').change(function() {
        if ($(this).is(':checked')){
          $(this).parent().find('label').text('Oui');
          $(this).attr('value', true);
          $(this).attr('checked', true);
        }
        else {
          $(this).parent().find('label').text('Non');
          $(this).attr('value', false);
          $(this).attr('checked', false);
          // $(this).removeAttr("checked");
        }        
      });
    });
  }

  get_customer_first_step_form(){
    this.applicationJS.parseAjaxResponse({ 'url': '/organizations/' + this.organization_id + '/customers/form_with_first_step' }).then((element)=>{
      this.create_customer_modal.find('.customer-base-form').html($(element).find('form .customer-base-form').html());
      this.create_customer_modal.find('.subscription-base-form').html($(element).find('form .subscription-base-form').html());
      
      $('select#select-group-list').removeClass('form-control');
      $('select#select-customer-list').removeClass('form-control');
      $('select#ibiza-customers-lists').removeClass('form-control');
      $('select#select-group-list').searchableOptionList({
        'noneText': 'Selectionner un/des groupe(s)',
        'allText': 'Tous séléctionnés'
      });
      $('select#select-customer-list').searchableOptionList();
      $('select#ibiza-customers-lists').searchableOptionList();
      
      this.create_customer_modal.modal('show');
    });
  }

  hide_sub_menu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.sub_menu').addClass('hide');
      }
    });
  }
}


jQuery(function () {
  var customer = new Customer();
  customer.main();
  // // customer.set_pre_assignment_view();
  // $(document).on('show.bs.modal', '#create-customer.modal', function () {
  //   $('.check-pre-assignment-view').change(function() {
  //     if ($(this).is(':checked')){
  //       $(this).attr('value', true);
  //       $(this).attr('checked', true); 
  //     }
  //     else { 
  //       $(this).attr('value', false);
  //       $(this).removeAttr("checked");
  //     }        
  //   });
  // });
  
  // $('#appart-group-filter').multiSelect({
  //   'noneText': 'Selectionner un groupes',
  //   'allText': 'Tous séléctionnés'
  // });

  // $('#appart-collaborator-filter').multiSelect({
  //   'noneText': 'Selectionner un collaborateur',
  //   'allText': 'Tous séléctionnés'
  // });

  // $('#book-customer').multiSelect({
  //   'noneText': 'Selectionnez un journal à ajouter au dossier client',
  //   'allText': 'Tous séléctionnés'
  // });

  // $('.action.sub_edit_delete, .edit_group').unbind('click')
  // $(".action.sub_edit_delete, .edit_group").bind('click',function(e) {
  //   e.stopPropagation();

  //   if ($(this).find('.sub_menu').hasClass('hide')){
  //     $(this).find('.sub_menu').removeClass('hide')
  //   }
  //   else {
  //     $(this).find('.sub_menu').addClass('hide')
  //   }
  // });

  // $('.new-customer').unbind('click')
  // $(".new-customer").bind('click',function(e) {
  //   e.stopPropagation();

  //   // $('#select-group-list').multiSelect();
  //   // $('#collab-customers').multiSelect();
  //   // $('#ibiza-customers-lists').multiSelect();
  //   // $('#add-book-customer').multiSelect({
  //   //   'noneText': 'Selectionnez un journal à ajouter au dossier client',
  //   //   'allText': 'Tous séléctionnés'
  //   // });

  //   $('#create-customer').modal('show');
  // });

  $('.sub_edit_delete li.edit').unbind('click')
  $(".sub_edit_delete li.edit").bind('click',function(e) {
    e.stopPropagation();

    $('.list-customers').addClass('hide')
    $('.customer-parameters').removeClass('hide')

  });

  $('.customer-filter').unbind('click')
  $(".customer-filter").bind('click',function(e) {
    e.stopPropagation();

    // $('#group-filter').multiSelect({
    //   'noneText': 'Selectionner un/des groupes',
    //   'allText': 'Tous séléctionnés'
    // });

    // $('#collaborator-filter').multiSelect({
    //   'noneText': 'Selectionner un/des collaborateurs',
    //   'allText': 'Tous séléctionnés'
    // });

    $('#customers-filter').modal('show');
  });
});