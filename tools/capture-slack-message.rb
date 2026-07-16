#!/usr/bin/env ruby

require "date"
require "digest"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "time"

ROOT = File.expand_path("..", __dir__)
TARGETS = {
  "inbox" => File.join(ROOT, "00_Inbox", "Slack Inbox.md")
}.freeze
QUEUE = File.join(ROOT, ".agent-queue", "slack-capture.jsonl")
LOCK = File.join(ROOT, "tools", "agent-lock.sh")

SECRET_PATTERNS = [
  /xox[baprs]-[A-Za-z0-9-]+/,
  /sk-[A-Za-z0-9_-]{20,}/,
  /(?:api[_ -]?key|access[_ -]?token|client[_ -]?secret)\s*[:=]\s*\S+/i
].freeze

def reject_secret!(message)
  return unless SECRET_PATTERNS.any? { |pattern| message.match?(pattern) }

  warn "CAPTURE_REJECTED: possible secret"
  exit 3
end

def acquire_lock
  stdout, stderr, status = Open3.capture3(LOCK, "acquire", "hermes", "Slack capture")
  [status.success?, stderr.strip.empty? ? stdout.strip : stderr.strip]
end

def release_lock
  Open3.capture3(LOCK, "release", "hermes")
end

def append_entry(payload)
  target = TARGETS.fetch(payload.fetch("channel"))
  message = payload.fetch("message").strip.gsub("\r\n", "\n")
  stable_id = payload["id"].to_s.strip
  fingerprint = if stable_id.empty?
                  Digest::SHA256.hexdigest("#{Date.today.iso8601}\0#{message}")[0, 16]
                else
                  Digest::SHA256.hexdigest("slack\0#{stable_id}")[0, 16]
                end
  existing = File.read(target, encoding: "UTF-8")
  return "CAPTURE_SKIPPED: duplicate" if existing.include?("slack-id: #{fingerprint}")

  timestamp = begin
    value = payload["timestamp"].to_s.strip
    value.empty? ? Time.now : Time.parse(value)
  rescue ArgumentError
    Time.now
  end
  metadata = []
  metadata << "- Slack: #{payload['permalink']}" unless payload["permalink"].to_s.strip.empty?
  metadata << "- チャンネル: ##{payload['channel_name']}" unless payload["channel_name"].to_s.strip.empty?

  entry = <<~MARKDOWN

    ## #{timestamp.getlocal.strftime('%Y-%m-%d %H:%M')}

    <!-- slack-id: #{fingerprint} -->
    #{message}

    #{metadata.join("\n")}
    - 状態: 未整理
  MARKDOWN

  File.open(target, "a:UTF-8") { |file| file.write(entry) }
  "CAPTURED: #{File.basename(target)}"
end

def queue(payload, reason)
  FileUtils.mkdir_p(File.dirname(QUEUE))
  File.open(QUEUE, "a:UTF-8", 0o600) { |file| file.puts(JSON.generate(payload)) }
  warn "CAPTURE_QUEUED: #{reason.lines.first.to_s.strip}"
end

def flush_queue
  return puts("QUEUE_EMPTY") unless File.exist?(QUEUE)

  ok, reason = acquire_lock
  return warn("FLUSH_DEFERRED: #{reason.lines.first.to_s.strip}") unless ok

  begin
    lines = File.readlines(QUEUE, chomp: true, encoding: "UTF-8")
    failed = []
    processed = 0
    lines.each do |line|
      begin
        puts append_entry(JSON.parse(line))
        processed += 1
      rescue StandardError => e
        failed << line
        warn "QUEUE_ITEM_FAILED: #{e.class}"
      end
    end
    if failed.empty?
      File.delete(QUEUE)
    else
      File.write(QUEUE, failed.join("\n") + "\n", mode: "w", encoding: "UTF-8")
    end
    puts "QUEUE_FLUSHED: #{processed}"
  ensure
    release_lock
  end
end

if ARGV.first == "flush"
  flush_queue
  exit
end

options = {}
parser = OptionParser.new do |opts|
  opts.on("--id ID") { |value| options["id"] = value }
  opts.on("--permalink URL") { |value| options["permalink"] = value }
  opts.on("--timestamp TIME") { |value| options["timestamp"] = value }
  opts.on("--channel-name NAME") { |value| options["channel_name"] = value }
end
parser.parse!(ARGV)

channel, message = ARGV
unless TARGETS.key?(channel) && message && !message.strip.empty?
  warn "usage: ruby tools/capture-slack-message.rb [options] inbox MESSAGE"
  warn "       ruby tools/capture-slack-message.rb flush"
  exit 2
end

reject_secret!(message)
payload = options.merge("channel" => channel, "message" => message)
ok, reason = acquire_lock
unless ok
  queue(payload, reason)
  exit 4
end

begin
  puts append_entry(payload)
ensure
  release_lock
end
