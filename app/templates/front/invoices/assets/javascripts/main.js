// class InvoiceMain {
//   constructor(){ }

//   setVariables(url, type, contentType, dataType, target='', data = null) {
//     return  {
//               'url': url,
//               'type': type,
//               'data': (data)? data : '',
//               'contentType': contentType,
//               'dataType': dataType,
//               'target': target,
//             }
//   }

//   resetForm(formId) {
//     $(formId)[0].reset();
//   }

//   hideModal(modalId) {
//     $(modalId).modal('hide');
//   }

//   showModal(modalId) {
//     $(modalId).modal('show');
//   }

//   reBindInvoiceAction(selector) {
//     var self = this
//     $(selector).unbind('click').bind('click', self.handleInvoice());
//   }

//   resetContent() {
//     this.resetForm('form#data-invoice-upload');
//     this.hideModal('#integration')
//   }

//   setInvoice(){
//     var fileUploadParams, fileUploadUpdateFields, self = this;

//     if ($('#invoice_setting_user_code').length > 0) {
//       fileUploadParams = $('#data-invoice-upload').data('params');
//       fileUploadUpdateFields = function(code) {
//         var accountBookTypes, comptaProcessable, content, i, journalsComptaProcessable, name;
//         accountBookTypes = fileUploadParams[code]['journals'];
//         journalsComptaProcessable = fileUploadParams[code]['journals_compta_processable'] || [];
//         content = '';
//         i = 0;
//         while (i < accountBookTypes.length) {
//           name = accountBookTypes[i].split(' ')[0].trim();
//           comptaProcessable = journalsComptaProcessable.includes(name) ? '1' : '0';
//           content = content + '<option compta-processable=' + comptaProcessable + ' value=' + name + '>' + accountBookTypes[i] + '</option>';
//           i++;
//         }
//         return $('#invoice_setting_journal_code').html(content);
//       };
//     }

//     $('#invoice_setting_user_code').on('change', function() {
//       if ($(this).val() !== '') {
//         fileUploadUpdateFields($(this).val());
//         $('#invoice_setting_journal_code').val();
//         return $('#invoice_setting_journal_code').change();
//       } else {
//         return $('#invoice_setting_journal_code').html('');
//       }
//     });

//     $('#add-to-invoice-setting, #edit-to-invoice-setting').on('click', function(e) {
//       e.stopPropagation();
//       e.preventDefault();
//       e.stopImmediatePropagation();

//       var url = $('form#data-invoice-upload').attr('action');
//       var organizationId = url.split('/invoices')[0].split('organizations/')[1].split('-')[0];

//       var dataParams = {
//         invoice_setting: {
//           id: $('form#data-invoice-upload input:hidden#invoice_setting_id').val(),
//           user_code: $('form#data-invoice-upload select#invoice_setting_user_code').val(),
//           journal_code: $('form#data-invoice-upload select#invoice_setting_journal_code').val()
//         },
//           organization_id: organizationId
//       };

//       var applicationJS = new ApplicationJS();

//       var beforeUpdateContent = function(){
//         self.resetForm('form#data-invoice-upload');
//         self.hideModal('#integration');
//       };
//       var afterUpdateContent = function(){ 
//         self.settingInvoice();
//         self.reBindInvoiceAction('.action.sub_integration'); 
//       };

//       var params = self.setVariables(
//         '/organizations/' + organizationId + '/invoices/insert',
//         'POST',
//         'application/json; charset=utf-8',
//         'html',
//         '.auto_integration_box',
//         JSON.stringify(dataParams)
//       );

//       applicationJS.parseAjaxResponse(params, beforeUpdateContent, afterUpdateContent);
//     });

//     $('#reset-invoice-setting-form').on('click', function() {
//       $('form#data-invoice-upload').trigger("reset");
//     });
//   }

//   integrateInvoiceSetting() {
//     var self = this;

//     if ($('.action.sub_integration .sub_menu').length > 0) {
//       $('.invoice-setting-action').unbind('click');
//       $("#invoice-setting-synchronize, #invoice-setting-edit, #invoice-setting-delete").bind('click',function(e) {
//         e.stopPropagation();

//         if ($(this).hasClass('invoice-setting-synchronize')) {
//           $('#synchronization').modal('show');
//           $('input:hidden[name="invoice_setting_id"]').val($('input:hidden[name="invoice-setting-data"]').data('id'));
//           $("#synchronize_user_info").text($('input:hidden[name="invoice-setting-data"]').data('info'));
//         }
//         else if ($(this).hasClass('invoice-setting-edit')) {
//           self.setInvoice();

//           $('.modal .modal-footer .add').hide();
//           $('.modal .modal-footer .edit').show();
//           $('#integration').modal('show');

//           var code = $('input:hidden[name="invoice-setting-data"]').data("code");
//           var journal = $('input:hidden[name="invoice-setting-data"]').data("journal");
//           var id = $('input:hidden[name="invoice-setting-data"]').data("id");

//           $("#invoice_setting_user_code option:contains("+code+")")
//             .removeAttr('selected')
//             .val(code)
//             .prop("selected",true);
//           $("#invoice_setting_user_code").change();

