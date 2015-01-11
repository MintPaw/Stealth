package;


import flixel.FlxGame;
import flxMintInput.FlxMintInput;
import game.GameState;
import openfl.display.Sprite;
import openfl.events.Event;


class Main extends Sprite
{

	public function new()
	{
		addEventListener(Event.ADDED_TO_STAGE, init);
		super();
	}
	
	private function init(e:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		FlxMintInput.init(stage);
		
		var flixel:FlxGame = new FlxGame(1280, 720, GameState, 1, 60, 60, true);
		addChild(flixel);
	}
	
}
