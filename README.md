# Batchy

Batches asynchronous requests.

# How to explain this?

You might have something like this:

    getUser(1, function (error, user) {
        displayUser(user);
    });

    getUser(2, function (error, user) {
        displayUser(user);
    });

    getUser(3, function (error, user) {
        displayUser(user);
    });

This would ordinarily result in 3 individual calls for users:

    http://.../users/1
    http://.../users/2
    http://.../users/3

But what if you wanted to make just one request, with an API like this:

    http://.../users?id=1&id=2&id=3

Use batchy:

    var getUser = batchy(function (userIds, callback) {
        var ids = userIds.map(function (id) { return 'id=' + id; }).join('&');
        $.get('http://.../users?' + ids)
            .done(function (data) {
                callback(undefined, data);
            })
            .error(function (error) {
                callback(error);
            });
    });

Batchy will batch requests up into groups of 10, or into time segments of 140ms, which ever comes first.

# API

    var mapItem = batchy(map, [options])

where:

* `map(items, callback)` - a function accepting *items* and *callback*. The function is to process the items and call the callback. The result (second argument to *callback*) is the list of mapped items. This function can also be synchronous if you omit the *callback* parameter, in which case just `return` the mapped items.
* `options` - can contain:
    * `size` - the maximum size of each batch (default 10)
    * `timeout` - the maximum time to wait for items to batch (default 140ms)

It returns a new function that looks like this:

    mapItem(item, callback)

where:

* `item` - an item to map
* `callback(error, mappedItem)` - a function that will be called when the item is eventually mapped.
