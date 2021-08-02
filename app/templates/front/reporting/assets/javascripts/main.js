class ReportingMain {
  constructor(){   
  }

  reportingFlowChart(){
    var chart_flux_document = $('#chart_flux_document')[0].getContext('2d');

    var mychart_2 = new Chart(chart_flux_document,
      {
        type: 'bar',
        data: {
          labels: ["19/11", "20/11", "21/11", "22/11", "23/11", "24/11", "25/11"],
          datasets: [
            {
              label: "TODO(info)",
              backgroundColor: ["#C1D837", "#C1D837","#C1D837","#C1D837","#C1D837","#C1D837","#C1D837"],
              data: [47,56,79,67,56,68,85]
            }
          ]
        },
        options: {
          legend: { display: false },
          title: {
            display: true,
            text: 'Nombre de documents par jour',
            align: 'end',
            position: 'top'
          }
        }
    });
  }

  reportingDeliveryAccountChart(){
    var chart_sending = $('#chart_sending')[0].getContext('2d');

    var mychart = new Chart(chart_sending,
      {
        type: 'pie',
        data: {
          labels: [
            "1",
            "2",
            "3",
            "4"
          ],
          datasets: [{
            label: 'My First Dataset',
            data: [200, 150, 50, 50],
            backgroundColor: [
              '#72AA42',
              '#C1E637',
              '#C1D837',
              '#445E2B'
            ]
          }]
        },
        options: {
         title: {
            display: false,
            fontsize: 17,
            text: 'TODOreporting....',
            align: 'start'
          },
          legend: {
            display: false 

          }
        }
    });
  }

  reportingRetrieversData(label_name, valueData, backgroundColorValue, hoverBackgroundColorValue){
    var retrieversData = {
      labels: label_name,
      datasets: [
          {
            data: valueData,
            backgroundColor: backgroundColorValue,
            hoverBackgroundColor: hoverBackgroundColorValue,
            borderWidth: [
                0, 0
            ]
          }]
    };

    

    return retrieversData;
  }

  reportingRetrieversChart(){
    var label_name = ['Automates actifs'];
    var valueData = [60, 40];
    var backgroundColorValue = ["#3ec556", "#EEF8B8"];
    var hoverBackgroundColorValue = ["#3ec556", "#EEF8B8"];

    var activeRetrieversData = this.reportingRetrieversData(label_name, valueData, backgroundColorValue, hoverBackgroundColorValue);


    label_name = ['Automates en panne'];
    valueData = [40, 60];
    backgroundColorValue = ["#FF4848", "#FFE7E7"];
    hoverBackgroundColorValue = ["#FF4848", "#FFE7E7"];

    var failedRetrieversData = this.reportingRetrieversData(label_name, valueData, backgroundColorValue, hoverBackgroundColorValue);

    var retrieversOptions = {
      cutoutPercentage: 88,
      radius: 500,
      animation: {
          animationRotate: true,
          duration: 2000
      },
      legend: {
        display: false,
        // position:'bottom',
        // align:'center'
      },
      tooltips: {
          enabled: false
      }
    };

   var chart = new Chart($('#chart_retriever_active')[0].getContext('2d'), {
        type: 'doughnut',
        data: activeRetrieversData,
        options: retrieversOptions
    });

   var chart2 = new Chart($('#chart_retriever_inactive')[0].getContext('2d'), {
        type: 'doughnut',
        data: failedRetrieversData,
        options: retrieversOptions
    });
  }
}

jQuery(function() {
  $('.daterange').daterangepicker({
    "autoApply": true,
    linkedCalendars: false,
    locale: {
      format: 'DD/MM/YYYY'
    }
  });

  $('#customer_filter').multiSelect({
    "noneText": "Filtre par dossier"
  });

  let main = new ReportingMain();
  main.reportingFlowChart();
  main.reportingDeliveryAccountChart();
  main.reportingRetrieversChart();
});
