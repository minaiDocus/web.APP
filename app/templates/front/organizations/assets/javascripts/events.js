function load_slimpay_step() {
  const loader = $('#slimpay_checkout #step_loader');

  if (loader.hasClass('hide')) {
    $('#slimpay_checkout #step1_buttons').addClass('hide');
    $('#slimpay_checkout #step_loader').removeClass('hide');
  }
  else {
    $('#slimpay_checkout #step1_buttons').removeClass('hide');
    $('#slimpay_checkout #step_loader').addClass('hide');
  }
}

function bind_organization_events() {
  $('.valid-modification').unbind('click').bind('click', function(e) {
    e.preventDefault();
    
    if (confirm('Vous venez de changer les paramètres, voulez-vous enregister les modifications apportées ?')) {
      $('form#organization_edit').submit();
    }
  });

  $('#slimpay_checkout #submitSlimpay').unbind('click').bind('click', function(e) {
    e.preventDefault();
    
    const id = $('#slimpay_checkout_form #organization_id').val();
    let url = "/organizations/" + id + "/prepare_payment";

    load_slimpay_step();
    AppEmit('prepare_payment_slimpay', { url: url, data: $('#slimpay_checkout_form').serialize()});
  });

  $('#slimpay_checkout').on('hidden.bs.modal', function(e) {
    const id = $('#slimpay_checkout_form #organization_id').val();
    let url = "/organizations/" + id + "/confirm_payment";

    $('#payments #payment_configuration_checker').removeClass('hide');
    AppEmit('confirm_payment_slimpay', { url: url });
  });
}


jQuery(function () {
  bind_organization_events();
});