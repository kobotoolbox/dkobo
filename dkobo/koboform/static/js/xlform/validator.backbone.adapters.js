_.extend(Backbone.Validation.validators, {
    invalidChars: function (value, attr, customValue, model) {
        if(viewUtils.Validator.__validators.invalidChars(value, customValue)){
            return;
        }
        return value + 'contains invalid characters';
    },
    unique: function (value, attr, customValue, model) {
        var values = _.map(
            model.getSurvey().rows.pluck(model.key), 
            function (rd) { 
                return rd.get('value'); 
            });


        if(viewUtils.Validator.__validators.unique(value, values)) {
            return;
        }
        return "Question name isn't unique";
    }
});