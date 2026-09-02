<#
    Stores your knowledge-base token.

    It sets TWO variables from one prompt, because the same token is read under
    two names:

        CENSOF_MCP_TOKEN   the censof-mcp plugin (knowledge base search)
        KB_TOKEN           grp-mcp's write preflight, via kb_server.json

    Setting one and not the other is the single most common half-working setup:
    search works and the write preflight silently does not, or the reverse.
    Setting both is harmless if you only installed one plugin -- the unused
    variable is simply never read.

    Deliberately NOT `setx`. A command line is visible to every process running
    as you -- Task Manager shows it, any script can read it out of the process
    list -- so passing a secret as an argument leaks it. It also lands in your
    PowerShell history file on disk. This prompts inside PowerShell and writes
    straight to your user environment, so the value never appears on a command
    line, in a history file, or echoed back.
#>
$ErrorActionPreference = 'Stop'
$VARS = @('CENSOF_MCP_TOKEN', 'KB_TOKEN')

Write-Host ''
Write-Host '  GRP knowledge base - set your token' -ForegroundColor Cyan
Write-Host '  ==================================='
Write-Host ''
Write-Host '  This sets both variables the token is read under:'
Write-Host '    CENSOF_MCP_TOKEN  - knowledge base search (censof-mcp)'
Write-Host '    KB_TOKEN          - write preflight (grp-mcp)'
Write-Host ''

$existing = @{}
foreach ($v in $VARS) { $existing[$v] = [Environment]::GetEnvironmentVariable($v, 'User') }
$already = @($VARS | Where-Object { $existing[$_] })

if ($already.Count -gt 0) {
    foreach ($v in $already) {
        Write-Host ("  {0} is already set ({1} characters)." -f $v, $existing[$v].Length)
    }
    if ($already.Count -eq 1) {
        $missing = @($VARS | Where-Object { -not $existing[$_] })
        Write-Host ("  {0} is NOT set - that is the half-working case this fixes." -f $missing[0]) -ForegroundColor Yellow
    }
    Write-Host ''
    $go = Read-Host '  Enter the token again and set both? (y/N)'
    if ($go -ne 'y') {
        Write-Host '  Left unchanged.' -ForegroundColor Yellow
        exit 0
    }
    Write-Host ''
}

Write-Host '  Paste the token, then press Enter. It will not be shown.'
Write-Host '  (Right-click pastes into this window. It starts with grpkb_)'
Write-Host ''

$sec = Read-Host '  Token' -AsSecureString
$bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
try   { $tok = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr) }
finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) }

$tok = $tok.Trim()

# People paste the whole header. Store only the token -- kb_server.json and
# .mcp.json both supply the "Bearer " prefix themselves, and a doubled one fails
# with a 401 that names nothing useful.
if ($tok -match '^(?i)bearer\s+') {
    $tok = $tok -replace '^(?i)bearer\s+', ''
    Write-Host '  (removed the leading "Bearer " - only the token itself is stored)'
}

if (-not $tok) {
    Write-Host '  Nothing entered. Nothing changed.' -ForegroundColor Yellow
    exit 1
}
if ($tok -notmatch '^grpkb_') {
    Write-Host ''
    Write-Host '  Warning: that does not start with grpkb_, which these tokens do.' -ForegroundColor Yellow
    $ok = Read-Host '  Store it anyway? (y/N)'
    if ($ok -ne 'y') { Write-Host '  Nothing changed.'; exit 1 }
}

Write-Host ''
$failed = $false
foreach ($v in $VARS) {
    [Environment]::SetEnvironmentVariable($v, $tok, 'User')
    if ([Environment]::GetEnvironmentVariable($v, 'User') -eq $tok) {
        Write-Host ("  {0,-18} stored ({1} characters)" -f $v, $tok.Length) -ForegroundColor Green
    } else {
        Write-Host ("  {0,-18} FAILED - did not read back. Do not rely on it." -f $v) -ForegroundColor Red
        $failed = $true
    }
}
if ($failed) { exit 1 }

Write-Host ''
Write-Host '  Now RESTART Claude Code completely. A running program keeps the'
Write-Host '  environment it started with, so it will not see this until then.'
Write-Host ''
Write-Host '  Then check whichever you installed:'
Write-Host '    censof-mcp  - ask it to search the knowledge base for anything'
Write-Host '    grp-mcp     - ask for kb_status; expect variable_is_set: true'
Write-Host ''
