@if "%1"=="h" GOTO:help

haxelib install openfl
haxelib run openfl setup
haxelib git flixel https://github.com/HaxeFlixel/flixel.git dev
haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons.git dev
haxelib git FlxMintInput https://github.com/MintPaw/FlxMintInput.git master
haxelib upgrade

@goto:EOF
:help
@echo Sets up your environment to build and run the game