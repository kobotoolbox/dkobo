/*global describe*/
/*global it */
/*global expect*/
/*global userDetailsFactory*/
/*global sinon*/
/*global restApiFactory*/
'use strict';

describe('userDetails Factory', function () {
    it ('should return the value of window.userDetails', function () {
        window.userDetails = {};
        expect(userDetailsFactory()).toBe(window.userDetails);
    });
});

describe('restApi Factory', function () {
    describe('createSurveyDraftApi', function () {
        it ('should invoke $resource with an empty object when no id is provided', function () {
            var resourceSpy = sinon.spy();

            var factory = restApiFactory(resourceSpy);

            factory.createSurveyDraftApi();

            expect(resourceSpy).toHaveBeenCalledWith('/koboform/survey_draft/:id', { id: 0 }, {});
        });

        it ('should invoke $resource with a custom save object when an id is provided', function () {
            var resourceSpy = sinon.spy();

            var factory = restApiFactory(resourceSpy);

            factory.createSurveyDraftApi(1);

            expect(resourceSpy).toHaveBeenCalledWith(
                '/koboform/survey_draft/:id',
                { id: 1 },
                { save: { method: 'PUT' } });
        });
    });
});