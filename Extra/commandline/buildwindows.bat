@if "%1"=="h" GOTO:help

openfl build B:\project.xml windows

@goto:EOF
:help
@echo Builds the windows file