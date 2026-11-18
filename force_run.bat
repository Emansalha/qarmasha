@echo off
REM Qarmasha - double-click to force run the app on your Android phone
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tool\force_run.ps1" %*
pause