//           $("#invoice_setting_journal_code option:contains("+journal+")")
//             .removeAttr('selected')
//             .val(journal)
//             .prop("selected",true);
//           $("#invoice_setting_journal_code").change();
          
//           $("input:hidden[name="+'"invoice_setting[id]"'+"]").val(id);
//         }
//         else if ($(this).hasClass('invoice-setting-delete')) {
//           var organizationId = $('input:hidden[name="invoice-setting-data"]').data('organization-id');
//           var invoiceSettingId = $('input:hidden[name="invoice-setting-data"]').data('id');

//           if (confirm('Voulez-vous vraiment le supprimer?')) {
//             $('.action .sub_menu').remove();

//             self.setVariables(
//               '/organizations/' + organizationId + '/invoices/remove',
//               'DELETE',
//               'application/json; charset=utf-8',
//               'html',
//               '.total-invoices-setting',
//               'table.table_integration tbody',
//               JSON.stringify({id: invoiceSettingId, organization_id: organizationId})
//             );

//             var applicationJS = new ApplicationJS();

//             var beforeUpdateContent = function(){
//               self.hideModal('form#data-invoice-upload');
//               self.hideModal('#integration');
//             };
//             var afterUpdateContent = function(){ self.reBindInvoiceAction('.action.sub_integration'); };

//             applicationJS.parseAjaxResponse(beforeUpdateContent, afterUpdateContent);
//           }
//         }
//       });
//     }
//   }

//   setInvoiceAction() {
//     if ($('.action.sub_facture .sub_menu').length > 0) {
//       $('.invoice-action').unbind('click');
//       $("#invoice-viewing-pdf, #invoice-download-pdf").bind('click',function(e) {
//         e.stopPropagation();
//         if (($(this).hasClass('do-showInvoice'))) {
//           var invoiceDialog = $('#showInvoice');
//           invoiceDialog = $('#showInvoice');
//           invoiceDialog.find('h3').text($('input:hidden[name="invoice-data"]').data('title'));
//           invoiceDialog.find("iframe").attr('src', $('input:hidden[name="invoice-data"]').data('link'));
//           invoiceDialog.modal('show');
//         }
//         else if (($(this).hasClass('do-downloadInvoice'))) {
//           window.open($('input:hidden[name="invoice-data"]').data('link'), '_blank');
//         }
//       });
//     }
//   }

//   displayedPage() {
//     var self = this;
//     $('select#display_invoice_per, select#display_invoice_setting_per').on('change', function() {
//       var href = $("option:selected", this).data('href');
//       var organizationId = href.split('/invoices')[0].split('organizations/')[1];
//       var totalSelector = '.total-invoices';
//       var tableSelector = 'table.table_facture tbody';
//       var actionSelector = '.action.sub_facture';
//       var valueSelected = this.value;

//       if ($(this).hasClass('d-invoice-setting')){
//         totalSelector = '.total-invoices-setting';
//         tableSelector = 'table.table_integration tbody';
//         actionSelector = '.action.sub_integration';
//       }

//       self.setVariables(
//         href,
//         'GET',
//         'application/json; charset=utf-8',
//         'html',
//         totalSelector,
//         tableSelector,
//         null
//       );

//       var applicationJS = new ApplicationJS();
//       var afterUpdateContent = function(){ self.reBindInvoiceAction(actionSelector); };

//       applicationJS.displayListPer(afterUpdateContent);
//     });
//   }

//   hideSubMenu() {
//     $(document).click(function(e) {
//       if ($('.sub_menu').is(':visible')) {
//         $('.action .sub_menu').remove();
//       }
//     });
//   }

//   handleInvoice() {
//     var self = this;

//     $('.action.sub_facture').unbind('click');
//     $('.action.sub_integration').unbind('click');
//     $(".action.sub_facture, .action.sub_integration").bind('click',function(e) {
//       e.stopPropagation();
//       var subMenuClass = ($(this).hasClass('sub_integration')) ? 'sub_integration' : 'sub_facture';

//       if ($(this).parent().find('div.sub_menu').length > 0){
//         // $(this).parent().find('div.sub_menu').remove();
//       }
//       else {
//         if ($('.action .sub_menu').length > 0){
//           $('.action .sub_menu').remove();
//         }

//         $(this).append($('.'+ subMenuClass +'_append').html());
//       }

//       $('#invoice-setting-data').attr({
//         'data-id': $(this).find('#invoice_setting').val(),
//         'data-code': $(this).find('#invoice_setting').data('code'),
//         'data-journal': $(this).find('#invoice_setting').data('journal'),
//         'data-info': $(this).find('#invoice_setting').data('info')
//       });

//       self.integrateInvoiceSetting();

//       $('#invoice-data').attr({
//         'data-title': $(this).find('input:hidden[name="invoice-viewing-action"]').attr('title'),
//         'data-link': $(this).find('input:hidden[name="invoice-viewing-action"]').attr('link')
//       });

//       self.setInvoiceAction();
//     });
//   }

