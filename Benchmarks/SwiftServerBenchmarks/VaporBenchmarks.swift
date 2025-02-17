import Benchmark
import NIO
import AsyncHTTPClient
import Vapor
import Helpers

struct VaporBenchmarks {
    @discardableResult init() {
        Self.http1Tests()
        Self.http1TLSTests()
        Self.http2TLSTests()
        Self.http2TLSCompressionTests()
    }
    
    static func http1Tests() {
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Computed <- 4MB <- Pattern (246 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = HTTPClient.makeSingleUseClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Computed <- 4MB <- Pattern (256 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024, chunkSize: 256*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = HTTPClient.makeSingleUseClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Computed <- 4MB <- Pattern (1 MB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024, chunkSize: 1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = HTTPClient.makeSingleUseClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- HTTP <- Vapor <- Precomputed <- 4MB <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomFixedSizeResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = HTTPClient.makeSingleUseClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "http://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
    }
    
    static func http1TLSTests() {
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TLS -> TCP -> Loopback <- TCP <- TLS <- HTTP <- Vapor <- Computed <- 4MB <- Pattern (256 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseTLSServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024, chunkSize: 256*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = try HTTPClient.makeSingleUseTLSClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "https://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TLS -> TCP -> Loopback <- TCP <- TLS <- HTTP <- Vapor <- Precomputed <- 4MB <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseTLSServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.one]
            
            app.get("resource", use: EventLoopFutureRandomFixedSizeResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = try HTTPClient.makeSingleUseTLSClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "https://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
    }
    
    static func http2TLSTests() {
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TLS -> TCP -> Loopback <- TCP <- TLS <- HTTP/2 <- Vapor <- Computed <- 4MB <- Pattern (256 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseTLSServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.two]
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024, chunkSize: 256*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = try HTTPClient.makeSingleUseTLSClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "https://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TLS -> TCP -> Loopback <- TCP <- TLS <- HTTP/2 <- Vapor <- Precomputed <- 4MB <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseTLSServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.two]
            
            app.get("resource", use: EventLoopFutureRandomFixedSizeResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = try HTTPClient.makeSingleUseTLSClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "https://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
    }
    
    static func http2TLSCompressionTests() {
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TLS -> TCP -> Loopback <- TCP <- TLS <- HTTP/2 <- Response Compression <- Vapor <- Computed <- 4MB <- Pattern (256 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseTLSServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.two]
            app.http.server.configuration.responseCompression = .enabled
            
            app.get("resource", use: EventLoopFutureRandomComputedResponse(size: 4*1024*1024, chunkSize: 256*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = try HTTPClient.makeSingleUseTLSClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "https://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
        
        Benchmark(
            "SingleRequest -> AsyncHTTPClient -> TLS -> TCP -> Loopback <- TCP <- TLS <- HTTP/2 <- Response Compression <- Vapor <- Precomputed <- 4MB <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            let app = try await Application.makeSingleUseTLSServer()
            app.http.server.configuration.hostname = "127.0.0.1"
            app.http.server.configuration.supportVersions = [.two]
            app.http.server.configuration.responseCompression = .enabled
            
            app.get("resource", use: EventLoopFutureRandomFixedSizeResponse(size: 4*1024*1024))
            
            try app.server.start()
            defer { app.server.shutdown() }
            
            let port = app.http.server.shared.localAddress!.port!
            let client = try HTTPClient.makeSingleUseTLSClient()
            
            benchmark.startMeasurement()
            for _ in benchmark.scaledIterations {
                let response = try await client.execute(HTTPClientRequest(url: "https://localhost:\(port)/resource"), timeout: .seconds(300))
                // TODO: Find a better way of scanning to the end without filling up a buffer
                blackHole(try await response.body.reduce(into: 0, { result, _ in result += 1 }))
            }
            benchmark.stopMeasurement()
        }
    }
}
