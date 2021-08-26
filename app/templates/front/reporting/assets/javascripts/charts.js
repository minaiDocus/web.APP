class ReportingCharts{
  flow_chart(data = {}){
    let chart_flux_document = $('#chart_flux_document')[0].getContext('2d');

    let mychart_2 = new Chart(chart_flux_document,
      {
        type: 'bar',
        data: {
          labels: data['range_date'],
          datasets: [
            {
              label: "TODO(info)",
              backgroundColor: ["#C1D837", "#C1D837","#C1D837","#C1D837","#C1D837","#C1D837","#C1D837"],
              data: data['pieces_count']
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

  delivery_account_chart(data = {}){
    let chart_sending = $('#chart_sending')[0].getContext('2d');

    let mychart = new Chart(chart_sending,
      {
        type: 'pie',
        data: {
          labels: data['labels'],
          datasets: [{
            label: 'My First Dataset',
            data: data['counts'],
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

  retrievers_chart(data = {}){
    let retrievers_data = (labelName, valueData, backgroundColorValue, hoverBackgroundColorValue) => {
      return  {
                labels: labelName,
                datasets: [{
                            data: valueData,
                            backgroundColor: backgroundColorValue,
                            hoverBackgroundColor: hoverBackgroundColorValue,
                            borderWidth: [0, 0]
                          }]
              };
    }

    let labelName = ['Automates actifs'];
    let valueData = [data['actif_percentage'], data['error_percentage']];
    let backgroundColorValue = ["#3ec556", "#EEF8B8"];
    let hoverBackgroundColorValue = ["#3ec556", "#EEF8B8"];

    let activeRetrieversData = retrievers_data(labelName, valueData, backgroundColorValue, hoverBackgroundColorValue);


    labelName = ['Automates en panne'];
    valueData = [data['error_percentage'], data['actif_percentage']];
    backgroundColorValue = ["#FF4848", "#FFE7E7"];
    hoverBackgroundColorValue = ["#FF4848", "#FFE7E7"];

    let failedRetrieversData = retrievers_data(labelName, valueData, backgroundColorValue, hoverBackgroundColorValue);

    $('label.actif_retrievers_percentage').text(data['actif_percentage'] + '%');
    $('label.failed_retrievers_percentage').text(data['error_percentage'] + '%');

    $('#chart_retriever_active').append('<span>AAAAA</span>')

    let retrieversOptions = {
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

   let chart = new Chart($('#chart_retriever_active')[0].getContext('2d'), {
      type: 'doughnut',
      data: activeRetrieversData,
      options: retrieversOptions
    });

   let chart2 = new Chart($('#chart_retriever_inactive')[0].getContext('2d'), {
      type: 'doughnut',
      data: failedRetrieversData,
      options: retrieversOptions
    });
  }
}