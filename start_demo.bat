@echo off
chcp 65001 >nul
title Naamati Demo Server
echo ============================================
echo   Naamati - Demo Server
echo ============================================
echo.

REM Find the project folder (this script's folder)
cd /d "%~dp0"

REM 1. Check MySQL is up on 3306
echo [1/3] Checking MySQL...
netstat -ano | findstr ":3306" | findstr "LISTENING" >nul
if errorlevel 1 (
    echo      MySQL NOT running! Open Laragon and press "Start All" first.
    pause
    exit /b 1
)
echo      MySQL is up.

REM 2. Show the LAN IPs so phones can connect
echo [2/3] Your laptop IP addresses for phones:
echo      (use the one matching the demo Wi-Fi network in the app's .env)
ipconfig | findstr /C:"IPv4"
echo.

REM 3. Start Laravel on all interfaces
echo [3/3] Starting Laravel on 0.0.0.0:8000  (keep this window open!)
echo      Dashboard : http://localhost:8000/admin
echo      Phones    : http://^<laptop-ip^>:8000
echo.
cd backend
"C:\laragon\bin\php\php-8.3.33-Win32-vs16-x64\php.exe" artisan serve --host=0.0.0.0 --port=8000
pause
