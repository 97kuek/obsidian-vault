#!/usr/bin/env ruby

require "set"

ROOT = File.expand_path("..", __dir__)
EXCLUDED = %w[.git .obsidian .quartz node_modules].freeze
files = Dir.glob(File.join(ROOT, "**", "*.md")).reject do |path|
  path.delete_prefix("#{ROOT}/").split("/").any? { |part| EXCLUDED.include?(part) }
end.sort

names = Hash.new { |hash, key| hash[key] = [] }
files.each do |path|
  relative = path.delete_prefix("#{ROOT}/")
  names[File.basename(path, ".md").downcase] << relative
  names[relative.delete_suffix(".md").downcase] << relative
end

issues = []
files.each do |path|
  relative = path.delete_prefix("#{ROOT}/")
  text = File.read(path, encoding: "UTF-8").gsub("\r\n", "\n")
  content_note = relative.match?(%r{\A(?:00_Inbox|10_Projects|20_Areas|30_Resources|40_Archives|99_Templates)/}) || relative == "Home.md" || relative == "VAULT_INDEX.md"
  issues << ["frontmatter", relative] if content_note && !text.start_with?("---\n")

  fence = false
  text.each_line.with_index(1) do |line, number|
    if line.match?(/^\s*(```|~~~)/)
      fence = !fence
      next
    end
    next if fence
    issues << ["H1", "#{relative}:#{number}"] if line.match?(/^#\s+/)
  end

  next unless content_note

  link_text = text.gsub(/```[\s\S]*?```|~~~[\s\S]*?~~~/, "").gsub(/`[^`\n]+`/, "")
  link_text.scan(/\[\[([^\]|#]+)(?:#[^\]|]+)?(?:\|[^\]]+)?\]\]/).flatten.each do |target|
    clean = target.sub(/\.md\z/i, "").strip.downcase
    next if clean.empty?
    relative_target = File.expand_path(clean, File.dirname(relative)).delete_prefix("#{ROOT}/")
    next if names.key?(clean) || names.key?(File.basename(clean)) || names.key?(relative_target)
    issues << ["unresolved-link", "#{relative} -> #{target}"]
  end
end

puts "Vault review: #{files.length} Markdown files"
if issues.empty?
  puts "REVIEW_OK"
  exit
end

issues.group_by(&:first).each do |kind, rows|
  puts "\n#{kind}: #{rows.length}"
  rows.first(50).each { |(_, detail)| puts "- #{detail}" }
  puts "- ..." if rows.length > 50
end
exit 1
