import Benchmark
import NIO
import AsyncHTTPClient
import Vapor
import Helpers

struct VaporBenchmarks {
    @discardableResult init() {
        Benchmark(
            "SingleRequest_AsyncHTTPClient_TCP_Loopback_TCP_HTTP_Vapor_Computed_1GB_Random",
            configuration: .init(scalingFactor: .one, maxIterations: .count(10))
        ) { benchmark in
            let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.port = 0
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 1024*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await HTTPClient.shared.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.collect(upTo: 10*1024*1024*1024))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest_AsyncHTTPClient_TCP_Loopback_TCP_HTTP_Vapor_Memory_1GB_Random",
            configuration: .init(scalingFactor: .one, maxIterations: .count(10))
        ) { benchmark in
            let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.port = 0
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomFixedSizeResponse(size: 1024*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await HTTPClient.shared.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.collect(upTo: 10*1024*1024*1024))
            }
            benchmark.stopMeasurement()
        }
    }
}
