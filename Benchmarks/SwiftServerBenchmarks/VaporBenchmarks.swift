import Benchmark
import NIO
import AsyncHTTPClient
import Vapor
import Helpers

struct VaporBenchmarks {
    @discardableResult init() {
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Computed <- 4MB <- Pattern (246 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.port = 0
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await HTTPClient.shared.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Computed <- 4MB <- Pattern (256 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.port = 0
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024, chunkSize: 256*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await HTTPClient.shared.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Precomputed <- 4MB <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.make(.development, .shared(MultiThreadedEventLoopGroup(numberOfThreads: 1)))
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.port = 0
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomFixedSizeResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await HTTPClient.shared.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
    }
}
