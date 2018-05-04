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
        XCTAssertEqual(buf.writeIndex, 2)
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
        var buf = CircularBuffer<Float>(repeating: 0, count: 10)
        let testData: [Float] = [0.1, 0.2, 0.3, 0.4]
        testData.forEach { buf.write($0) }

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
    }

    func testReadAll() {
        var buf = CircularBuffer<Float>(repeating: 0, count: 3)
        let testData: [Float] = [0.1, 0.2, 0.3]

        buf.write(testData)
        let data = buf.readAll()
        
        XCTAssertEqual(data, testData)
        XCTAssertTrue(buf.isEmpty)
        XCTAssertFalse(buf.isFull)
    }

    func testWrappedRead() {
        let array = [1, 0, 1]
        let readIndex = 2
        let writeIndex = 1
        var buf = CircularBuffer<Int>(from: array, readIndex: readIndex, writeIndex: writeIndex)
  
        let data = buf.readAll()

        XCTAssertEqual(data, [1, 1])
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

    static var allTests = [
        ("testInit", testInit),
        ("testFullAndEmpty", testFullAndEmpty),
        ("testBasicWrite", testBasicWrite),
        ("testBasicRead", testBasicRead),
        ("testArrayWrite", testArrayWrite),
        ("testReadAll", testReadAll),
        ("testWrappedRead", testWrappedRead),
        ("testWrappedWrite", testWrappedWrite)
    ]
}
