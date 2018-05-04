/*
 * fixed size circular buffer
 * not thread-safe
 * uses empty flag with additional logic to check if buffer is full or empty
 */

public struct CircularBuffer<Numeric> {
    private(set) var store: [Numeric]
    private var empty: Bool
    var readIndex: Int = 0
    var writeIndex: Int = 0

    var isEmpty: Bool {
        return (readIndex == writeIndex) && empty
    }

    var isFull: Bool {
        return (readIndex == writeIndex) && !empty
    }

    public init(repeating value: Numeric, count: Int) {
        store = Array<Numeric>(repeating: value, count: count)
        empty = true
    }

    init(from array: [Numeric], readIndex: Int, writeIndex: Int, empty: Bool = false) {
        self.store = array
        self.readIndex = readIndex
        self.writeIndex = writeIndex
        self.empty = empty
    }

    public func hasCapacity(for count: Int) -> Bool {
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
    public mutating func write(_ element: Numeric) -> Bool {
        if isFull {
            return false
        }

        defer {
            writeIndex = (writeIndex + 1) % store.count
            empty = false
        }

        store[writeIndex] = element

        return true
    }

    @discardableResult
    public mutating func write(_ elements: [Numeric]) -> Bool {
        guard hasCapacity(for: elements.count) else {
            return false
        }

        // TODO: use subscript with ranges instead forEach
        elements.forEach {
            write($0)
        }
        
        return true
    }

    public mutating func read() -> Numeric? {
        if isEmpty {
            return nil
        }

        defer {
            readIndex = (readIndex + 1) % store.count
            if readIndex == writeIndex {  // may be empty after reading one element
                empty = true
            }
        }

        return store[readIndex]
    }

    public mutating func readAll() -> [Numeric] {
        if isEmpty {
            return []
        }
        
        /*
         * version using read()
         */
        var result: [Numeric] = []
        while let data = read() {
            result.append(data)
        }
        
        return result
        
        
        /*
         * version using subscripts (probably faster)
         */

        // let result: [Numeric]
        // if readIndex < writeIndex {
        //     result = Array(store[readIndex ..< writeIndex])
        // } else {
        //     result = Array(store[readIndex...]) + Array(store[..<writeIndex])
        // }

        // defer {
        //     readIndex = (readIndex + result.count) % store.count
        //     empty = true // must always be empty after reading all elements
        // }

        // return result
    }
}
