@if "%1"=="h" GOTO:help

openfl build B:\project.xml flash -debug -Dfdb

@goto:EOF
:help
@echo Builds the flash file in debug mode