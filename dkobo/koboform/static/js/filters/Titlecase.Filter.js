function TitlecaseFilter() {
    return function (text) {
        text = text.replace('_', ' ');
        text = text.split(' ');
        for (var i = 0; i < text.length; i++) {
            var word = text[i].split('');
            word[0] = word[0].toUpperCase();
            text[i] = word.join('');
        }

        return text.join(' ');
    }
}