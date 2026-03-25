@echo off
setlocal enabledelayedexpansion
title VH Conference Toolkit - Countdown Planner Setup

echo.
echo ================================================
echo   VH Conference Toolkit - Countdown Planner
echo   Setup and Launcher
echo ================================================
echo.

REM Check if Ops Tracker already running (shared storage)
curl -sf http://localhost:8080/api/local/countdown_state >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Ops Tracker detected on port 8080!
    echo      Countdown Planner will share its storage.
    echo      No extra Docker setup needed.
    echo.
    echo      Just open index.html in your browser.
    echo.
    start index.html
    pause & exit /b 0
)

echo [1/5] Checking Docker...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker not installed.
    echo https://www.docker.com/products/docker-desktop/
    pause & exit /b 1
)
echo [OK] Docker found.

echo [2/5] Checking Docker is running...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker not running. Start Docker Desktop and try again.
    pause & exit /b 1
)
echo [OK] Docker is running.

echo [3/5] Checking port 8081...
netstat -ano | findstr ":8081" | findstr "LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [ERROR] Port 8081 is in use. Add PORT=XXXX to .env to change it.
    pause & exit /b 1
)
echo [OK] Port 8081 is free.

echo [4/5] Setting up data storage...
if not exist "data" mkdir data
if not exist "data\db.json" (
    echo {"countdown_state":[{"id":1}]} > data\db.json
    echo [OK] Created: .\data\db.json
) else (
    echo [OK] Existing data found.
)

echo [5/5] Starting Docker...
docker compose up -d --build
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker Compose failed. See errors above.
    pause & exit /b 1
)
echo [OK] Services started.

timeout /t 3 /nobreak >nul
start http://localhost:8081

echo.
echo ================================================
echo   Countdown Planner is running!
echo   Open: http://localhost:8081
echo   Data: .\data\db.json
echo ================================================
pause
