kobo.filter('itemFilter',[function () {
    var filterFn = function (item, filter) {
        try {
            if (typeof filter === 'string') {
                var filterValues = filter.split(' ');
                for (var i = 0; i < filterValues.length; i++) {
                    if (item.toLowerCase().indexOf(filterValues[i].toLowerCase()) === -1) {
                        return false;
                    }
                }
            } else if (filter instanceof Array) {
                for (i = 0; i < filter.length; i++) {
                    if (item.indexOf(filter[i]) === -1) {
                        return false;
                    }
                }
            }
        } catch(e) {
            window.console && window.console.error && window.console.error("Cannot call filterFn on item: ", item);
            return false;
        }
        return true;
    };

    return function (items, props) {
        var out = [],
            keys = Object.keys(props);

        if (angular.isArray(items)) {
            for (var i = 0; i < items.length; i++) {
                var currentItem = items[i],
                    includeCurrentItem = true;

                for (var j = 0; j < keys.length; j++) {
                    var currentKey = keys[j];
                    if (!(includeCurrentItem = filterFn(currentItem[currentKey] || '', props[currentKey]))) {
                        break;
                    }
                }
                if (includeCurrentItem) {
                    out.push(currentItem);
                }
            }
        } else {
            out = items;
        }

        return out;
    }
}]);