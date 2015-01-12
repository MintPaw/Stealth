package ;

import flixel.FlxG;
import flixel.FlxState;
import game.GameState;

/**
 * ...
 * @author MintPaw
 */
class MainState extends FlxState
{

	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		
		FlxG.cameras.bgColor = 0xFFFFFFFF;
		
		FlxG.switchState(new GameState());
	}
	
}