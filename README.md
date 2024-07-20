# Swift Server Benchmarks

This repo serves to compare different Swift server configurations and evaluate their relative performance, so users of these configurations can make informed decisions when planning their application on specific hardware or deployments.

### Requirements

Please make sure jemalloc is installed:
```
% brew install jemalloc
```

### Running Benchmarks

Running through Xcode is not supported. Please run the benchmarks with:
```
% swift package --disable-sandbox benchmark
```

> [!IMPORTANT]
> `--disable-sandbox` is necessary to bind benchmarked servers to a port on your system so they can run. As with all software you download from the internet, please inspect it before running it!

### Naming Convention

Banckmarks are named according to the order of handlers configured on the NIO channel, with the client side on the left, and server side on the right.

For instance, `SingleRequest -> AsyncHTTPClient -> TCP -> Loopback <- TCP <- TLS <- HTTP2 <- ResponseCompression <- Vapor <- Computed <- 1GB <- Pattern` would test a client making a request to a server over the `Loopback` TCP interface.

On the client end, `SingleRequest -> AsyncHTTPClient -> TCP ->` indicates a single request is made over `AsyncHTTPClient` to a TCP address. `->` indicates the direction being primarily tested is sending the request to the server.

On the server end, `<- TCP <- TLS <- HTTP2 <- ResponseCompression <- Vapor <- Computed <- 1GB <- Pattern` indicates a server listening on a TCP socket with TLS enabled, running the HTTP/2 protocol, with dynamic response compression turned on, managed by Vapor to serve on-demand computed data 1 GB in size and pseudo-random but consistent in form. `<-` indicates the direction being primarily tested is sending the response back to the client.

> [!Note]
> The protocol and options for the client are omitted because they are not only also specified on the server half, but also indicate default options that don't need to be configured.


## Contributing

Contribution is welcome! Please take a look at the issues already available, or start a new discussion to propose a new feature. Although guarantees can't be made regarding feature requests, PRs that fit within the goals of the project and that have been discussed beforehand are more than welcome!

Please make sure that all submissions have clean commit histories, are well documented, and thoroughly tested. **Please rebase your PR** before submission rather than merge in `main`. Linear histories are required, so merge commits in PRs will not be accepted.

## Support

To support this project, consider following [@dimitribouniol](https://mastodon.social/@dimitribouniol) on Mastodon, or checking out his app, [Jiiiii](https://jiiiii.moe/).
