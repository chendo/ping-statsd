require "./ping-statsd/*"
require "statsd"

class IO::Null
  include IO
  def write(bytes)
  end
  def read(slice)
    ""
  end
end

module Ping::Statsd
  class Pinger
    def initialize(
      @host : String,
      @statsd : ::Statsd::Client,
      @name : String | Nil = nil,
      @metric_base : String = "ping",
      @interval : Float32 = 1_f32,
      @logger : IO = STDOUT)

      @name ||= @host
      @tags = ["host:#{@host}", "name:#{name}"]
    end

    def run
      r, w = IO.pipe
      spawn do
        Process.run("ping", ["-i", @interval.to_s, @host], output: w, error: w)
      end
      while line = r.gets
        case line
        when /bytes from .*=([\d.]+) ms$/
          log "#{$1} ms"
          @statsd.increment(metric("success"), tags: @tags)
          @statsd.timing(metric("time"), $1.to_f32, tags: @tags)
          @statsd.increment(metric("total"), tags: @tags)
        when /^Request timeout/
          @statsd.increment(metric("timeout"), tags: @tags)
          @statsd.increment(metric("total"), tags: @tags)
          log "Timed out"
        when /^PING/
          # no-op
        else
          log "Unhandled line: #{line}"
        end
      end
    end

    private def metric(name)
      [@metric_base, name].join(".")
    end

    private def log(msg)
      @logger.puts "[#{@name}]: #{msg}"
    end
  end
end

statsd = Statsd::Client.new(ENV.fetch("STATSD_HOST", "localhost"), ENV.fetch("STATSD_PORT", "8125").to_i)
logger = ENV.fetch("QUIET", nil) ? IO::Null.new : STDOUT
interval = ENV.fetch("INTERVAL", "1").to_f32
metric_base = ENV.fetch("METRIC_BASE", "ping")

fibers = [] of Fiber
ENV.keys.each do |key|
  if key =~ /^PING_?(.*)$/
    args = {
      name: $1.size == 0 ? nil : $1.downcase,
      host: ENV[key],
      metric_base: metric_base,
      logger: logger,
      interval: interval,
      statsd: statsd
    }

    fibers << spawn do
      Ping::Statsd::Pinger.new(**args).run
    end
  end
end

if fibers.empty?
  STDERR.puts <<-STR
You must set at least one host to ping.
PING_[NAME]=<HOSTNAME>
PING_GOOGLE=google.com
PING_YAHOO=yahoo.com
INTERVAL=0.2            # 200ms
STR
else
  sleep
end
