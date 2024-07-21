import Vapor
import Foundation
import NIOSSL

extension Application {
    public static func makeSingleUseServer() async throws -> Application {
        let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 0
        app.http.server.configuration.supportVersions = [.one]
        
        return app
    }
    
    public static func makeSingleUseTLSServer() async throws -> Application {
        guard
            let clientCertPath = Bundle.module.url(forResource: "expired", withExtension: "crt"),
            let clientKeyPath = Bundle.module.url(forResource: "expired", withExtension: "key")
        else {
            throw BenchmarkError(message: "Certs were not found.")
        }
        
        let cert = try NIOSSLCertificate(file: clientCertPath.path, format: .pem)
        let key = try NIOSSLPrivateKey(file: clientKeyPath.path, format: .pem)
        
        let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
        app.http.server.configuration.hostname = "127.0.0.1"
        app.http.server.configuration.port = 0
        app.http.server.configuration.supportVersions = [.one]
        
        var serverConfig = TLSConfiguration.makeServerConfiguration(certificateChain: [.certificate(cert)], privateKey: .privateKey(key))
        serverConfig.certificateVerification = .noHostnameVerification
        app.http.server.configuration.tlsConfiguration = serverConfig
        app.http.server.configuration.customCertificateVerifyCallback = { @Sendable _, successPromise in
            successPromise.succeed(.certificateVerified)
        }
        
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
