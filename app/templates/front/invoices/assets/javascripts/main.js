class Invoice {

  constructor() {}

  setVariables(url, type, contentType, dataType, target='', data = null) {
    return  {
      'url': url,
      'type': type,
      'data': (data)? data : '',
      'contentType': contentType,
      'dataType': dataType,
      'target': target,
    }
  }

  resetForm(){
    $('form#data-invoice-upload')[0].reset();
    $('#invoice_setting_journal_code').html('');
  }

  openSubmenu() {
    var self = this;

    if ($('.sub_menu.integration').length > 0) {
      $('.invoice-setting-action').unbind('click');
      $(".invoice-setting-action").bind('click',function(e) {
        e.stopPropagation();

        var id = $(this).parent().find('input:hidden[name="invoice-setting-data"]').val();
        var code = $(this).parent().find('input:hidden[name="invoice-setting-data"]').data("code");
        var journal = $(this).parent().find('input:hidden[name="invoice-setting-data"]').data("journal");
        var organizationId = $(this).parent().find('input:hidden[name="invoice-setting-data"]').data('organization-id');

        if ($(this).hasClass('synchronize')) {
          $('#synchronization').modal('show');
          $('input:hidden[name="invoice_setting_id"]').val(id);
          $("#synchronize_user_info").text($(this).parent().find('input:hidden[name="invoice-setting-data"]').data('info'));
        }

        else if ($(this).hasClass('edit')) {
          self.setInvoice();

          $('#add-invoice-setting').addClass('hide');
          $('#integration').modal('show');
          $('#edit-invoice-setting').removeClass('hide');

          $("#invoice_setting_user_code option:contains("+code+")")
            .removeAttr('selected')
            .val(code)
            .prop("selected",true);
          $("#invoice_setting_user_code").change();

          $("#invoice_setting_journal_code option:contains("+journal+")")
            .removeAttr('selected')
            .val(journal)
            .prop("selected",true);
          $("#invoice_setting_journal_code").change();
          
          $("input:hidden[name="+'"invoice_setting[id]"'+"]").val(id);
        }
        else if ($(this).hasClass('delete')) {
          if (confirm('Voulez-vous vraiment le supprimer?')) {
            var applicationJS = new ApplicationJS();

            var beforeUpdateContent = function(){
              // self.hideModal('form#data-invoice-upload');
              // self.hideModal('#integration');
            };
            var afterUpdateContent = function(){
              self.showIntegrationModal();
              self.bindSubMenu();
            };

            var params = self.setVariables(
              '/organizations/' + organizationId + '/invoices/remove',
              'DELETE',
              'application/json; charset=utf-8',
              'html',
              '.auto_integration_box',
              JSON.stringify({id: id, organization_id: organizationId})
            );

            applicationJS.sendRequest(params, beforeUpdateContent, afterUpdateContent);
          }
        }
      });
    }
  }

  synchronizeInvoice() {
    var self = this;
    $('input#synchronize-invoice-setting').on('click', function(e) {
      e.stopPropagation();
      e.stopImmediatePropagation();

      var url = $('form#synchronization-invoice-form').attr('action');
      var organizationId = url.split('/invoices')[0].split('organizations/')[1].split('-')[0];

      var dataParams = { 
        organization_id: organizationId,
        invoice_setting_id: $('#synchronization-invoice-form input:hidden[name="invoice_setting_id"]').val(),
        invoice_setting_synchronize_contains: {
          period: $('#synchronization-invoice-form select#invoice_setting_synchronize_contains_period').val()
        }
      };

      var params = self.setVariables(
        '/organizations/' + organizationId + '/invoices/synchronize',
        'GET',
        'application/json; charset=utf-8',
        'html',
        '.invoices_box',
        dataParams
      );

      var applicationJS = new ApplicationJS();
      var beforeUpdateContent = function(){
        // $('#invoice_setting_synchronize_contains_period').html('');
        $('#synchronization').modal('hide');
      };

      var afterUpdateContent = function(){
        self.showIntegrationModal(); 
        self.bindSubMenu();
      };

      applicationJS.sendRequest(params, beforeUpdateContent, afterUpdateContent);
    })
  }

  addOrEdit(){
    var self = this;
    $('#add-invoice-setting, #edit-invoice-setting').unbind('click');
    $('#add-invoice-setting, #edit-invoice-setting').bind('click', function(e) {
      e.stopPropagation();
      e.stopImmediatePropagation();

      var organizationId = $('form#data-invoice-upload').attr('action').split('/invoices')[0].split('organizations/')[1].split('-')[0];
      var dataParams = {
        invoice_setting: {
          id: $('form#data-invoice-upload input:hidden#invoice_setting_id').val(),
          user_code: $('form#data-invoice-upload select#invoice_setting_user_code').val(),
          journal_code: $('form#data-invoice-upload select#invoice_setting_journal_code').val()
        },
          organization_id: organizationId
      };

      var applicationJS = new ApplicationJS();
      var beforeUpdateContent = function(){
        self.resetForm();
        $('#integration').modal('hide');
      };
      var afterUpdateContent = function(){
        self.showIntegrationModal();
        self.bindSubMenu();
      };
      var params = self.setVariables(
        '/organizations/' + organizationId + '/invoices/insert',
        'POST',
        'application/json; charset=utf-8',
        'html',
        '.auto_integration_box',
        JSON.stringify(dataParams)
      );

      applicationJS.sendRequest(params, beforeUpdateContent, afterUpdateContent);
    });

    $('#reset-invoice-setting-form').on('click', function() {
      self.resetForm();
    });
  }

  setInvoice(){
    var fileUploadParams, fileUploadUpdateFields, self = this;

    if ($('#invoice_setting_user_code').length > 0) {
      fileUploadParams = $('#data-invoice-upload').data('params');
      fileUploadUpdateFields = function(code) {
        var accountBookTypes, comptaProcessable, content, i, journalsComptaProcessable, name;
        accountBookTypes = fileUploadParams[code]['journals'];
        journalsComptaProcessable = fileUploadParams[code]['journals_compta_processable'] || [];
        content = '';
        i = 0;
        while (i < accountBookTypes.length) {
          name = accountBookTypes[i].split(' ')[0].trim();
          comptaProcessable = journalsComptaProcessable.includes(name) ? '1' : '0';
          content = content + '<option compta-processable=' + comptaProcessable + ' value=' + name + '>' + accountBookTypes[i] + '</option>';
          i++;
        }
        return $('#invoice_setting_journal_code').html(content);
      };
    }

    $('#invoice_setting_user_code').on('change', function() {
      if ($(this).val() !== '') {
        fileUploadUpdateFields($(this).val());
        $('#invoice_setting_journal_code').val();
        return $('#invoice_setting_journal_code').change();
      } else {
        return $('#invoice_setting_journal_code').html('');
      }
    });

    self.addOrEdit();
  }

  bindSubMenu() {
    $('.action.sub-menu-invoice').unbind('click');
    $(".action.sub-menu-invoice").bind('click',function(e) {
      e.stopPropagation();
      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).find('.sub_menu').removeClass('hide');
    });

    this.openSubmenu();
    this.viewOrDownload();
    this.loadPer();
  }

  hideSubMenu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.action .sub_menu').addClass('hide');
      }
    });
  }

  showIntegrationModal() {
    var self = this;
    $('.parameter').unbind('click');
    $('.parameter').bind('click', function(e) {
      self.setInvoice();
      $('#integration').modal('show');
      $('#edit-invoice-setting').addClass('hide');
    });
  }

  viewOrDownload() {
    if ($('.sub_menu.invoice').length > 0) {
      $('.invoice-action').unbind('click');
      $('.invoice-action').bind('click',function(e) {
        e.stopPropagation();
        if (($(this).hasClass('view'))) {
          var invoiceDialog = $('#showInvoice');
          invoiceDialog.find('h3').text($(this).parent().find('input:hidden[name="invoice-action-data"]').attr('title'));
          invoiceDialog.find("iframe").attr('src', $(this).parent().find('input:hidden[name="invoice-action-data"]').attr('link'));
          invoiceDialog.modal('show');
        }
        else if (($(this).hasClass('download'))) {
          window.open($(this).parent().find('input:hidden[name="invoice-action-data"]').attr('link'), '_blank');
        }
      });
    }
  }

  loadPer() {
    var self = this;
    $('select.display').on('change', function() {
      var valueSelected = $("option:selected", this).val();
      var elements = valueSelected.split('_');
      var current = ($(this).hasClass('customer-invoice')) ? 'select.customer-invoice' : 'select.organization-invoice';

      var params = self.setVariables(
        '/organizations/' + elements[0] + '/invoices?per_page=' + elements[1],
        'GET',
        'application/json; charset=utf-8',
        'html',
        ($(this).hasClass('customer-invoice')) ? '.auto_integration_box' : '.invoices_box'
      );

      var applicationJS = new ApplicationJS();
      var afterUpdateContent = function(){
        self.showIntegrationModal();
        self.bindSubMenu();
        $(current + ' option[value="' + valueSelected + '"]', this).attr('selected','selected');
      };

      applicationJS.displayListPer(params, afterUpdateContent);
    });
  }
}

jQuery(function () {
  var invoice = new Invoice();

  invoice.bindSubMenu();

  invoice.showIntegrationModal();
  invoice.openSubmenu();
  if ($('form#synchronization-invoice-form').length > 0) {
    invoice.synchronizeInvoice();
  }

  invoice.hideSubMenu();

  invoice.viewOrDownload();
  invoice.loadPer();
});