import fs from "node:fs"
import path from "node:path"
import process from "node:process"

const vaultRoot = process.cwd()
const args = process.argv.slice(2)
const outputFlag = args.indexOf("--output")

if (outputFlag === -1 || !args[outputFlag + 1]) {
  throw new Error("Usage: node tools/export-public-notes.mjs --output <directory>")
}

const outputRoot = path.resolve(vaultRoot, args[outputFlag + 1])
if (path.basename(outputRoot).toLowerCase() !== "content") {
  throw new Error(`Refusing to replace a directory not named "content": ${outputRoot}`)
}

const excludedDirectories = new Set([
  ".git",
  ".github",
  ".obsidian",
  ".agents",
  ".claude",
  ".quartz",
  "node_modules",
  "site",
  "tmp",
])

function normalize(relativePath) {
  return relativePath.split(path.sep).join("/")
}

function walk(directory) {
  const files = []
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    if (entry.isDirectory() && excludedDirectories.has(entry.name)) continue
    const absolutePath = path.join(directory, entry.name)
    if (entry.isDirectory()) files.push(...walk(absolutePath))
    else if (entry.isFile()) files.push(absolutePath)
  }
  return files
}

function frontmatter(text) {
  const match = text.replace(/\r\n/g, "\n").match(/^---\n([\s\S]*?)\n---(?:\n|$)/)
  return match?.[1] ?? ""
}

function isPublished(text, relativePath) {
  const yaml = frontmatter(text)
  const explicitTrue = /(?:^|\n)publish:\s*true\s*(?:\n|$)/i.test(yaml)
  const explicitFalse = /(?:^|\n)publish:\s*false\s*(?:\n|$)/i.test(yaml)

  if (explicitTrue && explicitFalse) {
    throw new Error(`Conflicting publish values: ${relativePath}`)
  }
  if (explicitFalse) return false
  if (explicitTrue) return true

  return relativePath.startsWith("20_Areas/")
}

