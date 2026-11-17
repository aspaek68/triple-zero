@echo off
setlocal
title TRIPLE ZERO - Mission 3 : L'Astrolabe

rem Cherche Godot dans les emplacements connus. Surcharge possible :
rem   set TRIPLE_ZERO_GODOT=C:\chemin\Godot_v4.7.2-stable_win64.exe
set "GODOT="
if defined TRIPLE_ZERO_GODOT if exist "%TRIPLE_ZERO_GODOT%" set "GODOT=%TRIPLE_ZERO_GODOT%"
if not defined GODOT if exist "%~dp0..\..\..\programme\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" set "GODOT=%~dp0..\..\..\programme\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"
if not defined GODOT if exist "C:\Users\guillaume\Desktop\programme\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" set "GODOT=C:\Users\guillaume\Desktop\programme\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"
if not defined GODOT if exist "C:\Users\guillaume\Desktop\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" set "GODOT=C:\Users\guillaume\Desktop\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe"

if not defined GODOT (
    echo.
    echo   Godot 4.7.2 est introuvable.
    echo.
    echo   Ouvre le projet manuellement :
    echo   Godot ^> Importer ^> choisir project.godot dans ce dossier.
    echo.
    pause
    exit /b 1
)

echo Lancement de TRIPLE ZERO - mission 3...
start "" "%GODOT%" --path "%~dp0" --rendering-method gl_compatibility -- --mission=3
exit /b 0
