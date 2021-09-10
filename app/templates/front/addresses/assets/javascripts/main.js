class AddressesMain{
  constructor(){
    this.applicationJS = new ApplicationJS();
  }

  update_addresses(){
    let addr_for = $('#addresses_management input#addr_for').val();
    let id       = $('#addresses_management input#addr_id').val();

    let paper_return       = SerializeToJson( $('#addresses_management form.paper_return_form') );
    let paper_set_shipping = SerializeToJson( $('#addresses_management form.paper_set_shipping_form') );
    let dematbox_shipping  = SerializeToJson( $('#addresses_management form.dematbox_shipping_form') );

    let ajax_params = {
                        url: '/addresses/update_all',
                        type: 'POST',
                        dataType: 'json',
                        data: { id: id, addr_for: addr_for, paper_return: paper_return, paper_set_shipping: paper_set_shipping, dematbox_shipping: dematbox_shipping },
                      };
    this.applicationJS.parseAjaxResponse(ajax_params);
  }

  destroy_address(elem){  
    let id   = elem.data('id');
    let type = elem.data('type');

    if( id > 0 && confirm("Êtes-vous sûr de vouloir supprimer cette adresse ?") )
    {
      let ajax_params = {
                          url: `/addresses/destroy/${id}`,
                          type: 'DELETE',
                          dataType: 'json',
                        };
      this.applicationJS.parseAjaxResponse(ajax_params)
                        .then((e)=>{ 
                          $(`#addresses_management form.${type}_form input`).each(function(a){
                            $(this).val('');
                          });
                          elem.remove();
                        });
    }
  }
}


jQuery(function() {
  let main = new AddressesMain();

  $('#addresses_management .update_addresses').unbind('click').bind('click', (e)=>{ main.update_addresses() });
  $('#addresses_management .destroy_address').unbind('click').bind('click', function(e){ main.destroy_address($(this)) });
});