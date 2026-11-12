@echo off
setlocal
cd /d "%~dp0"

set "MODEL_NAME=%~1"
set "CLI=%~dp0llama-windows\llama-cli.exe"
set "RULES=%~dp0system_prompt.txt"

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

if not exist "%CLI%" (
    echo ERROR: llama-cli.exe not found in the llama-windows folder.
    pause
    exit /b 1
)

if not exist "%MODEL%" (
    echo ERROR: Model file not found: "%MODEL%"
    echo Download a GGUF model into the models folder and set its filename in model.txt.
    pause
    exit /b 1
)

if not exist "%RULES%" (
    echo ERROR: system_prompt.txt not found.
    pause
    exit /b 1
)

"%CLI%" -m "%MODEL%" --system-prompt-file "%RULES%" -c 8192 -n 2048 --temp 0.2

pause
exit /b

:invalid_model_name
echo ERROR: Use a model filename only, without folders.
pause
exit /b 2
