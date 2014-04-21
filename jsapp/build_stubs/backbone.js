define('backbone', [], function(){
  if(!this.Backbone) {
    console && console.error("Backbone has not been loaded into the page. Library will not work properly.")
  }
  return this.Backbone;
});
