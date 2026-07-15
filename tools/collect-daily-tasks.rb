#!/usr/bin/env ruby

require "json"
require "date"

root = File.expand_path("..", __dir__)
targets = ["00_Inbox", "10_Projects", "20_Areas/大学授業"]
tasks = []

targets.each do |directory|
  Dir.glob(File.join(root, directory, "**", "*.md")).sort.each do |path|
    fence = nil

    File.foreach(path, encoding: "UTF-8").with_index(1) do |line, line_number|
      if line.match?(/^\s*```/)
        fence = fence == "```" ? nil : "```" if fence.nil? || fence == "```"
        next
      end
      if line.match?(/^\s*~~~/)
        fence = fence == "~~~" ? nil : "~~~" if fence.nil? || fence == "~~~"
        next
      end
      next unless fence.nil?

      match = line.match(/^\s*-\s+\[ \]\s+(\S.*)$/)
      next unless match

      text = match[1].strip
      due = text[/📅\s*(\d{4}-\d{2}-\d{2})/, 1]
      priority = if text.include?("⏫")
                   "highest"
                 elsif text.include?("🔼")
                   "high"
                 elsif text.include?("🔽")
                   "low"
                 else
                   "normal"
                 end

      tasks << {
        path: path.delete_prefix("#{root}/"),
        line: line_number,
        task: text,
        due: due,
        priority: priority
      }
    end
  end
end

puts JSON.pretty_generate(
  generated_on: Date.today.iso8601,
  count: tasks.length,
  tasks: tasks
)
