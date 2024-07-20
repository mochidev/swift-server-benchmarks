import Logging
/// Add all benchmarks to this closure to register them.
let benchmarks = {
    /// Disable server logging that could obstruct the benchmarks
    LoggingSystem.bootstrap { _ in SwiftLogNoOpLogHandler() }
    
    HelperBenchmarks()
    VaporBenchmarks()
}
