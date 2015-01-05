package game;

import flixel.FlxState;

class GameState extends FlxState
{

	public function new()
	{
		super();
	}

	override public function create():Void
	{
		trace("Started");
	}
}