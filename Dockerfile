FROM crystallang/crystal:0.22.0
MAINTAINER Ian Blenke <ian@blenke.com>

# This is an example Dockerized Crystal Kemal project

# Install shards
WORKDIR /usr/local

# Add this directory to container as /app
WORKDIR /app
ADD shard.lock shard.yml /app/

# Install dependencies
RUN crystal deps

ADD . /app
# Build our app
RUN crystal build --release src/ping-statsd.cr

CMD ./ping-statsd
