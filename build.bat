@echo off
setlocal

set ROOT=%~dp0
set SJASMPLUS=%ROOT%tools\sjasmplus\sjasmplus.exe
set SRC=%ROOT%src\main.asm
set OUT=%ROOT%bin

if not exist "%OUT%" mkdir "%OUT%"

echo Building ZX Spectrum 48K program...
"%SJASMPLUS%" "%SRC%"
if errorlevel 1 (
    echo Build FAILED.
    exit /b 1
)

echo Build OK.
echo Output: %OUT%\program.tap
dir /b "%OUT%\program.tap" 2>nul
exit /b 0
