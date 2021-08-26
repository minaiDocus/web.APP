//= require './events'
//= require './charts'

class ReportingMain {
  constructor(){
    this.applicationJS    = new ApplicationJS();
    this.chart            = new ReportingCharts();

    this.data_params   = {};
    this.change_locker = false;
  }

  handle_customer_change(){
    self = this;
    if(!this.change_locker){
      this.change_locker = true;
      setTimeout(()=>{ self.load_all(); }, 2000);
    }
  }

  load_all(){
    this.data_params =  {
                          json_type: { ids: $('#customer_filter').val(), date_range: $('#date_filter').val() },
                          html_type: `ids=${encodeURIComponent($('#customer_filter').val())}&date_range=${$('#date_filter').val()}`,
                        }

    this.injected_documents();
    this.pre_assignment_accounts();
    this.retrievers_report();

    this.change_locker = false;
  }

  injected_documents(){
    //data chart fetching
    let ajax_params = {
                        url: '/reporting/injected_documents',
                        type: 'POST',
                        dataType: 'json',
                        data: this.data_params.json_type
                      }
    this.applicationJS.parseAjaxResponse(ajax_params).then((res)=>{ this.chart.flow_chart(res); });

    //html table fetching
    let ajax_params2 =  {
                          url: '/reporting/injected_documents',
                          type: 'POST',
                          data: this.data_params.html_type
                        }
    this.applicationJS.parseAjaxResponse(ajax_params2).then((e)=>{ $('#lastest_sending_docs').html(e); });
  }

  pre_assignment_accounts(){
    //data chart fetching
    let ajax_params = {
                        url: '/reporting/pre_assignment_accounts',
                        type: 'POST',
                        dataType: 'json',
                        data: this.data_params.json_type
                      }
    this.applicationJS.parseAjaxResponse(ajax_params).then((res)=>{ this.chart.delivery_account_chart(res); });

    //html table fetching
    let ajax_params2 =  {
                          url: '/reporting/pre_assignment_accounts',
                          type: 'POST',
                          data: this.data_params.html_type
                        }
    this.applicationJS.parseAjaxResponse(ajax_params2).then((e)=>{ $('#pre_assignment_accounts').html(e); });
  }

  retrievers_report(){
    //data chart fetching
    let ajax_params = {
                        url: '/reporting/retrievers_report',
                        type: 'POST',
                        dataType: 'json',
                        data: this.data_params.json_type
                      }
    this.applicationJS.parseAjaxResponse(ajax_params).then((res)=>{ this.chart.retrievers_chart(res); });

    //html table fetching
    let ajax_params2 =  {
                          url: '/reporting/retrievers_report',
                          type: 'POST',
                          data: this.data_params.html_type
                        }
    this.applicationJS.parseAjaxResponse(ajax_params2).then((e)=>{ $('#failed_retrievers').html(e); });
  }
}

jQuery(function() {
  let main = new ReportingMain();

  main.load_all();

  AppListenTo('reporting_load_all', (e)=>{ main.handle_customer_change(); });
});
