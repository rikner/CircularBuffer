public struct CircularBuffer<Element> {
    private(set) var store: [Element]
    private var empty: Bool // only set to true on init and when reading, only set to false when writing
    private(set) var readIndex: Int = 0
    private(set) var writeIndex: Int = 0

    var isEmpty: Bool {
        return (readIndex == writeIndex) && empty
    }

    var isFull: Bool {
        return (readIndex == writeIndex) && !empty
    }

    public init(repeating value: Element, count: Int) {
        store = Array<Element>(repeating: value, count: count)
        empty = true
    }

    /// only used for tests to setup use-cases more faster
    init(from array: [Element], readIndex: Int, writeIndex: Int, empty: Bool = false) {
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
    public mutating func write(_ element: Element) -> Bool {
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

    public mutating func read() -> Element? {
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
    public mutating func readAll() -> [Element] {
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
    public mutating func write(_ elements: [Element]) -> Bool {
        guard hasCapacity(for: elements.count) else {
            return false
        }

        defer {
            writeIndex = (writeIndex + elements.count) % store.count
            empty = false
        }

        let mustWrap = (store.count - writeIndex) < elements.count
        if !mustWrap {
            store[writeIndex ..< writeIndex + elements.count] = ArraySlice(elements)
        } else {
            let maxNumberOfElementsToWriteAtEnd = store.count - writeIndex
            let elementsToWriteAtEnd = elements.prefix(maxNumberOfElementsToWriteAtEnd)
            store[writeIndex...] = elementsToWriteAtEnd

            let maxNumberOfElementsToWriteAtBeginning = elements.count - elementsToWriteAtEnd.count
            let elementsToWriteAtBeginning = elements.suffix(maxNumberOfElementsToWriteAtBeginning)
            store[..<maxNumberOfElementsToWriteAtBeginning] = elementsToWriteAtBeginning
        }

        return true
    }
}
