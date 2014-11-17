// http://plnkr.co/edit/RamNQ4Km73uG691Ku402?p=preview
// http://stackoverflow.com/a/24051015/1029988

kobo.directive('innerTransclude', function(){
    return function(scope, elem, attrs){
        scope.transclude(scope, function(clone){
            elem.append(clone);
        })
    }
});