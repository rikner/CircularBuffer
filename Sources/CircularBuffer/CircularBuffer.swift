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

    func hasCapacity(for count: Int) -> Bool {
        if isFull {
            return false
        }
        return remainingElementsToWrite >= count
    }

    var remainingElementsToWrite: Int {
        if isFull { return 0 }
        if writeIndex < readIndex {
            return readIndex - writeIndex
        } else {
            return (store.count - writeIndex) + readIndex
        }
    }

    var remainingElementsToRead: Int  {
        if isEmpty { return store.count }
        if readIndex < writeIndex {
            return writeIndex - readIndex
        } else {
            return (store.count - readIndex) + writeIndex
        }
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

    @discardableResult
    mutating func write(_ elements: [Numeric]) -> Bool {
        guard hasCapacity(for: elements.count) else {
            return false
        }

        // TODO: use subscript with ranges instead forEach
        elements.forEach {
            write($0)
        }
        
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

    mutating func readAll() -> [Numeric] {
        if isEmpty {
            return []
        }

        let result: [Numeric]
        if readIndex < writeIndex {
            result = Array(store[readIndex ..< writeIndex])
        } else {
            result = Array(store[readIndex...]) + Array(store[..<writeIndex])
        }

        defer {
            readIndex = (readIndex + result.count) % store.count
        }

        return result
    }
}
