/*
 * fixed size circular buffer
 * not thread-safe
 * uses an 'empty' flag with additional logic to check if buffer is full or empty
 * does not overwrite data which has not been read yet
 */

public struct CircularBuffer<Numeric> {
    private(set) var store: [Numeric]
    private var empty: Bool // only set to true on init and when reading, only set to false when writing
    private(set) var readIndex: Int = 0
    private(set) var writeIndex: Int = 0

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

    /// only used for tests to setup use-cases more faster
    init(from array: [Numeric], readIndex: Int, writeIndex: Int, empty: Bool = false) {
        assert(readIndex < array.count, "readIndex must be smaller than array length")
        assert(writeIndex < array.count, "writeIndex must be smaller than array length")
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

    public mutating func read() -> Numeric? {
        if isEmpty {
            return nil
        }

        defer {
            readIndex = (readIndex + 1) % store.count
            if readIndex == writeIndex {
                empty = true
            }
        }

        return store[readIndex]
    }
}


// MARK: Read / Write Array
extension CircularBuffer {

    /// read all remaining data from the buffer
    public mutating func readAll() -> [Numeric] {
        if isEmpty {
            return []
        }

        defer {
            readIndex = (readIndex + remainingElementsToRead) % store.count
            empty = true // must always be empty after reading all elements
        }

        if readIndex < writeIndex {
            return Array(store[readIndex ..< writeIndex])
        } else {
            return Array(store[readIndex...]) + Array(store[..<writeIndex])
        }
    }

    /// write an array to the buffer
    @discardableResult
    public mutating func write(_ elements: [Numeric]) -> Bool {
        guard hasCapacity(for: elements.count) else {
            return false
        }

        defer {
            writeIndex = (writeIndex + elements.count) % store.count
            empty = false
        }

        if writeIndex < readIndex {
            store[writeIndex ..< readIndex] = ArraySlice(elements)
        } else {
            store[writeIndex...] = ArraySlice(elements.prefix(store.count - writeIndex))
            store[..<readIndex] = ArraySlice(elements.suffix(readIndex))
        }

        return true
    }

}
