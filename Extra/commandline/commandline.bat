@if "%1"=="h" GOTO:help

color A
cd %~dp0..\..\
subst b: /d
subst b: .
cd /d b:\
set path=%path%;b:\extra\commandline
cmd /k "cls"

@goto:EOF
:help
@echo Leave this alone