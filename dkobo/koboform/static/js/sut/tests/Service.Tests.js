/*global describe*/
/*global it */
/*global expect*/
/*global RouteToService*/
/*global sinon*/
'use strict';

describe('RouteTo Service', function () {
    describe('forms method', function () {
        it('should redirect to "/forms" page', function () {
            var location = {
                path: sinon.spy()
            };

            var router = new RouteToService(location);
            router.forms();

            expect(location.path).toHaveBeenCalledOn(location);
            expect(location.path).toHaveBeenCalledWith('/forms');
        });
    });
});