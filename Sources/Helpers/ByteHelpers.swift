import NIO

/// Create a consistent, but ever so slightly different byte pattern.
///
/// This ensures repeated runs are consistent, while the data itself is also not trivially compressible, but not completely random either.
@inlinable
public func generateBytePattern(chunkSize: Int = 256, block: Int) -> [UInt8] {
    precondition(chunkSize > 0 && chunkSize % 256 == 0, "chunkSize must be larger than 0 and be a multiple of 256 bytes")
    var bytes = Array(repeating: UInt8(block & 0xFF), count: chunkSize)
    for index in bytes.indices {
        bytes[index] ^= UInt8(index & 0xFF)
    }
    return bytes
}

@inlinable
func generateByteBuffer(size: Int) -> ByteBuffer {
    precondition(size >= 256, "size must be larger than 256 bytes")
    var fixedSizeBuffer: [UInt8] = []
    fixedSizeBuffer.reserveCapacity(size)
    for block in 0..<(size/256) {
        fixedSizeBuffer.append(contentsOf: generateBytePattern(block: block))
    }
    
    return ByteBuffer(bytes: fixedSizeBuffer)
}
