//= require jquery
//= require jquery_ujs
//= require jquery-ui

//***GLOBALS***
class Test{
  constructor(){
    console.log('yes')
  }

  click_me(){
    $('#testid').html('<a href="#" data-href="/organizations" class="goto_button">Go to organization</a>')
  }
}


jQuery(function () {
  test = new Test()

  test.click_me()
});