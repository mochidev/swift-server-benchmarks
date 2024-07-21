import AsyncHTTPClient
import Foundation
import NIO
import NIOSSL

extension HTTPClient {
    public static func makeSingleUseClient() -> HTTPClient {
        var clientConfiguration = HTTPClient.Configuration()
        clientConfiguration.maximumUsesPerConnection = 1
        clientConfiguration.decompression = .enabled(limit: .none)
        
        return HTTPClient(eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)), configuration: clientConfiguration)
    }
    
    public static func makeSingleUseTLSClient() throws -> HTTPClient {
        guard
            let clientCertPath = Bundle.module.url(forResource: "expired", withExtension: "crt"),
            let clientKeyPath = Bundle.module.url(forResource: "expired", withExtension: "key")
        else {
            throw BenchmarkError(message: "Certs were not found.")
        }
        
        let cert = try NIOSSLCertificate(file: clientCertPath.path, format: .pem)
        let key = try NIOSSLPrivateKey(file: clientKeyPath.path, format: .pem)
        
        var clientTLSConfiguration = TLSConfiguration.makeClientConfiguration()
        clientTLSConfiguration.certificateVerification = .none
        clientTLSConfiguration.certificateChain = [.certificate(cert)]
        clientTLSConfiguration.privateKey = .privateKey(key)
        
        var clientConfiguration = HTTPClient.Configuration(tlsConfiguration: clientTLSConfiguration)
        clientConfiguration.maximumUsesPerConnection = 1
        clientConfiguration.decompression = .enabled(limit: .none)
        
        return HTTPClient(eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)), configuration: clientConfiguration)
    }
}
