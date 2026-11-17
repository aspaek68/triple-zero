@echo off
setlocal
title TRIPLE ZERO - Acte 2 : Aeroport

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

rem Premiere execution ou nouvel asset : met a jour le cache d'import
rem (enregistre les class_name et prepare les textures/sons). Sans effet
rem si tout est deja a jour.
echo Preparation des ressources...
"%GODOT%" --headless --path "%~dp0" --import >nul 2>&1

echo Lancement de TRIPLE ZERO - mode 2...
start "" "%GODOT%" --path "%~dp0" --rendering-method gl_compatibility -- --mode=2
exit /b 0
