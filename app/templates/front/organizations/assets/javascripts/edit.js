class Payment {
  constructor() {}

  validForm() {
    var self = this;
    var datas = $('#slimpay_checkout_form').serialize().split('&');
    var errors = [];

    datas.forEach(function(d) {
      var param = d.split('=');
      if (param[0] === 'first_name' && !param[1]) {
        errors.push('Prénom est vide');
      }
      if (param[0] === 'last_name' && !param[1]) {
        errors.push('Nom est vide');
      }
      if (param[0] === 'email' && !param[1]) {
        errors.push('Email est vide');
      }
      if (param[0] === 'address' && !param[1]) {
        errors.push('Adresse est vide');
      }
      if (param[0] === 'city' && !param[1]) {
        errors.push('Ville est vide');
      }
      if (param[0] === 'postal_code' && !param[1]) {
        errors.push('Code postal est vide');
      }
      if (param[0] === 'country' && !param[1]) {
        errors.push('Pays est vide');
      }
    });

    if (errors.length > 0) {
      self.setAlert('<ul>' + errors.map(function(e) {
        '<li>' + e + '</li>';
      }).join('') + '</ul>', 'alert-danger');
      return false;
    } else {
      return true;
    }
  }

  resetForm() {
    $('#slimpay_checkout_form #alert').addClass('hide');
    $('#slimpay_checkout_form #alert').html('');

    $('#slimpay_checkout #step2_section').html('');

    $('#slimpay_checkout #step1_buttons').removeClass('hide');
    $('#slimpay_checkout #step1_section').removeClass('hide');
    $('#slimpay_checkout #step2_section').addClass('hide');

    $('#slimpay_checkout #step_loader').addClass('hide');

    $('#slimpay_checkout_form input, #slimpay_checkout_form select').each(function(e) {
      $(this).removeAttr('disabled');
    });
  }

  setAlert(message, type) {
    $('#slimpay_checkout_form #alert').removeClass('hide');
    $('#slimpay_checkout_form #alert').html('<div class="span12 alert ' + type + '">' + message + '</div>');
    window.location.href = '#slimpay_checkout_form';
  }

  loadingToggle() {
    var loader = $('#slimpay_checkout #step_loader');

    if (loader.hasClass('hide')) {
      $('#slimpay_checkout #step1_buttons').addClass('hide');
      $('#slimpay_checkout #step_loader').removeClass('hide');
    }
    else {
      $('#slimpay_checkout #step1_buttons').removeClass('hide');
      $('#slimpay_checkout #step_loader').addClass('hide');
    }
  }

  submitSlimpay() {
    var self = this;
    $('#slimpay_checkout #submitSlimpay').on('click', function(e) {
      e.preventDefault();
      var id = $('#slimpay_checkout_form #organization_id').val();
      var url = "/organizations/" + id + "/prepare_payment";
      if (self.validForm()) {
        $.ajax({
          url: url,
          data: $('#slimpay_checkout_form').serialize(),
          dataType: "json",
          type: "POST",
          beforeSend: function() {
            self.loadingToggle();
          },
          success: function(data) {
            self.loadingToggle();
            if (data.success) {
              $('#slimpay_checkout #step1_section').addClass('hide');
              $('#slimpay_checkout #step2_section').removeClass('hide');
              $('#slimpay_checkout #step1_buttons').addClass('hide');
              if (data.frame_64) {
                var frame = atob(data.frame_64);
                $('#slimpay_checkout #step2_section').html('<div id="checkout_frame_loader" class="feedback active"><span style="margin-left: 40px">Chargement en cours ...</span></div>');
                $('#slimpay_checkout #step2_section').append(frame);
                setTimeout(function() {
                  $('#slimpay_checkout #step2_section #checkout_frame_loader').remove();
                }, 4000);
              } else if (data.redirect_uri) {
                window.location.href = data.redirect_uri;
              } else {
                self.setAlert('Aucune redirection définie', 'alert-danger');
              }
            } else {
              console.error(data.message);
              self.setAlert(data.message, 'alert-danger');
            }
          },
          error: function(data) {
            self.loadingToggle();
            console.error(data);
            self.setAlert('Internal serveur error', 'alert-danger');
          }
        });
      }
    });
  }


  hiddenModal() {
    $('#slimpay_checkout').on('hidden.bs.modal', function(e) {
      var self = this;
      var id = $('#slimpay_checkout_form #organization_id').val();
      var url = "/organizations/" + id + "/confirm_payment";
      return $.ajax({
        url: url,
        dataType: "json",
        type: "POST",
        beforeSend: function() {
          $('#payments #payment_configuration_checker').removeClass('hide');
        },
        success: function(data) {
          $('#payments #payment_configuration_checker').addClass('hide');
          if (data.success) {
            if (data.debit_mandate['transactionStatus'] === 'success') {
              $('#payments td#debit_state').html('<span class="badge badge-success fs-origin">OK</span>');
            } else if (data.debit_mandate['transactionStatus'] === 'started') {
              $('#payments td#debit_state').html('<span class="badge badge-warning fs-origin">En attente utilisateur ...</span>');
            } else {
              $('#payments td#debit_state').html('<span class="badge badge-secondary fs-origin">Non configuré</span>');
              self.resetForm();
            }
            $('#payments td#debit_bic').html(data.debit_mandate.bic);
            $('#payments td#debit_name').html(data.debit_mandate.title + ' ' + data.debit_mandate.firstName + ' ' + data.debit_mandate.lastName);
            $('#payments td#debit_email').html(data.debit_mandate.email);
          }
        },
        error: function() {
          $('#payments #payment_configuration_checker').addClass('hide');
          $('#payments td#debit_state').html("<span class='badge badge-danger fs-origin'>Une erreur inattendue s'est produite, Veuillez réessayer ultérieurement.</span>");
        }
      });
    });
  }

}

class Organization {
  constructor () {}

  edit() {
    $('.valid-modification').unbind('click');
    $(".valid-modification").bind('click', function(e) {
      e.preventDefault();
      $('#general-modal').modal('show');
      $('#general-modal .valid').unbind('click');
      $('#general-modal .valid').bind('click', function(event) {
        $('form#edit-organization').submit();
      });
    });
  }
}


jQuery(function () {
  var organization = new Organization();
  organization.edit();

  var payment = new Payment();
  payment.submitSlimpay();
  payment.hiddenModal();
});