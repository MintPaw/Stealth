@if "%1"=="h" GOTO:help

openfl build B:\project.xml flash


@goto:EOF
:help
@echo Builds the flash file