var system = require('system');

var page = require('webpage').create();

page.onAlert = function(msg) {
  console.log(msg);
};

page.open('http://127.0.0.1:8111/mnt', function(status) {
  if(status == 'success') {

    page.evaluate(function() {
      window.console.log = function(msg) { alert(msg) }; 
      
      console.log(document.title)

      if(document.getElementById('proceedButton') !== null){
        document.getElementById('proceedButton').click(function(){
          console.log("Proceed button pressed")
          setTimeout(function(){}, 2000);
        })
      }
      
      if(document.getElementById('doUpgrade') !== null){
        document.getElementById('doUpgrade').click(function(){
          console.log("Upgrade button pressed")
          setTimeout(function(){}, 2000);
        })
      }

    });
  } else {
    console.log("Error: Teamcity server not found")
  }
  setTimeout(function(){
    phantom.exit();
  }, 10000);
});