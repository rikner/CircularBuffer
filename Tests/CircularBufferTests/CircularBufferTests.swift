import XCTest
@testable import CircularBuffer

final class CircularBufferTests: XCTestCase {
    func testInit() {
        let buf = CircularBuffer<Float>(repeating: 0, count: 10)

        XCTAssertEqual(buf.readIndex, buf.writeIndex)
        XCTAssertTrue(buf.isEmpty)
        XCTAssertFalse(buf.isFull)
    }

    func testFullAndEmpty() {
        var buf = CircularBuffer<Float>(repeating: 0, count: 2)

        buf.write(0.1)
        
        XCTAssertFalse(buf.isFull)
        XCTAssertFalse(buf.isEmpty)
        XCTAssertEqual(buf.writeIndex, 1)

        buf.write(0.2)

        XCTAssertTrue(buf.isFull)
        XCTAssertFalse(buf.isEmpty)
        XCTAssertEqual(buf.writeIndex, 0)
    }

    func testBasicWrite() {
        var buf = CircularBuffer<Float>(repeating: 0, count: 10)
        let testData: [Float] = [0.1, 0.2, 0.3, 0.4]

        testData.forEach {
            buf.write($0)
        }

        XCTAssertEqual(buf.writeIndex, testData.count)
        XCTAssertEqual(buf.readIndex, 0)
    }

    func testBasicRead() {
        var buf = CircularBuffer<Float>(
            from: [0.1, 0.2, 0.3, 0.4],
            readIndex: 0,
            writeIndex: 3
        )

        if let value = buf.read() {
            XCTAssertEqual(0.1, value)
        } else {
            XCTFail()
        }
    }

    func testArrayWrite() {
        var buf = CircularBuffer<Float>(repeating: 0, count: 2)

        buf.write([0.1, 0.2])

        XCTAssertTrue(buf.isFull)
        XCTAssertFalse(buf.isEmpty)
        XCTAssertEqual(buf.readIndex, 0)
        XCTAssertEqual(buf.writeIndex, 0)
    }

    func testReadAll() {
        let testData: [Float] = [0.1, 0.2, 0.3]
        var buf = CircularBuffer<Float>(from: testData, readIndex: 0, writeIndex: 0, empty: false)
        XCTAssertTrue(buf.isFull) // since readIndex equals writeIndex and empty is false -> buffer is full
        
        let data = buf.readAll()
        
        XCTAssertEqual(data, testData)
        XCTAssertTrue(buf.isEmpty)
        XCTAssertFalse(buf.isFull)
    }

    func testWrappedRead() {
        let array = [1, 0, 2]
        let readIndex = 2
        let writeIndex = 1
        var buf = CircularBuffer<Int>(from: array, readIndex: readIndex, writeIndex: writeIndex)
  
        let data = buf.readAll()

        XCTAssertEqual(data, [2, 1])
        XCTAssertTrue(buf.isEmpty)
    }

    func testWrappedWrite() {
        let array = [0, 1, 0]
        let readIndex = 1
        let writeIndex = 2
        var buf = CircularBuffer<Int>(from: array, readIndex: readIndex, writeIndex: writeIndex)
  
        XCTAssertFalse(buf.isEmpty)
        XCTAssertFalse(buf.isFull)

        buf.write([1, 1])

        XCTAssertFalse(buf.isEmpty)
        XCTAssertTrue(buf.isFull)

        let data = buf.readAll()
        XCTAssertEqual(data, [1, 1, 1])
    }

    func testUseCase1() {
        let bufferSize = 8
        var buf = CircularBuffer<Float>(repeating: 0, count: bufferSize)
        let testData: [Float] = [0.1, 0.2, 0.3, 0.4]

        // write to fill buffer
        XCTAssertTrue(buf.write(testData))
        XCTAssertTrue(buf.write(testData))
        XCTAssertEqual(buf.store.count, bufferSize)

        // should not be able to write now
        XCTAssertFalse(buf.write(testData))

        // read all data
        let data = buf.readAll()
        XCTAssertEqual(data.count, bufferSize)
        XCTAssertEqual(data,  testData + testData)

        // should be able to write again
        XCTAssertTrue(buf.write(testData))

        XCTAssertEqual(buf.store.count, bufferSize)
    }

    static var allTests = [
        ("testInit", testInit),
        ("testFullAndEmpty", testFullAndEmpty),
        ("testBasicWrite", testBasicWrite),
        ("testBasicRead", testBasicRead),
        ("testArrayWrite", testArrayWrite),
        ("testReadAll", testReadAll),
        ("testWrappedRead", testWrappedRead),
        ("testWrappedWrite", testWrappedWrite),
        ("testUseCase1", testUseCase1)
    ]
}
