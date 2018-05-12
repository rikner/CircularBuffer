# CircularBuffer

A non-thread-safe circular buffer struct.
It doesn't overwrite elements, which not have been read yet. So the callside should take care
of consuming elements on time (by calling `read()` or `readAll()`).
When writing it returns a Bool indicating if element(s) have been written.

Build with `swift build`.
Run tests with `swift test`.

## Example Usage
```swift
let circularBuffer = CircularBuffer<Float>(repeating: 0, count: 5)

var hasWritten: Bool = false

hasWritten = circularBuffer.write(0.1)
// hasWritten == true

hasWritten = circularBuffer.write([0.2, 0.3, 0.4, 0.5])
// hasWritten == true

hasWritten = circularBuffer.write(0.6)
// hasWritten == false

let element = circularBuffer.read()
// element == 0.1
 
let elements = circularBuffer.readAll()
// elements == [0.2, 0.3, 0.4, 0.5]

```