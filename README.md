# ping-statsd

Small tool that pings specified addresses and logs timings and packet loss to Statsd (with tagging).

## Installation

Build and run with Docker, or run with Crystal.

## Usage

This tool is configured with environment variables for simplicity with running with Docker.

You can supply them like so:

```
PING_GOOGLE=google.com      # emits tags name:google,host:google.com
PING_SOME_IP=8.8.8.8        # emits tags name:some_ip,host:8.8.8.8
METRIC_BASE=namespace.ping  # emits metrics at "namespace.ping.{time,timeout,total}"
QUIET=true                  # optional, suppresses output
INTERVAL=0.2                # optional, sets ping interval to 200ms
```

## Contributing

1. Fork it ( https://github.com/[your-github-name]/ping-statsd/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) Jack Chen (chendo) - creator, maintainer
