param(
  [ValidateSet("All", "Links", "Naming", "Structure", "Index", "Inbox", "Mocs")]
  [string[]]$Check = @("All")
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $Root

$IntroFile = (-join @([char]0x306F, [char]0x3058, [char]0x3081, [char]0x306B)) + ".md"
$MemoSuffix = "_" + (-join @([char]0x30E1, [char]0x30E2)) + ".md"
$MocPrefix = ([string][char]0x3010) + "MOC" + ([string][char]0x3011)

function Test-Selected($Name) {
  return $Check -contains "All" -or $Check -contains $Name
}

function Get-NoteFiles {
  Get-ChildItem -Path "00_Inbox", "10_Projects", "20_Areas", "30_Resources", "40_Archives" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue
}

function Get-IndexedPaths {
  if (-not (Test-Path "VAULT_INDEX.md")) { return @() }
  $text = Get-Content -Raw -Encoding UTF8 "VAULT_INDEX.md"
  [regex]::Matches($text, '`([^`]+\.(?:md|ps1))`') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
}

function Get-AllIndexedCandidateFiles {
  Get-ChildItem -Path "." -Recurse -File -Include "*.md", "*.ps1" -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -notmatch '\\\.git\\' -and
      $_.FullName -notmatch '\\\.obsidian\\' -and
      $_.FullName -notmatch '\\\.claude\\' -and
      $_.FullName -notmatch '\\\.claude\\settings\.local\.json$'
    }
}

function Get-Aliases($File) {
  $lines = Get-Content -Encoding UTF8 -LiteralPath $File.FullName
  $aliases = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^aliases:\s*$') {
      for ($j = $i + 1; $j -lt $lines.Count -and $j -lt $i + 12; $j++) {
        if ($lines[$j] -match '^\s*-\s*(.+?)\s*$') { $aliases.Add($Matches[1]) }
        elseif ($lines[$j] -match '^\S') { break }
      }
    }
  }
  $aliases
}

if ((Test-Selected "Links")) {
  "## Broken links"
  $targets = New-Object System.Collections.Generic.HashSet[string]
  foreach ($file in Get-AllIndexedCandidateFiles) {
    [void]$targets.Add([IO.Path]::GetFileNameWithoutExtension($file.Name))
    foreach ($alias in Get-Aliases $file) {
      if ($alias) { [void]$targets.Add($alias) }
    }
  }

  $broken = New-Object System.Collections.Generic.List[string]
  foreach ($file in Get-NoteFiles) {
    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName
    foreach ($m in [regex]::Matches($text, '\[\[([^\]]+)\]\]')) {
      $target = ($m.Groups[1].Value -split '\|')[0] -split '#'
      $name = $target[0].Trim()
      if (-not $name -or $name -match '\.(pdf|png|jpg|jpeg|gif|canvas|excalidraw)$') { continue }
      if (-not $targets.Contains($name)) {
        $rel = Resolve-Path -Relative $file.FullName
        $broken.Add("BROKEN [[$name]] <- $rel")
      }
    }
  }
  if ($broken.Count) { $broken | Sort-Object -Unique } else { "OK: no broken wiki links found." }
  ""
}

if ((Test-Selected "Naming")) {
  "## Naming"
  $issues = New-Object System.Collections.Generic.List[string]

  Get-ChildItem -Path "20_Areas" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{8}_' -and $_.Name -notlike "$MocPrefix*" -and $_.DirectoryName -notmatch 'B4' } |
    ForEach-Object { $issues.Add("DATE_PREFIX_UNDER_AREAS: $((Resolve-Path -Relative $_.FullName))") }

  Get-ChildItem -Path "30_Resources" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object {
      (Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName) -match "(?m)^\s*-\s*paper\s*$" -and $_.Name -notlike "*$MemoSuffix"
    } |
    ForEach-Object { $issues.Add("PAPER_NOT_MEMO_SUFFIX: $((Resolve-Path -Relative $_.FullName))") }

  Get-NoteFiles |
    Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}_' } |
    ForEach-Object { $issues.Add("HYPHEN_DATE_PREFIX: $((Resolve-Path -Relative $_.FullName))") }

  if ($issues.Count) { $issues } else { "OK: no obvious naming issues found." }
  ""
}

