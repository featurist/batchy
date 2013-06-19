(function() {
    var self = this;
    var delay;
    delay = function(n, continuation) {
        var gen1_arguments = Array.prototype.slice.call(arguments, 0, arguments.length - 1);
        continuation = arguments[arguments.length - 1];
        if (!(continuation instanceof Function)) {
            throw new Error("asynchronous function called synchronously");
        }
        n = gen1_arguments[0];
        setTimeout(continuation, n);
    };
    module.exports = function(processBatch, gen2_options) {
        var self = this;
        var timeout, size;
        timeout = gen2_options !== void 0 && Object.prototype.hasOwnProperty.call(gen2_options, "timeout") && gen2_options.timeout !== void 0 ? gen2_options.timeout : 140;
        size = gen2_options !== void 0 && Object.prototype.hasOwnProperty.call(gen2_options, "size") && gen2_options.size !== void 0 ? gen2_options.size : 10;
        var invocations, runBatch, batchItem;
        invocations = [];
        runBatch = function() {
            var batch, notifyResults, results;
            if (invocations.length > 0) {
                batch = invocations;
                invocations = [];
                notifyResults = function(error, results) {
                    var n, invocation, result;
                    for (n = 0; n < batch.length; ++n) {
                        invocation = batch[n];
                        result = results[n];
                        invocation.continuation(error, result);
                    }
                    return void 0;
                };
                if (processBatch.length === 1) {
                    try {
                        results = processBatch(function() {
                            var gen3_results, gen4_items, gen5_i, inv;
                            gen3_results = [];
                            gen4_items = batch;
                            for (gen5_i = 0; gen5_i < gen4_items.length; ++gen5_i) {
                                inv = gen4_items[gen5_i];
                                gen3_results.push(inv.item);
                            }
                            return gen3_results;
                        }());
                        return notifyResults(void 0, results);
                    } catch (error) {
                        return notifyResults(error);
                    }
                } else {
                    return processBatch(function() {
                        var gen6_results, gen7_items, gen8_i, inv;
                        gen6_results = [];
                        gen7_items = batch;
                        for (gen8_i = 0; gen8_i < gen7_items.length; ++gen8_i) {
                            inv = gen7_items[gen8_i];
                            gen6_results.push(inv.item);
                        }
                        return gen6_results;
                    }(), function(error, results) {
                        return notifyResults(error, results);
                    });
                }
            }
        };
        return batchItem = function(item, callback) {
            invocations.push({
                item: item,
                continuation: callback
            });
            if (invocations.length >= size) {
                runBatch();
            }
            return delay(timeout, function() {
                return runBatch();
            });
        };
    };
}).call(this);