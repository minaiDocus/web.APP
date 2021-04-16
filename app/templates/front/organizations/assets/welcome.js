//= require jquery
//= require jquery_ujs
//= require jquery-ui

//***GLOBALS***
class Test{
  constructor(){
    console.log(window.GLOBALS.test_variable)
  }

  click_me(){
    $('#testid').html('<a href="#" data-href="/dashboard" class="goto_button">Go to dashboard</a>')
  }
}

jQuery(function () {
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
      data: [200, 150, 50, 50, 50],
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