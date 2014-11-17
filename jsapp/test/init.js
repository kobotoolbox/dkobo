/* exported staticFilesUri */
var staticFilesUri = '';

// Taken from http://stackoverflow.com/questions/12025035/use-sinon-js-to-create-a-spy-object-with-spy-methods-based-on-a-real-construct
sinon.stubObject = function (obj, target) {
    var cls = (typeof obj == 'function') ? obj.prototype : obj;
    target = target || {};

    _.forEach(cls, function(p, k) {
        if (cls.hasOwnProperty(k) && typeof cls[k] == 'function') {
            target[k] = sinon.stub()
        }
    });

    return cls.__proto__ ? sinon.stubObject(cls.__proto__, target) : target;
};

require.config({
    baseUrl: '/base/',
    paths: {
        'almond': 'components/almond/almond',
        'cs' :'components/require-cs/cs',
        'coffee-script': 'components/require-cs/coffee-script',

        'jquery': 'components/jquery/dist/jquery.min',
        'backbone': 'components/backbone/backbone',
        'backbone-validation': 'components/backbone-validation/dist/backbone-validation-amd',
        'underscore': 'components/underscore/underscore',

        'xlform': 'xlform_model_view'
    }
});
