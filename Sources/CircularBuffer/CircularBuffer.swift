/*
 * fixed size circular buffer
 * not thread-safe
 * uses tail-one-behind-head to check if buffer is full
 */


struct CircularBuffer<Numeric> {
    private(set) var store: [Numeric]
    var readIndex: Int = 0
    var writeIndex: Int = 0

    var isEmpty: Bool {
        return readIndex == writeIndex
    }

    var isFull: Bool {
        return ((writeIndex + 1) % store.count) == readIndex
    }
    
    init(repeating value: Numeric, count: Int) {
        store = Array<Numeric>(repeating: value, count: count + 1)
    }

    @discardableResult
    mutating func write(_ element: Numeric) -> Bool {
        if isFull {
            return false
        }

        defer {
            writeIndex = (writeIndex + 1) % store.count
        }

        store[writeIndex] = element

        return true
    }

    mutating func read() -> Numeric? {
        if isEmpty {
            return nil
        }

        defer {
            readIndex = (readIndex + 1) % store.count
        }

        return store[readIndex]
    }
}
