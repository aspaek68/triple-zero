@echo off
cd /d "%~dp0.."
python -u tools\autonomous.py "Godot particles" --iterations 1 --per-iter 2 --max-sources 3 > "C:\Users\guillaume\AppData\Local\Temp\opencode\auto_out.txt" 2> "C:\Users\guillaume\AppData\Local\Temp\opencode\auto_err.txt"
