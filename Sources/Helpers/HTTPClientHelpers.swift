import AsyncHTTPClient
import Foundation
import NIO

extension HTTPClient {
    public static func makeSingleUseClient() -> HTTPClient {
        var clientConfiguration = HTTPClient.Configuration()
        clientConfiguration.maximumUsesPerConnection = 1
        
        return HTTPClient(eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)), configuration: clientConfiguration)
    }
}
