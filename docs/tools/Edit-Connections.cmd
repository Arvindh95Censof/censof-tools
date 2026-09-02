@echo off
setlocal enabledelayedexpansion
title GRP MCP - Edit Connections

rem ---------------------------------------------------------------------------
rem Opens the GRP MCP config page using the copy of grp-mcp.exe that the plugin
rem already installed. Nothing to download and nothing to unzip.
rem
rem Why a launcher: the binary lives at a ~90-character path that people mistype,
rem and the cache copy carries the VERSION in it, so any path written into a
rem document breaks at the next release. This finds it instead.
rem ---------------------------------------------------------------------------

echo.
echo   GRP MCP - Edit Connections
echo   ==========================
echo.

set "EXE="

rem 1. The marketplace clone. Preferred: no version in the path, so it survives
rem    upgrades.
set "MP=%USERPROFILE%\.claude\plugins\marketplaces\censof-tools\plugins\grp-mcp\server\grp-mcp.exe"
if exist "%MP%" set "EXE=%MP%"

rem 2. The installed cache copy. Versioned, so take the newest by sort order.
if not defined EXE (
  for /f "delims=" %%D in ('dir /b /o-n "%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp" 2^>nul') do (
    if not defined EXE if exist "%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\%%D\server\grp-mcp.exe" (
      set "EXE=%USERPROFILE%\.claude\plugins\cache\censof-tools\grp-mcp\%%D\server\grp-mcp.exe"
    )
  )
)

rem 3. The Claude Desktop extension, if that is how it was installed instead.
if not defined EXE (
  set "EXT=%APPDATA%\Claude\Claude Extensions\local.mcpb.Censof.grp-mcp\server\grp-mcp.exe"
  if exist "!EXT!" set "EXE=!EXT!"
)

rem 4. The standalone setup binary, if it was placed beside this file.
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

echo   Using: %EXE%
echo.
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
