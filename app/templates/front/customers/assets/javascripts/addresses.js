class Address {

  constructor(){
    this.applicationJS = new ApplicationJS;;
    this.address_id = $('input:hidden[name="address_id"]').val();
  }

  update_form(){
    if ($('#address.new #check-dematbox-shipping, .dematbox_shipping_content #check-dematbox-shipping').is(':checked')){
      $('#address.new label[for=address_company], .dematbox_shipping_content label[for=address_company]').html('<abbr title="champ requis">*</abbr> Société');
      $('#address.new .dematbox_only, .dematbox_shipping_content .dematbox_only').show();
      $('#address_company_number').focus();
    }
    else{
      $('#address.new label[for=address_company], .dematbox_shipping_content label[for=address_company]').html('Société');
      $('#address.new .dematbox_only, .dematbox_shipping_content .dematbox_only').hide();
    }
  }


}

jQuery(function() {
  let address = new Address();

  if ($('#address.new #check-dematbox-shipping, .dematbox_shipping_content #check-dematbox-shipping').length > 0) {
    address.update_form();
    $('#address.new #check-dematbox-shipping, .dematbox_shipping_content #check-dematbox-shipping').unbind('change').bind('change', function(e) {
      e.stopPropagation();
      address.update_form();
    });

  }
});