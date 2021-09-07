//= require './charts'

class ReportingStatistics {
  constructor(){
    this.applicationJS    = new ApplicationJS();
    this.chart            = new ReportingCharts();

    this.data_params   = {};
  }

  load_all(){
    this.data_params =  {
                          json_type: { ids: $('#customer_filter').val(), date_range: $('#date_filter').val() },
                          html_type: `ids=${encodeURIComponent($('#customer_filter').val())}&date_range=${$('#date_filter').val()}`,
                        }

    this.injected_documents();
    this.pre_assignment_accounts();
    this.retrievers_report();
  }

  finalize_loading(){
    VARIABLES['reporting_loading']--;
    if(VARIABLES['reporting_loading'] <= 0){
      VARIABLES['reporting_loading'] = 0;
      VARIABLES['reporting_customer_change'] = false;
      AppToggleLoading('hide');
    }
  }

  injected_documents(){
    //data chart fetching
    let ajax_params = {
                        url: '/reporting/injected_documents',
                        type: 'POST',
                        dataType: 'json',
                        data: this.data_params.json_type
                      }
    VARIABLES['reporting_loading']++;
    this.applicationJS.parseAjaxResponse(ajax_params).then((res)=>{ this.chart.flow_chart(res); this.finalize_loading(); });

    //html table fetching
    let ajax_params2 =  {
                          url: '/reporting/injected_documents',
                          type: 'POST',
                          data: this.data_params.html_type
                        }
    VARIABLES['reporting_loading']++;
    this.applicationJS.parseAjaxResponse(ajax_params2).then((e)=>{ $('#lastest_sending_docs').html(e); this.finalize_loading(); });
  }

  pre_assignment_accounts(){
    //data chart fetching
    let ajax_params = {
                        url: '/reporting/pre_assignment_accounts',
                        type: 'POST',
                        dataType: 'json',
                        data: this.data_params.json_type
                      }
    VARIABLES['reporting_loading']++;
    this.applicationJS.parseAjaxResponse(ajax_params).then((res)=>{ this.chart.delivery_account_chart(res); this.finalize_loading(); });

    //html table fetching
    let ajax_params2 =  {
                          url: '/reporting/pre_assignment_accounts',
                          type: 'POST',
                          data: this.data_params.html_type
                        }
    VARIABLES['reporting_loading']++;
    this.applicationJS.parseAjaxResponse(ajax_params2).then((e)=>{ $('#pre_assignment_accounts').html(e); this.finalize_loading(); });
  }

  retrievers_report(){
    //data chart fetching
    let ajax_params = {
                        url: '/reporting/retrievers_report',
                        type: 'POST',
                        dataType: 'json',
                        data: this.data_params.json_type
                      }
    VARIABLES['reporting_loading']++;
    this.applicationJS.parseAjaxResponse(ajax_params).then((res)=>{ this.chart.retrievers_chart(res); this.finalize_loading();});

    //html table fetching
    let ajax_params2 =  {
                          url: '/reporting/retrievers_report',
                          type: 'POST',
                          data: this.data_params.html_type
                        }
    VARIABLES['reporting_loading']++;
    this.applicationJS.parseAjaxResponse(ajax_params2).then((e)=>{ $('#failed_retrievers').html(e); this.finalize_loading(); });
  }
}