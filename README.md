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

### Naming Convention

Banckmarks are named according to the order of handlers configured on the NIO channel, with the client side on the left, and server side on the right.

For instance, `SingleRequest_AsyncHTTPClient_TCP_Loopback_TCP_TLS_HTTP2_ResponseCompression_Vapor_Computed_1GB_Random` would test a client making a request to a server over the `Loopback` TCP interface. On the client end, `SingleRequest_AsyncHTTPClient_TCP` indicates a single request is made over `AsyncHTTPClient` to a TCP address. On the server end, `TCP_TLS_HTTP2_ResponseCompression_Vapor_Computed_1GB_Random` indicates a server listening on a TCP socket with TLS enabled, running the HTTP/2 protocol, with dynamic response compression turned on, managed by Vapor to serve on-demand computed data 1 GB in size and random in form. Note the protocol and options for the client are omitted because they are not only also specified on the server half, but also because they indicate default options that don't need to be configured.
