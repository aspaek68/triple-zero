@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0.."
set "COUNTER=knowledge\.topic_counter"
if not exist "knowledge" mkdir "knowledge"
set /a IDX=0
if exist "%COUNTER%" set /p IDX=<"%COUNTER%"
set /a LINES=0
for /f %%a in ('type "tools\daily_topics.txt" ^| find /c /v ""') do set /a LINES=%%a
if %LINES%==0 goto :end
set /a PICK=%IDX% %% %LINES%
set /a N=0
set "TOPIC="
for /f "usebackq delims=" %%t in ("tools\daily_topics.txt") do (
    if !N! equ %PICK% set "TOPIC=%%t"
    set /a N+=1
)
if "%TOPIC%"=="" goto :end
echo Learning topic: %TOPIC%
python -u tools\autonomous.py "%TOPIC%" --iterations 1 --per-iter 2 > "C:\Users\guillaume\AppData\Local\Temp\opencode\auto_out.txt" 2> "C:\Users\guillaume\AppData\Local\Temp\opencode\auto_err.txt"
set /a IDX+=1
echo !IDX!> "%COUNTER%"
:end
echo Done.
