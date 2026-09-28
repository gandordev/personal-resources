@echo off
setlocal

set "ENV_FILE=env.txt"

if not exist "%ENV_FILE%" (
    echo Environment variables file '%ENV_FILE%' not found.
    exit /b
)

for /f "tokens=1,2 delims==" %%A in (%ENV_FILE%) do (
    if not "%%A"=="" (
        setx "%%A" "%%B"
        echo Set %%A=%%B
    )
)

echo Environment variables set. Restart your session to apply changes.
exit /b
