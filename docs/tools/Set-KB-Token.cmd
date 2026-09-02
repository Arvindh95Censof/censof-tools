@echo off
title GRP MCP - Set knowledge base token

rem The work is in Set-KB-Token.ps1 beside this file. This wrapper exists only so
rem the tool can be double-clicked: a .ps1 opens in Notepad on a default Windows
rem install rather than running.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Set-KB-Token.ps1"

echo.
pause
