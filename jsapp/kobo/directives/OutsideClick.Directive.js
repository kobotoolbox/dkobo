/// http://vadimpopa.com/onblur-like-for-a-div-in-angularjs-to-close-a-popup/
kobo.directive ('outsideClick', ['$document', function ( $document ){
    return {
        scope: {
            isShowing: '=',
            closeMethod: '&'
        },
        link: function( scope, $element, $attributes ) {
            var scopeExpression = $attributes.outsideClick,
                onDocumentClick = function(event){
                    var isChild = $element.find(event.target).length > 0;

                    if (!scope.isShowing) {
                        if (!isChild) {
                            scope.closeMethod();
                        }
                    } else {
                        scope.isShowing = false;
                    }
                };

            $document.on("click", onDocumentClick);

            $element.on('$destroy', function() {
                $document.off("click", onDocumentClick);
            });
        }
    }
}]);
