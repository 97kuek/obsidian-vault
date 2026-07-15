#!/usr/bin/env ruby

require "digest"

ROOT = File.expand_path("..", __dir__)
files = Dir.glob(File.join(ROOT, "**", "*.md")).reject do |path|
  path.include?("/.git/") || path.include?("/.obsidian/") || path.include?("/.quartz/")
end.sort

empty = files.select { |path| File.read(path, encoding: "UTF-8").strip.empty? }
by_name = files.group_by { |path| File.basename(path).downcase }.select { |_, paths| paths.length > 1 }
by_content = files.group_by { |path| Digest::SHA256.file(path).hexdigest }.select { |_, paths| paths.length > 1 }

puts "Vault GC candidates: #{files.length} Markdown files"
puts "\nEmpty files (#{empty.length})"
empty.each { |path| puts "- #{path.delete_prefix("#{ROOT}/")}" }
puts "\nDuplicate basenames (#{by_name.length})"
by_name.each_value { |paths| puts "- #{paths.map { |p| p.delete_prefix("#{ROOT}/") }.join(' | ')}" }
puts "\nIdentical contents (#{by_content.length})"
by_content.each_value { |paths| puts "- #{paths.map { |p| p.delete_prefix("#{ROOT}/") }.join(' | ')}" }
puts "\n候補の削除・統合は自動実行しない。"
