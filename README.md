# Swift Server Benchmarks

This repo serves to compare different Swift server configurations and evaluate their relative performance, so users of these configurations can make informed decisions when planning their application on specific hardware or deployments.

### Requirements

Please make sure jemalloc is installed:
```
% brew install jemalloc
```

### Running Benchmarks

Run the benchmarks with:
```
% swift package benchmark
```
