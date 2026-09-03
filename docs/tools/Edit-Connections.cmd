@echo off
setlocal enabledelayedexpansion
title GRP MCP - Edit Connections

rem ---------------------------------------------------------------------------
rem Opens the GRP MCP config page using the copy of grp-mcp.exe that the plugin
rem already installed, pointed at the connections.json the SERVER actually uses.
rem
rem Why a launcher: the binary lives at a ~90-character path that people mistype,
rem and the cache copy carries the VERSION in it, so any path written into a
rem document breaks at the next release. This finds it instead.
rem ---------------------------------------------------------------------------

echo.
echo   GRP MCP - Edit Connections
echo   ==========================
echo.

rem ===========================================================================
rem 1. Find the binary.
rem ===========================================================================

set "EXE="

rem 1a. The marketplace clone. Preferred: no version in the path, so it survives
rem     upgrades.
set "MP=%USERPROFILE%\.claude\plugins\marketplaces\censof-tools\plugins\grp-mcp\server\grp-mcp.exe"
if exist "%MP%" set "EXE=%MP%"

rem 1b. The installed cache copy. Sorted NEWEST-DATE first, not by name: the
rem     names are rc9, rc10, rc11, rc12 and a NAME sort puts rc9 on top, which
rem     would launch the oldest build on any machine that has more than one.
if not defined EXE (
  for /f "delims=" %%D in ('dir /b /a:d /o-d "%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp" 2^>nul') do (
    if not defined EXE if exist "%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\%%D\server\grp-mcp.exe" (
      set "EXE=%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\%%D\server\grp-mcp.exe"
    )
  )
)

rem 1c. The Claude Desktop extension, if that is how it was installed instead.
if not defined EXE (
  set "EXT=%APPDATA%\Claude\Claude Extensions\local.mcpb.Censof.grp-mcp\server\grp-mcp.exe"
  if exist "!EXT!" set "EXE=!EXT!"
)

rem 1d. The standalone setup binary, if it was placed beside this file.
if not defined EXE if exist "%~dp0GRP-MCP-Setup.exe" (
  set "EXE=%~dp0GRP-MCP-Setup.exe"
  set "STANDALONE=1"
)

if not defined EXE (
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
rem Claude installs as an MSIX package. Everything IT launches - including the
rem grp-mcp server - runs INSIDE that package container, where writes to
rem %%LOCALAPPDATA%%\grp-mcp are silently redirected to
rem   %%LOCALAPPDATA%%\Packages\Claude_<id>\LocalCache\Local\grp-mcp
rem This .cmd is double-clicked from Explorer, which is OUTSIDE the container,
rem so the very same %%LOCALAPPDATA%%\grp-mcp is a DIFFERENT folder - normally
rem an empty one.
rem
rem Measured 2026-09-03 on a working install: PowerShell (outside) saw
rem AppData\Local\grp-mcp EMPTY while the container copy held 12 profiles. The
rem editor opened on nothing and reported "No profiles yet" - which reads as a
rem broken or out-of-date UI, and a Save from that state would have written a
rem SECOND connections.json that the server never reads. Nothing errors; the
rem edits just never take effect.
rem
rem GRP_MCP_CONNECTIONS beats every other candidate in load_config(), and
rem kb_client.default_spec_path() places kb_server.json beside whatever it
rem names - so setting this one variable fixes both files.
rem ===========================================================================

set "CFG="
set "CFGWHY="
set "PLAIN=%LOCALAPPDATA%\grp-mcp\connections.json"

rem 2a. An explicit override wins here exactly as it does in the server.
if defined GRP_MCP_CONNECTIONS (
  set "CFG=%GRP_MCP_CONNECTIONS%"
  set "CFGWHY=GRP_MCP_CONNECTIONS was already set"
)

rem 2b. An existing config inside the Claude container. Newest package first,
rem     in case an old one was left behind by a previous install.
if not defined CFG (
  for /f "delims=" %%P in ('dir /b /a:d /o-d "%LOCALAPPDATA%\Packages\Claude_*" 2^>nul') do (
    if not defined CFG if exist "%LOCALAPPDATA%\Packages\%%P\LocalCache\Local\grp-mcp\connections.json" (
      set "CFG=%LOCALAPPDATA%\Packages\%%P\LocalCache\Local\grp-mcp\connections.json"
      set "CFGWHY=found in the Claude app container - %%P"
    )
  )
)

rem 2c. An existing config in the plain location - a non-packaged Claude, or
rem     the CLI installed on its own.
if not defined CFG if exist "%PLAIN%" (
  set "CFG=%PLAIN%"
  set "CFGWHY=found in the standard location"
)

rem 2d. Nothing exists yet: FIRST RUN. Write where the server will LOOK, which
rem     for a packaged Claude is inside the container. Getting this wrong is the
rem     same bug in reverse - a first profile saved outside the container is
rem     invisible to the server that is supposed to load it.
if not defined CFG (
  for /f "delims=" %%P in ('dir /b /a:d /o-d "%LOCALAPPDATA%\Packages\Claude_*" 2^>nul') do (
    if not defined CFG if exist "%LOCALAPPDATA%\Packages\%%P\LocalCache\Local" (
      set "CFG=%LOCALAPPDATA%\Packages\%%P\LocalCache\Local\grp-mcp\connections.json"
      set "CFGWHY=first run - creating it in the Claude app container"
    )
  )
)
if not defined CFG (
  set "CFG=%PLAIN%"
  set "CFGWHY=first run - no Claude package container on this machine"
)

set "GRP_MCP_CONNECTIONS=%CFG%"

rem A config in BOTH places usually means someone already hit this and saved
rem into the copy the server ignores. Report it, but do NOT tell anyone to
rem delete it: if this .cmd is ever run from a terminal that Claude itself
rem spawned, that terminal is inside the container too, %LOCALAPPDATA%\grp-mcp
rem redirects, and the "other" file is THE SAME FILE under a second name.
rem Deleting on that advice would destroy the live config.
set "OTHER="
if /i not "%CFG%"=="%PLAIN%" if exist "%PLAIN%" set "OTHER=%PLAIN%"

echo   Using   : %EXE%
echo   Config  : %CFG%
echo             %CFGWHY%
echo.
if defined OTHER (
  echo   NOTE: a connections.json also exists at
  echo         %OTHER%
  echo         The path above is the one being edited. If that second file is a
  echo         leftover, the server is not reading it - but check before deleting
  echo         anything, because on some setups both paths reach the same file.
  echo.
)
echo   Your browser will open on http://127.0.0.1:8765
echo   Add your instance, click Save, then CLOSE THIS WINDOW and restart Claude.
echo.

if defined STANDALONE (
  "%EXE%"
) else (
  "%EXE%" --setup
)

echo.
echo   Config page stopped.
pause
