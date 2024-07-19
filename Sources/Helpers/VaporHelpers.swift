import Vapor

public func EventLoopFutureRandomComputedResponse(size: Int) -> @Sendable (_ request: Request) -> Response {
    precondition(size >= 256, "size must be larger than 256 bytes")
    return { request in
        Response(body: .init(stream: { writer in
            for block in 0..<(size/256) {
                /// Create a consistent, but ever so slightly different byte pattern
                var bytes = Array(repeating: UInt8(block % 0xFF), count: 256)
                for index in bytes.indices {
                    bytes[index] = UInt8((Int(bytes[index]) + index) % 0xFF)
                }
                let _ = writer.write(.buffer(ByteBuffer(bytes: bytes)))
            }
            let _ = writer.write(.end)
        }))
    }
}

public func EventLoopFutureRandomFixedSizeResponse(size: Int) -> @Sendable (_ request: Request) -> Response {
    precondition(size >= 256, "size must be larger than 256 bytes")
    var fixedSizeBuffer: [UInt8] = []
    fixedSizeBuffer.reserveCapacity(size)
    for block in 0..<(size/256) {
        /// Create a consistent, but ever so slightly different byte pattern
        var bytes = Array(repeating: UInt8(block % 0xFF), count: 256)
        for index in bytes.indices {
            bytes[index] = UInt8((Int(bytes[index]) + index) % 0xFF)
        }
        fixedSizeBuffer.append(contentsOf: bytes)
    }
    
    let byteBuffer = ByteBuffer(bytes: fixedSizeBuffer)
    
    return { request in
        Response(body: .init(buffer: byteBuffer))
    }
}
