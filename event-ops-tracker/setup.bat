@echo off
setlocal enabledelayedexpansion
title VH Conference Toolkit - Ops Tracker Setup

echo.
echo ==========================================
echo   VH Conference Toolkit - Ops Tracker
echo   Setup and Launcher
echo ==========================================
echo.

REM Step 1: Docker installed?
echo [1/5] Checking Docker is installed...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not installed.
    echo.
    echo Install Docker Desktop (free) from:
    echo https://www.docker.com/products/docker-desktop/
    echo.
    pause & exit /b 1
)
echo [OK] Docker found.

REM Step 2: Docker running?
echo [2/5] Checking Docker is running...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running.
    echo Please start Docker Desktop (whale icon in system tray) and try again.
    pause & exit /b 1
)
echo [OK] Docker is running.

REM Step 3: Port free?
echo [3/5] Checking port 8080...
netstat -ano | findstr ":8080" | findstr "LISTENING" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [ERROR] Port 8080 is already in use.
    echo Stop the other service or add PORT=9090 to a .env file in this folder.
    pause & exit /b 1
)
echo [OK] Port 8080 is free.

REM Step 4: Data directory
echo [4/5] Setting up data storage...
if not exist "data" mkdir data
if not exist "data\db.json" (
    echo {"ops_state":[{"id":1}]} > data\db.json
    echo [OK] Created fresh data file: .\data\db.json
) else (
    echo [OK] Existing data found: .\data\db.json (your data is safe)
)

REM Step 5: Start Docker
echo [5/5] Starting Docker services...
docker compose up -d --build
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker Compose failed. See errors above.
    pause & exit /b 1
)
echo [OK] Services started.

timeout /t 3 /nobreak >nul
start http://localhost:8080

echo.
echo ==========================================
echo   Ops Tracker is running!
echo   Open: http://localhost:8080
echo.
echo   Your data is saved in: .\data\db.json
echo   This file survives Docker restarts.
echo   Back it up by copying it somewhere safe.
echo.
echo   To stop:    docker compose stop
echo   To restart: docker compose up -d
echo ==========================================
echo.
pause
