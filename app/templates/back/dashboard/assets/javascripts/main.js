//= require './dashboard_charts'

function event(){
  $('.foot-box .label_more_info').unbind('click.animation').bind('click.animation', function(e){
    
    $('.modal#see-more-info .modal-body').html($(this).find(".more-info").html());
    $('.modal#see-more-info').modal('show'); 
  })
}

function load_resources(resources) {
  for(i=0;i<12;i++){
    (function(counter) {
      var resource = resources[counter];
      $.ajax({
        url: '/admin/dashboard/' + resource,
        dataType: 'html',
        type: 'GET',
        success: function (data) {          
          $('.content#'+resource).html(data)
          $('.box.'+ resource + ' label.count.'+ resource).html($('.content#' + resource + ' table').data('total'))
        }
      });
    })(i);
  }
  event();
}

function load_graph_statistic(list_graph, type='bar'){  
  chart = new DashboardCharts(); 

  for(i=0;i<2;i++){
    (function(counter) {
      var graph = list_graph[counter];
      $.ajax({
        url: '/admin/dashboard/' + graph,
        dataType: 'html',
        type: 'GET',
        success: function (data) {
          let _data = JSON.parse(data)
          if (type == 'bar'){
            chart.flow_chart(_data['result'], graph);
          }
          else{
            chart.mixed_chart(_data['result'], graph);
          }
        }
      });
    })(i);
  }
}

function load_graph_bank_operation(){ 
  chart = new DashboardCharts();

  $.ajax({
    url: '/admin/dashboard/bank_operation',
    dataType: 'html',
    type: 'GET',
    success: function (data) {
      let _data = JSON.parse(data);      
      chart.mixed_chart_bo(_data['result']);
    }
  });
}


$(document).ready(function() {
  let resources = [
    'ocr_needed_temp_packs',
    'bundle_needed_temp_packs',
    'processing_temp_packs',
    'currently_being_delivered_packs',
    'failed_packs_delivery',
    'blocked_pre_assignments',
    'awaiting_pre_assignments',
    'reports_delivery',
    'failed_reports_delivery',
    'awaiting_supplier_recognition',
    'awaiting_adr',
    'cedricom_orphans'
  ];  

  let list_graph_bar = [
    'chart_flux_document',
    'document_api'    
  ]
  let list_graph_line = [
    'document_delivery',
    'software_customers'    
  ]

  load_graph_statistic(list_graph_bar, 'bar');
  load_graph_statistic(list_graph_line, 'line');
  load_graph_bank_operation()

  load_resources(resources);

  // var interval_id = setInterval(function(){ load_resources(resources); }, 30000);
});
