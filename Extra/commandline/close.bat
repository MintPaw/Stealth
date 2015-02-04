@if "%1"=="h" GOTO:help

color 7
cd /d %userprofile%
subst /d b: & cls

@goto:EOF
:help
@echo Resets your shell to the windows default