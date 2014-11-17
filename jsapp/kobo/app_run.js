kobo.run(function ($http, $cookies, $miscUtils) {
    $http.defaults.headers.common['X-CSRFToken'] = $cookies.csrftoken;
    $(function () {
        $('.alert-modal').dialog({
            autoOpen: false,
            modal: true
        });

        // forms__list poshytip effect on publish button
        $('.forms__poshytip').poshytip({
            className: 'tip__rightarrow',
            showTimeout: 1,
            alignTo: 'target',
            offsetX: 10,
            offsetY: -16,
            liveEvents: true
        });

        // question mark poshytip effect (in form__settings)
        $('span.poshytip').poshytip({
            className: 'tip__bottomarrow',
            showTimeout: 1,
            alignTo: 'target',
            alignX: 'right',
            alignY: 'inner-bottom',
            liveEvents: true
        });
    });
    // jQuery.fileupload for importing forms to the user's form list.
});