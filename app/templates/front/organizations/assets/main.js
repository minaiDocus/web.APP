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
  test = new Test()

  test.click_me()
});