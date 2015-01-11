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
		
		maxVelocity.set(200, 200);
		drag.set(800, 800);
		makeGraphic(20, 20, 0xFF0000FF);
	}
	
	public function move(dir:Int):Void
	{
		if (dir == FlxObject.LEFT)  acceleration.x = -maxVelocity.x * 4;
		if (dir == FlxObject.RIGHT)  acceleration.x = maxVelocity.x * 4;
		if (dir == FlxObject.UP)  acceleration.y = -maxVelocity.y * 4;
		if (dir == FlxObject.DOWN)  acceleration.y = maxVelocity.y * 4;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		acceleration.set();
	}
	
}