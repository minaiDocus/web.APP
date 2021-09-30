//=require './events'
//**** File Sending kits JS *******/
//=require '../../../file_sending_kits/assets/javascripts/events'
//=require './order'


jQuery(function () {
  let order = new Order();

  if ($('#order form, form#new_edit_order_customer').length > 0){
    order.update_casing_counts();
    order.update_price();
  }

  AppListenTo('update_casing_counts', (e)=>{ order.update_casing_counts(); });
  AppListenTo('update_price', (e)=>{ order.update_price(); });
  AppListenTo('check_casing_size_and_count', (e)=>{ order.check_casing_size_and_count(); });

  AppListenTo('new_edit_order_view', (e)=>{ order.new_edit_order_view(e.detail.url); });
  AppListenTo('rebind_order_events', (e)=>{ bind_all_events_order(); });

  AppListenTo('select_for_orders', (e)=>{ order.select_for_orders(e.detail.url); });
  AppListenTo('handle_select_for_orders_result', (e)=>{ order.handle_select_for_orders_result(e.detail.response); });

  AppListenTo('edit_file_sending_kits_view', (e)=>{ order.edit_file_sending_kits_view(e.detail.url); });
});