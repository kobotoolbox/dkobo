define('backbone', [], function(){
  if(!window.Backbone) {
    console && console.error("Backbone has not been loaded into the page. Library will not work properly.")
  }
  return window.Backbone;
});