function noteTitle(text, fallback) {
  const yaml = frontmatter(text)
  const yamlTitle = yaml.match(/(?:^|\n)title:\s*["']?(.+?)["']?\s*(?:\n|$)/)?.[1]
  if (yamlTitle) return yamlTitle.trim()
  const h1 = text.match(/^#\s+(.+)$/m)?.[1]
  return h1?.trim() || fallback
}

function aliases(text) {
  const yaml = frontmatter(text)
  const inline = yaml.match(/(?:^|\n)aliases:\s*\[([^\]]*)\]/)?.[1]
  if (inline) {
    return inline
      .split(",")
      .map((value) => value.trim().replace(/^["']|["']$/g, ""))
      .filter(Boolean)
  }

  const lines = yaml.split("\n")
  const result = []
  const start = lines.findIndex((line) => /^aliases:\s*$/.test(line))
  if (start === -1) return result
  for (let index = start + 1; index < lines.length; index += 1) {
    const match = lines[index].match(/^\s+-\s+(.+?)\s*$/)
    if (!match) break
    result.push(match[1].replace(/^["']|["']$/g, ""))
  }
  return result
}

const allFiles = walk(vaultRoot)
const markdownFiles = allFiles.filter((file) => file.toLowerCase().endsWith(".md"))
const assetFiles = allFiles.filter((file) =>
  /\.(png|jpe?g|gif|svg|webp|avif)$/i.test(file),
)

const notes = markdownFiles.map((absolutePath) => {
  const relativePath = normalize(path.relative(vaultRoot, absolutePath))
  const text = fs.readFileSync(absolutePath, "utf8").replace(/\r\n/g, "\n")
  const withoutExtension = relativePath.slice(0, -3)
  return {
    absolutePath,
    relativePath,
    withoutExtension,
    basename: path.posix.basename(withoutExtension),
    text,
    title: noteTitle(text, path.posix.basename(withoutExtension)),
    aliases: aliases(text),
    published: isPublished(text, relativePath),
  }
})

const publishedNotes = notes.filter((note) => note.published)
if (publishedNotes.length === 0) {
  throw new Error("No notes contain `publish: true` in frontmatter.")
}

const noteLookup = new Map()
function addNoteLookup(key, note) {
  const normalizedKey = key.toLowerCase()
  const matches = noteLookup.get(normalizedKey) ?? []
  matches.push(note)
  noteLookup.set(normalizedKey, matches)
}

for (const note of notes) {
  addNoteLookup(note.withoutExtension, note)
  addNoteLookup(note.basename, note)
  for (const alias of note.aliases) addNoteLookup(alias, note)
}

function resolveNote(target, sourceNote) {
  const cleanTarget = target.split("#")[0].replace(/\.md$/i, "").trim()
  if (!cleanTarget) return sourceNote

  const sourceDirectory = path.posix.dirname(sourceNote.withoutExtension)
  const relativeTarget = path.posix.normalize(path.posix.join(sourceDirectory, cleanTarget))
  const candidates = [
    ...(noteLookup.get(cleanTarget.toLowerCase()) ?? []),
    ...(noteLookup.get(relativeTarget.toLowerCase()) ?? []),
    ...(noteLookup.get(path.posix.basename(cleanTarget).toLowerCase()) ?? []),
  ]
  return [...new Set(candidates)].length === 1 ? candidates[0] : undefined
}

const assetLookup = new Map()
for (const asset of assetFiles) {
  const name = path.basename(asset).toLowerCase()
  const matches = assetLookup.get(name) ?? []
  matches.push(asset)
  assetLookup.set(name, matches)
}

const copiedAssets = new Set()
function copyAsset(target, sourceNote) {
  const cleanTarget = target.split("|")[0].split("#")[0].trim()
  const decodedTarget = decodeURIComponent(cleanTarget)
  const relativeCandidate = path.resolve(
    path.dirname(sourceNote.absolutePath),
    decodedTarget,
  )

  let sourceAsset
  if (
    relativeCandidate.startsWith(vaultRoot + path.sep) &&
    fs.existsSync(relativeCandidate) &&
    fs.statSync(relativeCandidate).isFile()
  ) {
    sourceAsset = relativeCandidate
  } else {
    const matches = assetLookup.get(path.basename(decodedTarget).toLowerCase()) ?? []
    if (matches.length === 1) sourceAsset = matches[0]
  }

  if (!sourceAsset) return false
  const relativeAsset = path.relative(vaultRoot, sourceAsset)
  const destination = path.join(outputRoot, relativeAsset)
  fs.mkdirSync(path.dirname(destination), { recursive: true })
  fs.copyFileSync(sourceAsset, destination)
  copiedAssets.add(normalize(relativeAsset))
  return true
}

function sanitizeNote(note) {
  let text = note.text.replace(
    /```dataview(?:js)?\s*\n[\s\S]*?```/gi,
    "> [!note] 公開サイトではDataviewの動的表示を省略している。",
  )

  text = text.replace(/(!?)\[\[([^\]]+)\]\]/g, (full, embed, rawTarget) => {
    const [target, display] = rawTarget.split("|")
    if (embed && /\.(png|jpe?g|gif|svg|webp|avif)(?:#.*)?$/i.test(target)) {
      return copyAsset(target, note) ? full : "（画像を公開していない）"
    }

    const resolved = resolveNote(target, note)
    if (resolved?.published) return full

    const label =
      display?.trim() ||
      path.posix.basename(target.split("#")[0].replace(/\.md$/i, "")) ||
      target.replace(/^#/, "")
    return embed ? `> 公開対象外の参照: ${label}` : label
  })

  text = text.replace(
    /!\[([^\]]*)\]\(([^)]+)\)/g,
    (full, alt, target) => (copyAsset(target, note) ? full : alt || "（画像を公開していない）"),
  )

  return text
}

if (fs.existsSync(outputRoot)) {
  fs.rmSync(outputRoot, { recursive: true, force: true })
}
fs.mkdirSync(outputRoot, { recursive: true })

for (const note of publishedNotes) {
  const destination = path.join(outputRoot, note.relativePath)
  fs.mkdirSync(path.dirname(destination), { recursive: true })
  fs.writeFileSync(destination, sanitizeNote(note), "utf8")
}

const indexLines = [
  "---",
  'title: "学習・研究ノート"',
  "publish: true",
  "---",
  "",
  "# 学習・研究ノート",
  "",
  "Obsidianで管理しているノートのうち、公開を許可したものだけを掲載している。",
  "",
  "## 公開ノート",
  "",
  ...publishedNotes
    .sort((left, right) => left.title.localeCompare(right.title, "ja"))
    .map((note) => `- [[${note.withoutExtension}|${note.title}]]`),
  "",
]
fs.writeFileSync(path.join(outputRoot, "index.md"), indexLines.join("\n"), "utf8")

const manifest = {
  generatedAt: new Date().toISOString(),
  publishedNotes: publishedNotes.map((note) => note.relativePath).sort(),
  copiedAssets: [...copiedAssets].sort(),
}
fs.writeFileSync(
  path.join(outputRoot, "publication-manifest.json"),
  `${JSON.stringify(manifest, null, 2)}\n`,
  "utf8",
)

console.log(`Exported ${publishedNotes.length} public notes and ${copiedAssets.size} assets.`)
