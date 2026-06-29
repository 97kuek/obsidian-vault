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

// サイドカー folder-note の検出（例 `授業/人工知能.md` ＋ 同名フォルダ `授業/人工知能/`）。
// この種のノートを持つ vault では Quartz のリンク解決（pathToRoot）が末尾スラッシュ配信の
// URL と 1 段ずれ、パス二重化（404）や base 突き抜け（ポートフォリオへ誤遷移）を起こす。
// 対策は exportRelativePath（ハブを `<folder>/index.md` に配置）と sanitizeNote（ハブ宛
// リンクをフルパスに正規化）の二段構え。childDirectories はノートを含むディレクトリ集合。
const childDirectories = new Set(
  publishedNotes
    .map((note) => path.posix.dirname(note.withoutExtension))
    .filter((dir) => dir !== "."),
)
const folderNoteHubs = new Set(
  publishedNotes
    .map((note) => note.withoutExtension)
    .filter((withoutExtension) => childDirectories.has(withoutExtension)),
)

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
    if (resolved?.published) {
      // ハブ（folder-note）宛のリンクは bare basename だと Quartz が root スラグと誤認し 404 になる。
      // フルパスへ正規化すると `/<base>/<hub>` を出力でき、GitHub Pages が `/<hub>/` へ 301 する。
      if (!embed && folderNoteHubs.has(resolved.withoutExtension)) {
        const label =
          display?.trim() ||
          path.posix.basename(target.split("#")[0].replace(/\.md$/i, "")) ||
          resolved.basename
        return `[[${resolved.withoutExtension}|${label}]]`
      }
      return full
    }

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

function exportRelativePath(note) {
  // 同名の子フォルダを持つノート（folder-note ハブ）はフォルダの index として配置する。
  // これで Quartz が初めからスラグ `.../index` を割り当て、pathToRoot が正しくなる。
  if (folderNoteHubs.has(note.withoutExtension)) {
    return `${note.withoutExtension}/index.md`
  }
  return note.relativePath
}

for (const note of publishedNotes) {
  const destination = path.join(outputRoot, exportRelativePath(note))
  fs.mkdirSync(path.dirname(destination), { recursive: true })
  fs.writeFileSync(destination, sanitizeNote(note), "utf8")
}

// 公開ノートをフォルダ階層のツリーに組み立てる（ホームを羅列でなく分類表示にする）。
function buildTree(notes) {
  const root = { dirs: new Map(), files: [] }
  for (const note of notes) {
    const parts = note.withoutExtension.split("/")
    parts.pop() // ファイル名を除いた残りがフォルダ階層
    let node = root
    for (const dir of parts) {
      if (!node.dirs.has(dir)) node.dirs.set(dir, { dirs: new Map(), files: [] })
      node = node.dirs.get(dir)
    }
    node.files.push(note)
  }
  return root
}

const collator = new Intl.Collator("ja", { numeric: true })
function sortedFiles(files) {
  // MOC を各フォルダの先頭に、それ以外はファイル名順。
  // ファイル名基準にすると `_01_`,`_02_` の連番ノートが章番号どおりに並ぶ。
  return files.slice().sort((left, right) => {
    const leftMoc = left.basename.includes("【MOC】")
    const rightMoc = right.basename.includes("【MOC】")
    if (leftMoc !== rightMoc) return leftMoc ? -1 : 1
    return collator.compare(left.basename, right.basename)
  })
}

// withoutExtension からノートを引くための索引（folder-note ハブの見出しリンク化に使う）。
const noteByPath = new Map(publishedNotes.map((note) => [note.withoutExtension, note]))

// フォルダ＝見出し、ファイル＝リンクの入れ子リストを再帰生成する。
// フォルダに同名の folder-note ハブがあれば、見出し自体をそのハブへのリンクにし、
// ファイル一覧側では重複させない。
function renderNode(node, prefix, depth, lines) {
  const indent = "  ".repeat(depth)
  for (const name of [...node.dirs.keys()].sort(collator.compare)) {
    const childPrefix = prefix ? `${prefix}/${name}` : name
    const hub = noteByPath.get(childPrefix)
    lines.push(hub ? `${indent}- [[${hub.withoutExtension}|${name}]]` : `${indent}- **${name}**`)
    renderNode(node.dirs.get(name), childPrefix, depth + 1, lines)
  }
  for (const note of sortedFiles(node.files)) {
    if (folderNoteHubs.has(note.withoutExtension)) continue // 見出しに昇格済みなので省く
    lines.push(`${indent}- [[${note.withoutExtension}|${note.title}]]`)
  }
}

const tree = buildTree(publishedNotes)
// 大半が 20_Areas 配下なので、その直下のカテゴリを ## セクションとして展開する。
const areas = tree.dirs.get("20_Areas") ?? tree

const indexLines = [
  "---",
  'title: "Obsidian Browser"',
  "publish: true",
  "---",
  "",
  "# Obsidian Browser",
  "",
  "Obsidianで管理しているノートのうち、公開を許可したものだけを掲載している。",
  "",
]

// カテゴリ直下のノート（全体 MOC 等）を冒頭に出す。
for (const note of sortedFiles(areas.files)) {
  indexLines.push(`- [[${note.withoutExtension}|${note.title}]]`)
}
if (areas.files.length > 0) indexLines.push("")

// 各カテゴリを折りたたみコールアウトで出す（初期は畳んだ状態＝スマホで一覧が長くならない）。
for (const name of [...areas.dirs.keys()].sort(collator.compare)) {
  const lines = []
  renderNode(areas.dirs.get(name), `20_Areas/${name}`, 0, lines)
  const noteCount = lines.filter((line) => line.includes("[[")).length
  // `[!note]-` の末尾ハイフンで既定折りたたみ。中身は各行に `> ` を付けてコールアウト内に入れる。
  indexLines.push(`> [!note]- ${name}（${noteCount}）`)
  for (const line of lines) indexLines.push(`> ${line}`)
  indexLines.push("")
}

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
