package;


import flixel.FlxGame;
import game.GameState;
import openfl.display.Sprite;


class Main extends Sprite
{

	public function new()
	{
		var flixel:FlxGame = new FlxGame(1280, 720, GameState, 1, 60, 60, true);
		addChild(flixel);

		super();
	}
}