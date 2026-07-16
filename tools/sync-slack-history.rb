#!/usr/bin/env ruby

require "fileutils"
require "json"
require "net/http"
require "open3"
require "optparse"
require "rbconfig"
require "time"
require "uri"

ROOT = File.expand_path("..", __dir__)
CAPTURE = File.join(ROOT, "tools", "capture-slack-message.rb")
STATE_PATH = File.join(ROOT, ".agent-state", "slack-history.json")
HERMES_ENV = File.expand_path("~/.hermes/.env")
CHANNELS = {
  "inbox" => { id: "C0BGZCQMC5V", name: "inbox" },
  "research" => { id: "C0BHGM04GFK", name: "research" }
}.freeze

def load_dotenv(path)
  return {} unless File.file?(path)

  File.readlines(path, chomp: true, encoding: "UTF-8").each_with_object({}) do |line, values|
    match = line.match(/\A\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\z/)
    next unless match

    value = match[2].strip
    if value.length >= 2 && ((value.start_with?('"') && value.end_with?('"')) ||
                            (value.start_with?("'") && value.end_with?("'")))
      value = value[1...-1]
    end
    values[match[1]] = value
  end
end

def slack_get(token, method, params)
  uri = URI("https://slack.com/api/#{method}")
  uri.query = URI.encode_www_form(params)
  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = "Bearer #{token}"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 10, read_timeout: 30) do |http|
    http.request(request)
  end
  if response.code.to_i == 429
    wait = [response["retry-after"].to_i, 1].max
    sleep([wait, 30].min)
    return slack_get(token, method, params)
  end

  body = JSON.parse(response.body)
  raise "Slack API #{method} failed: #{body['error'] || response.code}" unless response.is_a?(Net::HTTPSuccess) && body["ok"]

  body
end

def load_state
  return { "channels" => {} } unless File.file?(STATE_PATH)

  JSON.parse(File.read(STATE_PATH, encoding: "UTF-8"))
rescue JSON::ParserError
  raise "Invalid state file: #{STATE_PATH}"
end

def save_state(state)
  FileUtils.mkdir_p(File.dirname(STATE_PATH), mode: 0o700)
  temporary = "#{STATE_PATH}.tmp"
  File.write(temporary, JSON.pretty_generate(state) + "\n", mode: "w", encoding: "UTF-8")
  File.chmod(0o600, temporary)
  File.rename(temporary, STATE_PATH)
end

def message_text(message)
  parts = [message["text"].to_s.strip]
  Array(message["files"]).each do |file|
    label = file["title"].to_s.strip
    label = file["name"].to_s.strip if label.empty?
    url = file["permalink"].to_s.strip
    parts << ["添付: #{label}", url].reject(&:empty?).join(" — ")
  end
  parts.reject(&:empty?).join("\n")
end

options = { dry_run: false, lookback_days: 7, channels: CHANNELS.keys }
OptionParser.new do |parser|
  parser.on("--dry-run") { options[:dry_run] = true }
  parser.on("--lookback-days DAYS", Integer) { |value| options[:lookback_days] = value }
  parser.on("--channel NAME", CHANNELS.keys) { |value| options[:channels] = [value] }
end.parse!(ARGV)

dotenv = load_dotenv(HERMES_ENV)
token = ENV["SLACK_BOT_TOKEN"] || dotenv["SLACK_BOT_TOKEN"]
abort "SLACK_SYNC_ERROR: SLACK_BOT_TOKEN is not configured" if token.to_s.empty?

state = load_state
state["channels"] ||= {}
total = 0

options[:channels].each do |channel|
  config = CHANNELS.fetch(channel)
  saved_ts = state.dig("channels", channel, "latest_ts")
  oldest = saved_ts || (Time.now - options[:lookback_days] * 86_400).to_f.to_s
  cursor = nil
  messages = []

  loop do
    params = { channel: config[:id], oldest: oldest, inclusive: false, limit: 200 }
    params[:cursor] = cursor unless cursor.to_s.empty?
    body = slack_get(token, "conversations.history", params)
    messages.concat(Array(body["messages"]))
    cursor = body.dig("response_metadata", "next_cursor")
    break if cursor.to_s.empty?
  end

  candidates = messages.reject do |message|
    message["bot_id"] || message["subtype"] == "bot_message" || message_text(message).empty?
  end.sort_by { |message| message.fetch("ts").to_f }

  puts "SLACK_SYNC_SCAN: ##{config[:name]} #{candidates.length} message(s)"
  unless options[:dry_run]
    candidates.each do |message|
      ts = message.fetch("ts")
      timestamp = Time.at(ts.to_f).iso8601
      permalink = slack_get(token, "chat.getPermalink", channel: config[:id], message_ts: ts)["permalink"]
      command = [
        RbConfig.ruby, CAPTURE,
        "--id", ts,
        "--permalink", permalink.to_s,
        "--timestamp", timestamp,
        "--channel-name", config[:name],
        channel, message_text(message)
      ]
      stdout, stderr, status = Open3.capture3(*command)
      output = stdout.strip.empty? ? stderr.strip : stdout.strip
      raise "Capture failed for ##{config[:name]} at #{ts}: #{output.lines.first}" unless status.success? || status.exitstatus == 4

      puts output unless output.empty?
      state["channels"][channel] = { "latest_ts" => ts, "updated_at" => Time.now.iso8601 }
      save_state(state)
      total += 1
    end
  end
end

puts options[:dry_run] ? "SLACK_SYNC_DRY_RUN_OK" : "SLACK_SYNC_OK: #{total} processed"
