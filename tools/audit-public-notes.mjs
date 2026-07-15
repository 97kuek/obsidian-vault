import fs from "node:fs"
import path from "node:path"
import process from "node:process"

const root = process.cwd()
const excluded = new Set([".git", ".github", ".obsidian", ".agents", ".claude", ".quartz", "node_modules", "site", "tmp"])
const errors = []
let published = 0

function walk(directory) {
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    if (entry.isDirectory() && excluded.has(entry.name)) return []
    const absolute = path.join(directory, entry.name)
    if (entry.isDirectory()) return walk(absolute)
    return entry.isFile() && entry.name.toLowerCase().endsWith(".md") ? [absolute] : []
  })
}

function frontmatter(text) {
  return text.replace(/\r\n/g, "\n").match(/^---\n([\s\S]*?)\n---(?:\n|$)/)?.[1] ?? ""
}

function publishState(text, relative) {
  const yaml = frontmatter(text)
  const yes = /(?:^|\n)publish:\s*true\s*(?:\n|$)/i.test(yaml)
  const no = /(?:^|\n)publish:\s*false\s*(?:\n|$)/i.test(yaml)
  if (yes && no) errors.push(`${relative}: publish値が競合している`)
  if (no) return false
  return yes || relative.startsWith("20_Areas/")
}

const forbiddenPublishedPath = /(?:^|\/)(?:課題|試験|答案)(?:\/|_|\.|$)/
const secretPatterns = [
  /xox[baprs]-[A-Za-z0-9-]+/,
  /\bsk-[A-Za-z0-9_-]{20,}\b/,
  /-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----/,
  /(?:api[_ -]?key|access[_ -]?token|client[_ -]?secret)\s*[:=]\s*[^\s"']{12,}/i,
]

for (const absolute of walk(root)) {
  const relative = path.relative(root, absolute).split(path.sep).join("/")
  const text = fs.readFileSync(absolute, "utf8")
  if (!publishState(text, relative)) continue
  published += 1

  if (forbiddenPublishedPath.test(relative)) {
    errors.push(`${relative}: 課題・試験・答案は公開できない`)
  }
  for (const pattern of secretPatterns) {
    if (pattern.test(text)) {
      errors.push(`${relative}: 秘密情報らしい文字列を検出した`)
      break
    }
  }
}

if (errors.length > 0) {
  console.error("PUBLICATION_AUDIT_FAILED")
  for (const error of errors) console.error(`- ${error}`)
  process.exit(1)
}

console.log(`PUBLICATION_AUDIT_OK: ${published} notes`)
