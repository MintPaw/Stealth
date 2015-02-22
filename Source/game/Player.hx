package game;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

/**
 * ...
 * @author MintPaw
 */
class Player extends FlxSprite
{
    public var moving:Bool = false;

	public function new() 
	{
		super();
		
		health = 2;
		
		maxVelocity.set(400, 400);
		drag.set(4000, 4000);
		makeGraphic(20, 20, 0xFF0000FF);
	}
	
	public function move(dir:Int):Void
	{
		if (dir == FlxObject.LEFT) acceleration.x = -maxVelocity.x * 10;
		if (dir == FlxObject.RIGHT) acceleration.x = maxVelocity.x * 10;
		if (dir == FlxObject.UP) acceleration.y = -maxVelocity.y * 10;
		if (dir == FlxObject.DOWN) acceleration.y = maxVelocity.y * 10;

        moving = acceleration.x != 0 || acceleration.y != 0;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		acceleration.set();
	}

	override public function getMidpoint(p:FlxPoint = null):FlxPoint
	{
		if (p == null) p = new FlxPoint();
		p.x = x + width / 2;
		p.y = y + height / 2;
		return p;
	}
}
