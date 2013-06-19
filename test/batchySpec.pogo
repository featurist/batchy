batchy = require '..'

describe 'batchy'
    negate = nil
    batches = nil
    async negate = nil

    delay! (n) = set timeout (continuation, n)

    (a) to (b) =
        items = []

        if (a < b)
            for (p = a, p <= b, ++p)
                items.push (p)
        else
            for (n = a, n >= b, --n)
                items.push (n)

        items

    with options (options) =
        before each
            batches := []

            negate := batchy @(items)
                batches.push (items)
                items.map @(item) @{ -item }
            (options)

            async negate := batchy @(items)
                delay! 0
                batches.push (items)
                items.map @(item) @{ -item }
            (options)

    with no options () = with options (nil)

    it creates a new batch every (ms)ms =
        it "creates a new batch every #(ms)ms"
            first batch = [negate? (n), where: n <- [1, 2, 3]]

            delay! (ms)

            second batch = [negate? (n), where: n <- [4, 5, 6]]
            negatives = [f!, where: f <- first batch].concat [f!, where: f <- second batch]

            batches.should.eql [[1, 2, 3], [4, 5, 6]]
            negatives.should.eql (-1 @to -6)

        it "doesn't create a new batch if requests are made in less than #(ms)ms"
            first batch = [negate? (n), where: n <- [1, 2, 3]]

            delay! (ms - 10)

            second batch = [negate? (n), where: n <- [4, 5, 6]]
            negatives = [f!, where: f <- first batch].concat [f!, where: f <- second batch]

            batches.should.eql [[1, 2, 3, 4, 5, 6]]
            negatives.should.eql (-1 @to -6)

    it creates a new batch every (x) items =
        it "creates a new batch every #(x) items"
            batch = [negate? (n), where: n <- (1 @to (2 * x))]

            negatives = [f!, where: f <- batch]

            batches.should.eql [(1 @to x), ((x + 1) @to (2 * x))]

            negatives.should.eql (-1 @to (-2 * x))
        

    it can map one or more items () =
        it 'can map one item'
            negate! 1.should.equal (-1)
            batches.should.eql [[1]]

        it 'can map several items'
            futures = [negate? (n), where: n <- [1, 2, 3]]
            negatives = [f!, where: f <- futures]

            batches.should.eql [[1, 2, 3]]
            negatives.should.eql [-1, -2, -3]

        it 'can map several items with async mapper'
            futures = [async negate? (n), where: n <- [1, 2, 3]]
            negatives = [f!, where: f <- futures]

            batches.should.eql [[1, 2, 3]]
            negatives.should.eql [-1, -2, -3]

    context 'default options'
        with no options ()
        it can map one or more items ()
        it creates a new batch every 140ms
        it creates a new batch every 10 items

    context 'with batch timeout 30ms'
        with options (timeout: 30)
        it can map one or more items ()
        it creates a new batch every 30ms
        it creates a new batch every 10 items

    context 'with batch size of 20'
        with options (size: 20)
        it can map one or more items ()
        it creates a new batch every 140ms
        it creates a new batch every 20 items
