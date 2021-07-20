class ReminderEmail {
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

  loadPer() {
    var self = this;
    $('select.display').on('change', function() {
      var valueSelected = $("option:selected", this).val();
      var elements = valueSelected.split('_');

      var params = self.setVariables(
        '/organizations/' + elements[0] + '/reminder_emails?per_page=' + elements[1],
        'GET',
        'application/json; charset=utf-8',
        'html',
        '.reminder-email-content'
      );

      var applicationJS = new ApplicationJS();
      var afterUpdateContent = function(){
        self.bindMain();
        $('select.reminder-email option[value="' + valueSelected + '"]', this).attr('selected','selected');
      };

      applicationJS.displayListPer(params, afterUpdateContent);
    });
  }

  bindMain() {
    var self = this;
    $('.action.sub-menu-mail-reminder').unbind('click');
    $(".action.sub-menu-mail-reminder").bind('click',function(e) {
      e.stopPropagation();

      $('.sub_menu').not(this).each(function(){
        $(this).addClass('hide');
      });

      $(this).find('.sub_menu').removeClass('hide');
    });

    $('.new-reminder-email').unbind('click');
    $(".new-reminder-email").bind('click',function(e) {
      e.stopPropagation();
      self.openModal();
    });

    self.hideSubMenu();
    self.loadPer();
  }

  setSubmenuAction(){
    var self = this;
    $('.reminder-email-action').unbind('click');
    $('.reminder-email-action').bind('click', function(e) {
      e.preventDefault();
      var organizationId = $(this).find('a').attr('organization_id');
      var reminderEmailsId = $(this).find('a').attr('id');
      var href = $(this).find('a').attr('href');

      if ($(this).hasClass('edit')) { window.location = href; /* self.openModal(); */ }
      else if ($(this).hasClass('view')) { window.open(href, '_blank');}
      else if ($(this).hasClass('delete') && confirm('Êtes-vous sûr ?')) { self.delete(reminderEmailsId, organizationId); }
      else if ($(this).hasClass('deliver') && confirm('Voulez vous vraiment envoyer les rappels maintenant ?')) { self.deliver(reminderEmailsId, organizationId); }
    });
  }

  openModal() {
    $('#reminder-email-modal').modal('show');
  }

  deliverOrDelete(reminderEmailsId, organizationId, url, method) {
    var self = this;
    var applicationJS = new ApplicationJS();

    var beforeUpdateContent = function(){
      $('.action.sub-menu-mail-reminder .sub_menu').addClass('hide');
    };
    var afterUpdateContent = function(){
      self.bindMain();
    };

    var params = self.setVariables(
      url,
      method,
      'application/json; charset=utf-8',
      'html',
      '.reminder-email-content',
      JSON.stringify({id: reminderEmailsId, organization_id: organizationId})
    );

    applicationJS.parseAjaxResponse(params, beforeUpdateContent, afterUpdateContent);
  }

  deliver(reminderEmailsId, organizationId){
    this.deliverOrDelete(
      reminderEmailsId,
      organizationId,
      '/organizations/' + organizationId + '/reminder_emails/' + reminderEmailsId + '/deliver',
      'POST'
    );
  }

  delete(reminderEmailsId, organizationId){
    this.deliverOrDelete(
      reminderEmailsId,
      organizationId,
      '/organizations/' + organizationId + '/reminder_emails/' + reminderEmailsId,
      'DELETE'
    );
  }

  hideSubMenu() {
    $(document).click(function(e) {
      if ($('.sub_menu').is(':visible')) {
        $('.action .sub_menu').addClass('hide');
      }
    });
  }
}

jQuery(function() {
  var reminderEmail = new ReminderEmail();
  reminderEmail.bindMain();
  reminderEmail.setSubmenuAction();
  reminderEmail.loadPer();
});