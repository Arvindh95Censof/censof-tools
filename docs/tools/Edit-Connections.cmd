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

echo   Using   : %EXE%
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
  echo   script, so it will not see it - and a plugin binary older than 0.81.0rc14
  echo   still looks under AppData by default. Run this once, then restart Claude:
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
