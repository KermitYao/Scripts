@echo off
if "%1" == "" (
	call python main.py
) else (
	call python "%~1"
)
pause