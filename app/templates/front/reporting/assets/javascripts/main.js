//= require './events'
//= require './statistics'

// TODO - LOADER TO CLASS
function load_reporting_invoices(){
  let applicationJS = new ApplicationJS();

  // console.log($('.reporting #customer_filter').val());
  let customers_ids   = $('.reporting #customer_filter').val();
  let ajax_params = {
                      url: `/reporting/invoices`,
                      type: 'POST',
                      data : `ids=${customers_ids}`,
                      dataType: 'html',
                    }

  VARIABLES['reporting_loading']++;
  applicationJS.sendRequest(ajax_params).then(e=>{ 
    $('.reporting #invoices').html(e);

    VARIABLES['reporting_loading']--;
    if(VARIABLES['reporting_loading'] <= 0){
      VARIABLES['reporting_loading'] = 0;
      VARIABLES['reporting_customer_change'] = false;
      AppToggleLoading('hide');
    }
  });
}

function handle_customer_change(statistics){
  if(!VARIABLES['reporting_customer_change'])
  {
    VARIABLES['reporting_customer_change'] = true;
    setTimeout(()=>{
      AppToggleLoading('show');

      load_reporting_invoices();
      statistics.load_all();

    }, 2000);
  }
}


jQuery(function() {
  let statistics  = new ReportingStatistics();

  VARIABLES['reporting_loading'] = 0;
  VARIABLES['reporting_customer_change'] = false;

  handle_customer_change(statistics);
  AppListenTo('reporting_load_all', (e)=>{ handle_customer_change(statistics); });
});
