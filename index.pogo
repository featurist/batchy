delay! (n) = set timeout (continuation, n)

module.exports (process batch, timeout: 140, size: 10) =
    invocations = []

    run batch () =
        if (invocations.length > 0)
            batch = invocations
            invocations := []

            notify results (error, results) =
                for (n = 0, n < batch.length, ++n)
                    invocation = batch.(n)
                    result = results.(n)

                    invocation.continuation (error, result)

            if (process batch.length == 1)
                try
                    results = process batch [inv.item, where: inv <- batch]
                    notify results (nil, results)
                catch (error)
                    notify results (error)
            else
                process batch [inv.item, where: inv <- batch] @(error, results)
                    notify results (error, results)

    batch item (item, callback) =
        invocations.push {item = item, continuation = callback}

        if (invocations.length >= size)
            run batch ()

        delay (timeout)
            run batch ()
