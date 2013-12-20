describe('RouteTo Service', function () {
    describe('forms method', function () {
        it('should redirect to "/forms" page', function () {
            var location = {
                path: sinon.spy()
            };

            router = new RouteToService(location);
            router.forms();

            expect(location.path).toHaveBeenCalledOn(location);
            expect(location.path).toHaveBeenCalledWith('/forms');
        });
    });
});