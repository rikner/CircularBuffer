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

    func testRead() {
        var buf = CircularBuffer<Float>(repeating: 0, count: 10)

        [0.1, 0.2, 0.3, 0.4].forEach {
            buf.write($0)
        }

        if let value = buf.read() {
            XCTAssertEqual(0.1, value)
        } else {
            XCTFail()
        }
    }

    static var allTests = [
        ("testInit", testInit),
        ("testFullAndEmpty", testFullAndEmpty),
        ("testBasicWrite", testBasicWrite),
        ("testRead", testRead)
    ]
}
