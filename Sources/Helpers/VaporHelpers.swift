import Vapor
import Foundation

extension Application {
    public static func makeSingleUseServer() async throws -> Application {
        let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 0
        app.http.server.configuration.supportVersions = [.one]
        
        return app
    }
}

@inlinable
public func EventLoopFutureRandomComputedResponse(size: Int, chunkSize: Int = 256) -> @Sendable (_ request: Request) -> Response {
    precondition(size >= 256, "size must be larger than 256 bytes")
    return { request in
        Response(body: .init(stream: { writer in
            var lastEventLoop: EventLoopFuture<Void> = writer.eventLoop.makeSucceededVoidFuture()
            for block in 0..<(size/chunkSize) {
                let lastEventLoop = lastEventLoop.map {
                    writer.write(.buffer(ByteBuffer(bytes: generateBytePattern(chunkSize: chunkSize, block: block))))
                }
            }
            let _ = lastEventLoop.map {
                writer.write(.end)
            }
        }))
    }
}

@inlinable
public func EventLoopFutureRandomFixedSizeResponse(size: Int) -> @Sendable (_ request: Request) -> Response {
    let byteBuffer = generateByteBuffer(size: size)
    
    return { request in
        Response(body: .init(buffer: byteBuffer))
    }
}
