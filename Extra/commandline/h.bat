@if "%1"=="h" GOTO:help

@echo off
cls
echo These are the avaliable commands (setup first)
for /F "delims=" %%j in ('dir b:\Extra\commandline /B /O:GEN') do echo %%~nj
@echo on

@goto:EOF
:help
@echo Shows you how to receive help