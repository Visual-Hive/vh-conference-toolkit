@echo off
title Open Countdown Planner

curl -sf http://localhost:8080/api/local/countdown_state >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Data is in Ops Tracker storage. Opening index.html...
    start index.html
    timeout /t 1 /nobreak >nul
    exit /b 0
)

set PORT=8081
if exist .env (for /f "tokens=1,* delims==" %%a in (.env) do if "%%a"=="PORT" set PORT=%%b)
set URL=http://localhost:%PORT%

curl -sf %URL% >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Countdown Planner already running.
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

echo Starting Countdown Planner Docker stack...
docker compose up -d
timeout /t 5 /nobreak >nul
start %URL%
