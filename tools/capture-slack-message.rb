#!/usr/bin/env ruby

require "date"
require "digest"
require "open3"

ROOT = File.expand_path("..", __dir__)
TARGETS = {
  "inbox" => File.join(ROOT, "00_Inbox", "Slack Inbox.md"),
  "research" => File.join(ROOT, "00_Inbox", "Slack Research.md")
}.freeze

channel, message = ARGV
unless TARGETS.key?(channel) && message && !message.strip.empty?
  warn "usage: ruby tools/capture-slack-message.rb inbox|research MESSAGE"
  exit 2
end

secret_patterns = [
  /xox[baprs]-[A-Za-z0-9-]+/,
  /sk-[A-Za-z0-9_-]{20,}/,
  /(?:api[_ -]?key|access[_ -]?token|client[_ -]?secret)\s*[:=]\s*\S+/i
]

if secret_patterns.any? { |pattern| message.match?(pattern) }
  warn "CAPTURE_REJECTED: possible secret"
  exit 3
end

lock = File.join(ROOT, "tools", "agent-lock.sh")
stdout, stderr, status = Open3.capture3(lock, "acquire", "hermes", "Slack capture")
unless status.success?
  warn "CAPTURE_DEFERRED: #{stderr.strip.empty? ? stdout.strip : stderr.strip}"
  exit 4
end

begin
  target = TARGETS.fetch(channel)
  normalized = message.strip.gsub("\r\n", "\n")
  fingerprint = Digest::SHA256.hexdigest("#{Date.today.iso8601}\0#{normalized}")[0, 16]
  existing = File.read(target, encoding: "UTF-8")

  if existing.include?("slack-id: #{fingerprint}")
    puts "CAPTURE_SKIPPED: duplicate"
    exit 0
  end

  timestamp = Time.now.strftime("%Y-%m-%d %H:%M")
  entry = <<~MARKDOWN

    ## #{timestamp}

    <!-- slack-id: #{fingerprint} -->
    #{normalized}

    - 状態: 未整理
  MARKDOWN

  File.open(target, "a:UTF-8") { |file| file.write(entry) }
  puts "CAPTURED: #{File.basename(target)}"
ensure
  Open3.capture3(lock, "release", "hermes")
end

