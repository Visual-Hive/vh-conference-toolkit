@echo off
title Open Ops Tracker

set PORT=8080
if exist .env (for /f "tokens=1,* delims==" %%a in (.env) do if "%%a"=="PORT" set PORT=%%b)
set URL=http://localhost:%PORT%

curl -sf %URL% >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Ops Tracker already running.
    start %URL%
    timeout /t 1 /nobreak >nul
    exit /b 0
)

docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Starting Docker Desktop...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    timeout /t 20 /nobreak >nul
)

echo Starting Ops Tracker Docker stack...
docker compose up -d
timeout /t 5 /nobreak >nul
start %URL%
