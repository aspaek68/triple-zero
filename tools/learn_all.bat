@echo off
setlocal
cd /d "%~dp0.."
set "PYTHON=python"
if not exist "knowledge" mkdir "knowledge"
for /f "usebackq delims=" %%u in ("tools\learn_urls.txt") do (
    if not "%%u"=="" (
        echo Learning: %%u
        %PYTHON% tools\learn.py "%%u" 2>&1
    )
)
echo Done.
