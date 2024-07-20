import Benchmark
import Helpers

struct HelperBenchmarks {
    @discardableResult init() {
        Benchmark(
            "Computed <- 256B <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .kilo)
        ) { benchmark in
            for block in benchmark.scaledIterations {
                blackHole(generateBytePattern(block: block))
            }
        }
        
        Benchmark(
            "Computed <- 1KB <- Pattern (1 KB chunk)",
            configuration: .init(scalingFactor: .kilo)
        ) { benchmark in
            for block in benchmark.scaledIterations {
                blackHole(generateBytePattern(chunkSize: 1024, block: block))
            }
        }
        
        Benchmark(
            "Computed <- 1MB <- Pattern (1 MB chunk)",
            configuration: .init(scalingFactor: .kilo)
        ) { benchmark in
            for block in benchmark.scaledIterations {
                blackHole(generateBytePattern(chunkSize: 1024*1024, block: block))
            }
        }
        
        Benchmark(
            "Computed <- 1GB <- Pattern (16 MB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            for _ in benchmark.scaledIterations {
                for block in 0..<64 {
                    blackHole(generateBytePattern(chunkSize: 16*1024*1024, block: block))
                }
            }
        }
        
        Benchmark(
            "Computed <- 1GB <- Pattern (1 MB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            for _ in benchmark.scaledIterations {
                for block in 0..<1024 {
                    blackHole(generateBytePattern(chunkSize: 1024*1024, block: block))
                }
            }
        }
        
        Benchmark(
            "Computed <- 1GB <- Pattern (512 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            for _ in benchmark.scaledIterations {
                for block in 0..<2*1024 {
                    blackHole(generateBytePattern(chunkSize: 512*1024, block: block))
                }
            }
        }
        
        Benchmark(
            "Computed <- 1GB <- Pattern (256 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            for _ in benchmark.scaledIterations {
                for block in 0..<4*1024 {
                    blackHole(generateBytePattern(chunkSize: 256*1024, block: block))
                }
            }
        }
        
        Benchmark(
            "Computed <- 1GB <- Pattern (1 KB chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            for _ in benchmark.scaledIterations {
                for block in 0..<1024*1024 {
                    blackHole(generateBytePattern(chunkSize: 1024, block: block))
                }
            }
        }
        
        Benchmark(
            "Computed <- 1GB <- Pattern (256 B chunk)",
            configuration: .init(scalingFactor: .one)
        ) { benchmark in
            for _ in benchmark.scaledIterations {
                for block in 0..<4*1024*1024 {
                    blackHole(generateBytePattern(chunkSize: 256, block: block))
                }
            }
        }
    }
}
