@if "%1"=="h" GOTO:help

openfl build B:\project.xml windows -debug -Dfdb


@goto:EOF
:help
@echo Builds the windows file in debug mode