//   synchronizeInvoice() {
//     var self = this;
//     $('input#synchronize-invoice-setting').on('click', function(e) {
//       e.stopPropagation();
//       e.preventDefault();
//       e.stopImmediatePropagation();

//       var url = $('form#synchronization-invoice-form').attr('action');
//       var organizationId = url.split('/invoices')[0].split('organizations/')[1].split('-')[0];

//       var dataParams = { 
//         organization_id: organizationId,
//         invoice_setting_id: $('#synchronization-invoice-form input:hidden[name="invoice_setting_id"]').val(),
//         invoice_setting_synchronize_contains: {
//           period: $('#synchronization-invoice-form select#invoice_setting_synchronize_contains_period').val()
//         }
//       };

//       self.setVariables(
//         '/organizations/' + organizationId + '/invoices/synchronize',
//         'GET',
//         'application/json; charset=utf-8',
//         'html',
//         '.total-invoices',
//         'table.table_facture tbody',
//         dataParams
//       );

//       var applicationJS = new ApplicationJS();

//       var afterUpdateContent = function(){ self.reBindInvoiceAction('.action.sub_facture'); $('#synchronization').modal('hide'); };

//       applicationJS.parseAjaxResponse(null, afterUpdateContent);
//     })
//   }

//   settingInvoice(){
//     var self = this;

//     $('.parameter').unbind('click');
//     $(".parameter").bind('click',function(e) {
//       e.stopPropagation();

//       self.setInvoice();

//       $('.modal .modal-footer .edit').hide();
//       $('.modal .modal-footer .add').show();
//       $('#integration').modal('show');
//     });
//   }

//   // TODO : order kit
//   setOrder(){
//     $('.commande').unbind('click');
//     $(".commande").bind('click',function(e) {
//       e.stopPropagation();
//       $('#select-kit').searchableOptionList({
//         'searchplaceholder': 'Selectionner / Rechercher un dossier client à qui envoyer un kit courrier'
//       });

//       $('#commande-courrier').modal('show');
//     });
//   }

//   // TODO : share folder
//   shareFolder(){
//     $('.to-share').unbind('click')
//     $(".to-share").bind('click',function(e) {
//       e.stopPropagation();

//       $('#select-to-share').multiSelect({
//         'noneText': 'Selectionner un dossier'
//       });

//       $('#select-shared').multiSelect({
//         'noneText': 'Selectionner un dossier'
//       });

//       $('#shared-account').modal('show');
//     });
//   }

//   // TODO ...
//   shareFolderContent(){
//     $('#select-to-share, #select-shared, input.mail-content').unbind('change');
//     $("#select-to-share, #select-shared, input.mail-content").bind('change',function(e) {
//       e.stopPropagation();

//       if ($('#select-to-share option:selected').length > 0 && ($('#select-shared option:selected').length > 0 || $('input.mail-content').val() != ''))
//       {
//         $('.share').removeClass('btn-secondary').addClass('btn-primary').prop('disabled', false);

//       }
//       else
//       {
//         $('.share').removeClass('btn-primary').addClass('btn-secondary').prop('disabled', true);
//       }
//     });
//   }

// }


// jQuery(function () {
//   let main = new InvoiceMain();

//   main.handleInvoice();

//   main.settingInvoice();

//   if ($('form#synchronization-invoice-form').length > 0) {
//     main.synchronizeInvoice();
//   }

//   main.setOrder();

//   main.shareFolder();

//   main.shareFolderContent();

//   main.displayedPage();
//   main.hideSubMenu();
// });


jQuery(function () {
  $('.action.sub-menu-invoice, .action.sub-menu-integration').unbind('click')
  $(".action.sub-menu-invoice, .action.sub-menu-integration").bind('click',function(e) {
    e.stopPropagation();

    if ($(this).find('.sub_menu').hasClass('hide')){
      $(this).find('.sub_menu').removeClass('hide')
    }
    else {
      $(this).find('.sub_menu').addClass('hide')
    }
  });

  $('.parameter').unbind('click')
  $(".parameter").bind('click',function(e) {
      e.stopPropagation()
        $('#select-customer').multiSelect({
          'noneText': 'Selectionner/Rechercher un dossier client'
        });

        $('#book-select-customer').multiSelect({
          'noneText': 'Selectionner/Rechercher un dossier client'
        });

        $('#select-document').multiSelect({
          'noneText': 'Selectionner le type de document'
        });

        $('#book-select-devise').multiSelect({
          'noneText': 'Selectionner la devise'
        });
      
      $('#integration').modal('show')
  });

  $('.sub_menu li.edit').unbind('click')
  $(".sub_menu li.edit").bind('click',function(e) {
      e.stopPropagation()
      $('#select-edit-customer').multiSelect({
        'noneText': 'Selectionner/Rechercher un dossier client'
      });

      $('#select-edit-document').multiSelect({
        'noneText': 'Selectionner le type de document'
      });   
      
      $('#edit-integration').modal('show')
  });

  $('.sub_menu li.delete').unbind('click')
  $(".sub_menu li.delete").bind('click',function(e) {
    e.stopPropagation()

    $(this).closest('tr').remove();
  });
});