@echo off
cd /d "%~dp0"
where python >nul 2>nul
if %errorlevel%==0 (
    python deepseek_proxy.py
) else (
    py -3 deepseek_proxy.py
)
pause
