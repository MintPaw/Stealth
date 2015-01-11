package game;

import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author MintPaw
 */
class Player extends FlxSprite
{
	public function new() 
	{
		super();
		
		maxVelocity.set(400, 400);
		drag.set(4000, 4000);
		makeGraphic(20, 20, 0xFF0000FF);
	}
	
	public function move(dir:Int):Void
	{
		if (dir == FlxObject.LEFT)  acceleration.x = -maxVelocity.x * 10;
		if (dir == FlxObject.RIGHT)  acceleration.x = maxVelocity.x * 10;
		if (dir == FlxObject.UP)  acceleration.y = -maxVelocity.y * 10;
		if (dir == FlxObject.DOWN)  acceleration.y = maxVelocity.y * 10;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		acceleration.set();
	}
	
}