param(
  [Parameter(Mandatory = $true)]
  [string[]]$Path
)

$allowed = ".obsidian\snippets\vault-custom.css"
$blocked = @()

foreach ($item in $Path) {
  $normalized = $item -replace '/', '\'
  if ($normalized -match '(^|\\)\.obsidian\\' -and $normalized -notlike "*$allowed") {
    $blocked += $item
  }
}

if ($blocked.Count -gt 0) {
  Write-Error ".obsidian is protected. Only .obsidian/snippets/vault-custom.css may be edited. Target: $($blocked -join ', ')"
  exit 1
}

Write-Output "OK: obsidian protection check passed."

