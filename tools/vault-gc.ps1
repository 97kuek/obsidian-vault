$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $Root

$PermanentDirName = -join @([char]0x6C38, [char]0x7D9A, [char]0x30CE, [char]0x30FC, [char]0x30C8)
$MocPrefix = ([string][char]0x3010) + "MOC" + ([string][char]0x3011)

function Get-NoteFiles {
  Get-ChildItem -Path "20_Areas", "30_Resources", "10_Projects" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike "$MocPrefix*" }
}

"## Knowledge note inventory"
Get-NoteFiles | ForEach-Object {
  $lineCount = (Get-Content -Encoding UTF8 -LiteralPath $_.FullName | Measure-Object -Line).Lines
  $heading = (Select-String -LiteralPath $_.FullName -Pattern '^#{1,2}\s+' -Encoding UTF8 | Select-Object -First 1).Line
  $last = git log -1 --format=%as -- $_.FullName 2>$null
  if (-not $last) { $last = "?" }
  "{0} | {1} lines | {2} | {3}" -f (Resolve-Path -Relative $_.FullName), $lineCount, $last, ($heading -replace '^#+\s+', '')
}

""
"## Split candidates: permanent notes over 120 lines"
$permanentDir = Get-ChildItem -Path "20_Areas" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq $PermanentDirName } | Select-Object -First 1
if ($permanentDir) {
  $large = Get-ChildItem -LiteralPath $permanentDir.FullName -File -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike "$MocPrefix*" -and (Get-Content -Encoding UTF8 -LiteralPath $_.FullName | Measure-Object -Line).Lines -gt 120 }
  if ($large) {
    $large | ForEach-Object {
      $n = (Get-Content -Encoding UTF8 -LiteralPath $_.FullName | Measure-Object -Line).Lines
      "{0} lines  {1}" -f $n, (Resolve-Path -Relative $_.FullName)
    }
  } else {
    "OK: no permanent notes over 120 lines found."
  }
} else {
  "SKIP: permanent note directory not found."
}

""
"## Stale candidates: no git update in 90 days"
$cutoff = (Get-Date).AddDays(-90)
$stale = foreach ($file in Get-NoteFiles) {
  $dateText = git log -1 --format=%as -- $file.FullName 2>$null
  if ($dateText) {
    $date = [datetime]::Parse($dateText)
    if ($date -lt $cutoff) { "{0}  {1}" -f $dateText, (Resolve-Path -Relative $file.FullName) }
  }
}
if ($stale) { $stale } else { "OK: no stale candidates found." }

""
"## Zero-backlink candidates: permanent notes"
$linked = New-Object System.Collections.Generic.HashSet[string]
Get-ChildItem -Path "00_Inbox", "10_Projects", "20_Areas", "30_Resources", "40_Archives" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
  ForEach-Object {
    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName
    foreach ($m in [regex]::Matches($text, '\[\[([^\]]+)\]\]')) {
      $name = (($m.Groups[1].Value -split '\|')[0] -split '#')[0].Trim()
      if ($name) { [void]$linked.Add($name) }
    }
  }

if ($permanentDir) {
  Get-ChildItem -LiteralPath $permanentDir.FullName -File -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike "$MocPrefix*" } |
    ForEach-Object {
      $name = [IO.Path]::GetFileNameWithoutExtension($_.Name)
      if (-not $linked.Contains($name)) { "NO_BACKLINK: $((Resolve-Path -Relative $_.FullName))" }
    }
}

""
"## Merge hints: notes sharing 2+ tags (excluding MOC/review/permanent)"
$tagExclude = @("MOC", "review", "weekly", "monthly", "permanent", "paper", "draft", "project", "experiment")
$noteTagMap = @{}
Get-NoteFiles | ForEach-Object {
  $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName
  if ($content -match '(?s)^---(.+?)---') {
    $fm = $Matches[1]
    $tags = [regex]::Matches($fm, '^\s+-\s+(\S+)', [System.Text.RegularExpressions.RegexOptions]::Multiline) |
      ForEach-Object { $_.Groups[1].Value } |
      Where-Object { $_ -notin $tagExclude }
    if ($tags.Count -gt 0) {
      $noteTagMap[$_.FullName] = @($tags)
    }
  }
}
$paths = @($noteTagMap.Keys)
$merged = New-Object System.Collections.Generic.HashSet[string]
$hints = foreach ($i in 0..($paths.Count - 2)) {
  foreach ($j in ($i+1)..($paths.Count - 1)) {
    $a = $paths[$i]; $b = $paths[$j]
    $key = "$a|$b"
    if ($merged.Contains($key)) { continue }
    $shared = $noteTagMap[$a] | Where-Object { $noteTagMap[$b] -contains $_ }
    if ($shared.Count -ge 2) {
      [void]$merged.Add($key)
      "SHARED_TAGS({0}): {1}  <->  {2}" -f ($shared -join ","), (Resolve-Path -Relative $a), (Resolve-Path -Relative $b)
    }
  }
}
if ($hints) { $hints } else { "OK: no merge hint pairs found." }

