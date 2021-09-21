//=require './events'
//=require './order'


jQuery(function () {
  let order = new Order();

  if ($('#order form').length > 0){
    order.update_casing_counts();
    order.update_price();
  }

  AppListenTo('update_casing_counts', (e)=>{ order.update_casing_counts(); });
  AppListenTo('update_price', (e)=>{ order.update_price(); });
  AppListenTo('check_casing_size_and_count', (e)=>{ order.check_casing_size_and_count(); });
});