//= require jquery
//= require jquery_ujs
//= require jquery-ui

jQuery(function () {

  var organization_options = JSON.parse($('#organization_options').val() || '{}');

  var chart_abonnement = document.getElementById('chart_abonnement').getContext('2d')

  var mychart = new Chart(chart_abonnement, {type: 'pie', data: {
    labels: [
      "iDo'Micro",
      "iDo'Nano",
      "iDo'X",
      "iDo'Classique",
      "Automate"
    ],
    datasets: [{
      label: 'My First Dataset',
      data: [organization_options.micro_package, organization_options.nano_package, organization_options.idox_package, organization_options.basic_package, organization_options.retriever_package],
      backgroundColor: [
        '#72AA42',
        '#C1E637',
        '#C1D837',
        '#445E2B',
        '#1A1A1A'
      ]
    }]
  }, options: {
     title: {
        display: false,
        fontsize: 17,
        text: 'Répartition des abonnements',
        align: 'start'
    },
    legend: {
      display: false 

    }
  }

  });

  var chart_dossiers = document.getElementById('chart_dossiers').getContext('2d')  

  var mychart_2 = new Chart(chart_dossiers, {type: 'line', data: {
    labels: ['Jan', 'Fev', 'Mar', 'Avr', 'Mai', 'Jui', 'Jul', 'Aou', 'Sep', 'Oct', 'Nov', 'Dec'],
    datasets: [{      
      data: [65, 59, 80, 81, 56, 55, 40, 25, 87, 45, 32, 49],
      fill: false,
      borderColor: '#72AA42',      
      backgroundColor: 'rgba(75, 192, 192, 0.2)',   
      tension: 0.1
    }]
  }, options: {
     title: {
        display: false,
        fontsize: 17,
        text: 'Evolution du nombre de dossiers',
        align: 'start'
    },
      legend: {
        display: false 

      }
  }
  });
});