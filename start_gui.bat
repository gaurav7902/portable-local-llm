
@echo off
setlocal
cd /d "%~dp0"

set "SERVER=%~dp0llama-windows\llama-server.exe"
set "MODEL_NAME=%~1"

if not "%~2"=="" (
    echo Usage: %~nx0 [model-filename]
    pause
    exit /b 2
)

if not defined MODEL_NAME (
    if not exist "%~dp0model.txt" (
        echo ERROR: model.txt not found. Set the model filename there.
        pause
        exit /b 1
    )
    for /f "usebackq delims=" %%M in ("%~dp0model.txt") do if not defined MODEL_NAME set "MODEL_NAME=%%M"
)

if "%MODEL_NAME%"=="." goto invalid_model_name
if "%MODEL_NAME%"==".." goto invalid_model_name
for %%I in ("%MODEL_NAME%") do if not "%%~nxI"=="%MODEL_NAME%" goto invalid_model_name

if not defined MODEL_NAME (
    echo ERROR: Model name is empty in model.txt.
    pause
    exit /b 1
)

set "MODEL=%~dp0models\%MODEL_NAME%"

if not exist "%SERVER%" (
    echo ERROR: llama-server.exe not found in the llama-windows folder.
    pause
    exit /b 1
)

if not exist "%MODEL%" (
    echo ERROR: Model file not found: "%MODEL%"
    echo Download a GGUF model into the models folder and set its filename in model.txt.
    pause
    exit /b 1
)

"%SERVER%" -m "%MODEL%" -c 4096 --host 127.0.0.1 --port 8080

pause
exit /b

:invalid_model_name
echo ERROR: Use a model filename only, without folders.
pause
exit /b 2
