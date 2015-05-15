/**
 * Created on 9/2/2014.
 */

$(function () {
    $('input[name=username]').on('change', function () {
        var $this = $(this),
            // Should match dkobo/koboform/forms.py
            pattern = /^[a-z][a-z0-9_]*$/,
            is_valid = pattern.test($this.val());

        var $form = $this.parents('form');

        $form.find('.error-message').remove();
        if (!is_valid) {
            $form.find('input[type=submit]').prop('disabled', true);
            var $div = $('<span>');
            $div.addClass('error-message');
            $div.text('A username may only contain lowercase letters, numbers, and underscores (_).');
            $div.insertAfter($this);
        } else {
            $form.find('input[type=submit]').prop('disabled', false);
        }
    });
});
