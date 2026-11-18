@echo off
REM Qarmasha - force run the app on the Android EMULATOR
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\force_run.ps1" -Emulator
pause
