@echo off
setlocal enabledelayedexpansion
title GRP MCP - Edit Connections

rem ---------------------------------------------------------------------------
rem Opens the GRP MCP config page, pointed at the connections.json the SERVER
rem actually uses.
rem
rem Why a launcher: nothing about how the server starts is stable enough to write
rem into a document. It used to be a binary at a ~90-character path that people
rem mistyped, in a cache folder carrying the VERSION. As of 0.81.0rc15 it is not a
rem binary at all -- the plugin runs the server from PyPI through uvx, and the
rem version is pinned inside the plugin's own .mcp.json. So this finds whichever
rem of those is present rather than naming one.
rem ---------------------------------------------------------------------------

echo.
echo   GRP MCP - Edit Connections
echo   ==========================
echo.

rem ===========================================================================
rem 1. Work out how to start the config page.
rem
rem uvx FIRST, when the plugin pins a version. That pin is the same string the
rem MCP server is launched with, so the config page is guaranteed to be the same
rem build as the server -- which the old exe-first order could not promise: after
rem an update the marketplace clone has no binary but a PREVIOUS version's cache
rem folder still does, and that stale exe would have won.
rem ===========================================================================

set "EXE="
set "PIN="
set "MODE="

rem 1a. The pinned version, read out of the plugin's own .mcp.json. Both plugin
rem     names are checked: grp-mcp-mac is the same package under an older name.
rem
rem     The pin is pulled by stripping quotes, commas and spaces off the matched
rem     line rather than by splitting on the quote character. `delims="` inside a
rem     quoted for /f options string is a syntax error -- measured, not assumed:
rem     it exits 255 with "The syntax of the command is incorrect."
for %%J in (
  "%USERPROFILE%\.claude\plugins\marketplaces\censof-tools\plugins\grp-mcp\.mcp.json"
  "%USERPROFILE%\.claude\plugins\marketplaces\censof-tools\plugins\grp-mcp-mac\.mcp.json"
) do (
  if not defined PIN if exist "%%~J" call :readpin "%%~J"
)

rem 1b. Not in the clone: look in the installed cache. Sorted NEWEST-DATE first,
rem     not by name -- the names are rc9, rc10, rc14, rc15 and a NAME sort puts
rem     rc9 on top, which would pick the oldest build on any machine with more
rem     than one.
if not defined PIN (
  for %%N in (grp-mcp grp-mcp-mac) do (
    for /f "delims=" %%D in ('dir /b /a:d /o-d "%USERPROFILE%\.claude\plugins\cache\censof-tools\%%N" 2^>nul') do (
      if not defined PIN if exist "%USERPROFILE%\.claude\plugins\cache\censof-tools\%%N\%%D\.mcp.json" (
        call :readpin "%USERPROFILE%\.claude\plugins\cache\censof-tools\%%N\%%D\.mcp.json"
      )
    )
  )
)

if defined PIN (
  where uvx >nul 2>nul
  if errorlevel 1 (
    echo   The plugin is installed and pins:
    echo       !PIN!
    echo   but uv is not on this machine, so nothing can run it.
    echo.
    echo   Install it once, then reopen this window:
    echo.
    echo       winget install astral-sh.uv
    echo.
    echo   Reopening matters - the installer adds a folder to PATH and an
    echo   already-open window will not see it.
    echo.
    pause
    exit /b 1
  )
  set "MODE=uvx"
)

rem 1c. LEGACY: a bundled binary from 0.81.0rc14 or earlier. Still honoured so a
rem     machine that has not updated yet keeps working.
if not defined MODE (
  set "MP=%USERPROFILE%\.claude\plugins\marketplaces\censof-tools\plugins\grp-mcp\server\grp-mcp.exe"
  if exist "!MP!" set "EXE=!MP!"

  if not defined EXE (
    for /f "delims=" %%D in ('dir /b /a:d /o-d "%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp" 2^>nul') do (
      if not defined EXE if exist "%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\%%D\server\grp-mcp.exe" (
        set "EXE=%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\%%D\server\grp-mcp.exe"
      )
    )
  )

  rem The Claude Desktop extension, if that is how it was installed instead.
  if not defined EXE (
    set "EXT=%APPDATA%\Claude\Claude Extensions\local.mcpb.Censof.grp-mcp\server\grp-mcp.exe"
    if exist "!EXT!" set "EXE=!EXT!"
  )

  if defined EXE set "MODE=exe"
)

