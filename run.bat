@echo off
setlocal

set ROOT=%~dp0
set FUSE=%ROOT%tools\fuse\fuse.exe
set TAP=%ROOT%bin\program.tap

if not exist "%TAP%" (
    echo Missing %TAP%
    echo Run build.bat first.
    exit /b 1
)

if not exist "%FUSE%" (
    echo Missing Fuse emulator: %FUSE%
    exit /b 1
)

echo Starting Fuse (48K) with %TAP%
start "" "%FUSE%" --machine 48 --tape "%TAP%" --auto-load