if ((Test-Selected "Structure")) {
  "## Structure"
  $issues = New-Object System.Collections.Generic.List[string]

  foreach ($file in Get-NoteFiles) {
    if ($file.Name -eq $IntroFile) { continue }

    $rel = (Resolve-Path -Relative $file.FullName)
    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName
    $lines = Get-Content -Encoding UTF8 -LiteralPath $file.FullName
    $isMoc = $file.Name -like "$MocPrefix*"

    if ($text -notmatch '\A---\r?\n(?<fm>[\s\S]*?)\r?\n---(?:\r?\n|$)') {
      $issues.Add("MISSING_FRONTMATTER: $rel")
    }
    else {
      $frontmatter = $Matches['fm']
      if ($frontmatter -notmatch '(?m)^tags:\s*') {
        $issues.Add("MISSING_TAGS: $rel")
      }
      if ($isMoc) {
        if ($frontmatter -notmatch '(?m)^created:\s*\d{4}-\d{2}-\d{2}\s*$') {
          $issues.Add("MISSING_MOC_CREATED: $rel")
        }
        if ($frontmatter -notmatch '(?m)^status:\s*\S+\s*$') {
          $issues.Add("MISSING_MOC_STATUS: $rel")
        }
      }
      elseif ($frontmatter -notmatch '(?m)^date:\s*\d{4}-\d{2}-\d{2}\s*$') {
        $issues.Add("MISSING_DATE: $rel")
      }
      else {
        $fmDate = [regex]::Match($frontmatter, '(?m)^date:\s*(\d{4}-\d{2}-\d{2})\s*$').Groups[1].Value
        if ($fmDate) {
          $gitFirst = git log --follow --format="%as" -- $file.FullName 2>$null | Select-Object -Last 1
          if ($gitFirst -and $gitFirst -ne $fmDate) {
            $diff = [math]::Abs(([datetime]::Parse($fmDate) - [datetime]::Parse($gitFirst)).TotalDays)
            if ($diff -gt 30) {
              $issues.Add("DATE_MISMATCH: $rel (frontmatter=$fmDate, git-first=$gitFirst)")
            }
          }
        }
      }
    }

    if ($text -notmatch '(?m)^# [^#\r\n]') {
      $issues.Add("MISSING_H1: $rel")
    }
    if ($text -match '<%\s*tp\.') {
      $issues.Add("TEMPLATE_VARIABLE_LEFT: $rel")
    }
    if ($text -match '(?m)^#{1,6}\s+Topic\d+\b') {
      $issues.Add("TOPIC_SPACING: $rel")
    }

    $previousLevel = 0
    $insideFence = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
      $line = $lines[$i]
      if ($line -match '^\s*```') {
        $insideFence = -not $insideFence
        continue
      }
      if ($insideFence -or $line -notmatch '^(#{1,6})\s+\S') { continue }

      $level = $Matches[1].Length
      if ($previousLevel -gt 0 -and $level -gt ($previousLevel + 1)) {
        $issues.Add("HEADING_JUMP: ${rel}:$($i + 1) (H$previousLevel -> H$level)")
        break
      }
      $previousLevel = $level
    }
  }

  if (Test-Path "VAULT_INDEX.md") {
    $indexText = Get-Content -Raw -Encoding UTF8 "VAULT_INDEX.md"
    $today = (Get-Date).ToString("yyyy-MM-dd")
    if ($indexText -notmatch "(?m)^updated:\s*$([regex]::Escape($today))\s*$") {
      $issues.Add("STALE_INDEX_UPDATED: .\VAULT_INDEX.md (expected $today)")
    }
  }

  if ($issues.Count) { $issues | Sort-Object -Unique } else { "OK: no structural issues found." }
  ""
}

if ((Test-Selected "Index")) {
  "## VAULT_INDEX consistency"
  $indexed = Get-IndexedPaths
  $all = Get-AllIndexedCandidateFiles | ForEach-Object { (Resolve-Path -Relative $_.FullName).TrimStart(".\") }

  "### Indexed but maybe missing"
  $missing = foreach ($p in $indexed) {
    $base = Split-Path -Leaf $p
    if (-not ($all | Where-Object { $_ -eq $p -or (Split-Path -Leaf $_) -eq $base })) { "MISSING: $p" }
  }
  if ($missing) { $missing } else { "OK" }

  "### Existing but maybe unlisted"
  $unlisted = foreach ($p in $all) {
    $base = Split-Path -Leaf $p
    if ($p -like "00_Inbox\*" -or $p -like "40_Archives\*") { continue }
    if (-not ($indexed | Where-Object { $_ -eq $p -or (Split-Path -Leaf $_) -eq $base })) { "UNLISTED: $p" }
  }
  if ($unlisted) { $unlisted } else { "OK" }
  ""
}

if ((Test-Selected "Inbox")) {
  "## Inbox"
  $inbox = Get-ChildItem -Path "00_Inbox" -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object { $_.Name -ne $IntroFile }
  if ($inbox) { $inbox | ForEach-Object { "INBOX: $($_.Name)" } } else { "OK: Inbox is clean." }
  ""
}

if ((Test-Selected "Mocs")) {
  "## MOC missing candidates"
  $mocs = Get-ChildItem -Path "10_Projects", "20_Areas", "30_Resources" -Recurse -File -Filter "$MocPrefix*.md" -ErrorAction SilentlyContinue
  $mocText = ($mocs | ForEach-Object { Get-Content -Raw -Encoding UTF8 -LiteralPath $_.FullName }) -join "`n"
  $candidates = Get-ChildItem -Path "10_Projects", "20_Areas", "30_Resources" -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike "$MocPrefix*" }
  $misses = foreach ($file in $candidates) {
    $name = [IO.Path]::GetFileNameWithoutExtension($file.Name)
    if ($mocText -notmatch [regex]::Escape("[[$name]]") -and $mocText -notmatch [regex]::Escape($file.Name)) {
      "MOC_MAYBE_MISSING: $((Resolve-Path -Relative $file.FullName))"
    }
  }
  if ($misses) { $misses } else { "OK: no MOC missing candidates found." }
  ""
}