rem 1d. The standalone setup binary, if it was placed beside this file. This is
rem     the route for creating a connections.json BEFORE anything is installed.
if not defined MODE if exist "%~dp0GRP-MCP-Setup.exe" (
  set "EXE=%~dp0GRP-MCP-Setup.exe"
  set "MODE=standalone"
)

if not defined MODE (
  echo   Could not find GRP MCP on this machine.
  echo.
  echo   Install the plugin first - see INSTALL-grp-mcp.md, Step 3. If you need to
  echo   create a connections file BEFORE installing anything, put
  echo   GRP-MCP-Setup.exe in this same folder and run this again.
  echo.
  pause
  exit /b 1
)

rem ===========================================================================
rem 2. Find the connections.json the SERVER actually reads.
rem
rem The default moved on 2026-09-04, and the move was paid for. It used to be
rem %%LOCALAPPDATA%%\grp-mcp. Claude installs as an MSIX package, so the server it
rem launches sees %%LOCALAPPDATA%% as the package's LocalCache -- and an app update
rem RESET that container overnight, deleting a user's connections.json holding
rem twelve profiles including live client credentials. It was recovered only
rem because an unrelated copy happened to still be in a OneDrive recycle bin. The
rem folder had been re-CREATED rather than emptied, which is what a LocalCache
rem reset looks like.
rem
rem The 2026-09-03 version of this script made that WORSE: it taught the config
rem page to write INTO the container, so the page and the server finally agreed
rem -- on a location an app update can delete.
rem
rem %%USERPROFILE%%\grp-mcp sits outside AppData, so no container maps it and no
rem update reaches it. Verified by listing the same path from inside the
rem container and outside: both see the same files, where AppData\grp-mcp showed
rem files to one and an empty folder to the other.
rem
rem Existing installs are NOT moved. Their file is found where it already is, and
rem the server writes back to whatever it loaded, so nothing forks into two.
rem ===========================================================================

set "CFG="
set "CFGWHY="
set "LEGACY="
set "HOMECFG=%USERPROFILE%\grp-mcp\connections.json"
set "PLAIN=%LOCALAPPDATA%\grp-mcp\connections.json"

rem 2a. An explicit override wins here exactly as it does in the server.
if defined GRP_MCP_CONNECTIONS (
  set "CFG=%GRP_MCP_CONNECTIONS%"
  set "CFGWHY=GRP_MCP_CONNECTIONS was already set"
)

rem 2b. The current default.
if not defined CFG if exist "%HOMECFG%" (
  set "CFG=%HOMECFG%"
  set "CFGWHY=found in the standard location"
)

rem 2c. LEGACY: inside the Claude container. Still read so an older install keeps
rem     working; never created here any more.
if not defined CFG (
  for /f "delims=" %%P in ('dir /b /a:d /o-d "%LOCALAPPDATA%\Packages\Claude_*" 2^>nul') do (
    if not defined CFG if exist "%LOCALAPPDATA%\Packages\%%P\LocalCache\Local\grp-mcp\connections.json" (
      set "CFG=%LOCALAPPDATA%\Packages\%%P\LocalCache\Local\grp-mcp\connections.json"
      set "CFGWHY=LEGACY - inside the Claude app container"
      set "LEGACY=1"
    )
  )
)

rem 2d. LEGACY: the plain AppData location.
if not defined CFG if exist "%PLAIN%" (
  set "CFG=%PLAIN%"
  set "CFGWHY=LEGACY - under AppData"
  set "LEGACY=1"
)

rem 2e. Nothing yet: FIRST RUN. Create it where an app update cannot reach it.
if not defined CFG (
  set "CFG=%HOMECFG%"
  set "CFGWHY=first run - creating it outside AppData, where updates cannot delete it"
)

set "GRP_MCP_CONNECTIONS=%CFG%"

