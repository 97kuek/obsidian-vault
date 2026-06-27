$ErrorActionPreference = 'Stop'

$path = Resolve-Path '20_Areas/授業/人工知能_課題まとめ.md'
$text = [IO.File]::ReadAllText($path)
$text = [regex]::Replace($text, '(?m)^#### ', '### ')
$text = [regex]::Replace($text, '(?m)^### (解答\d+)', '#### $1')
$text = [regex]::Replace($text, '(?m)^## (パート[①②])', '### $1')
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText($path, $text, $utf8NoBom)