rem A config in BOTH places usually means someone already hit the container split
rem and saved into the copy the server ignores. Report it, but do NOT tell anyone
rem to delete it: run this .cmd from a terminal Claude itself spawned and that
rem terminal is inside the container too, %%LOCALAPPDATA%%\grp-mcp redirects, and
rem the "other" file is THE SAME FILE under a second name.
set "OTHER="
if /i not "%CFG%"=="%PLAIN%" if exist "%PLAIN%" set "OTHER=%PLAIN%"

if "%MODE%"=="uvx" (
  echo   Using   : uvx --from !PIN! grp-mcp-setup
) else (
  echo   Using   : !EXE!
)
echo   Config  : %CFG%
echo             %CFGWHY%
echo.
if defined LEGACY (
  echo   NOTE: that file is somewhere a Claude app update can DELETE. It happened
  echo         on 2026-09-04 and cost twelve saved profiles. To move it somewhere
  echo         safe, close this window and run:
  echo.
  echo             move "%CFG%" "%USERPROFILE%\grp-mcp\"
  echo             setx GRP_MCP_CONNECTIONS "%USERPROFILE%\grp-mcp\connections.json"
  echo.
  echo         then restart Claude. Back the file up either way - it is the only
  echo         copy of your ERP credentials.
  echo.
)
if "%CFGWHY:~0,9%"=="first run" (
  echo   ONE-TIME STEP, and it matters. This window sets GRP_MCP_CONNECTIONS for
  echo   the config page only. The MCP server is started by Claude, not by this
  echo   script, so it will not see it - and a plugin older than 0.81.0rc14 still
  echo   looks under AppData by default. Run this once, then restart Claude:
  echo.
  echo       setx GRP_MCP_CONNECTIONS "%CFG%"
  echo.
)
if defined OTHER (
  echo   NOTE: a connections.json also exists at
  echo         %OTHER%
  echo         The path above is the one being edited. If that second file is a
  echo         leftover, the server is not reading it - but check before deleting
  echo         anything, because on some setups both paths reach the same file.
  echo.
)
if "%MODE%"=="uvx" (
  echo   First run downloads the package - allow a minute. Later runs are instant.
  echo.
)
echo   Your browser will open on http://127.0.0.1:8765
echo   Add your instance, click Save, then CLOSE THIS WINDOW and restart Claude.
echo.

if "%MODE%"=="uvx" (
  uvx --from "!PIN!" grp-mcp-setup
) else if "%MODE%"=="standalone" (
  "!EXE!"
) else (
  "!EXE!" --setup
)

echo.
echo   Config page stopped.
pause
exit /b 0

rem ---------------------------------------------------------------------------
rem :readpin <path to a plugin .mcp.json>   ->   sets PIN, or leaves it unset
rem
rem Pulls "grp-mcp-plugin[search]==<version>" out of the args array, using a real
rem JSON parser rather than string surgery. Both were tried. findstr plus
rem character-stripping works only while the file is pretty-printed one array
rem element per line: run against an installed cache copy, which writes
rem   "args": ["--from", "grp-mcp-plugin==0.81.0rc14", "grp-mcp"],
rem on one line, it yielded the pin "--fromgrp-mcp-plugin==0.81.0rc14grp-mcp" and
rem the script cheerfully offered to run it. Claude Code writes that file, so its
rem formatting is not ours to depend on.
rem
rem The path travels by environment variable, not inside the quoted -Command
rem string: a profile path containing an apostrophe would otherwise end the
rem PowerShell string literal early.
rem ---------------------------------------------------------------------------
:readpin
set "PINJSON=%~1"
set "RAW="
rem The pipes are NOT caret-escaped. Inside a double-quoted string cmd treats ^
rem as a literal character, so "a ^| b" hands PowerShell "^|" and it throws --
rem which the catch swallowed, leaving PIN unset and the script silently falling
rem back to a stale bundled .exe. Quoting already protects them from cmd.
for /f "usebackq delims=" %%V in (`powershell -NoProfile -ExecutionPolicy Bypass -Command "try{(Get-Content -Raw -LiteralPath $env:PINJSON | ConvertFrom-Json).mcpServers.'grp-mcp'.args | Where-Object{$_ -like 'grp-mcp-plugin*'} | Select-Object -First 1}catch{}" 2^>nul`) do set "RAW=%%V"
set "PINJSON="
if not defined RAW exit /b 0
set "PIN=%RAW%"
exit /b 0
