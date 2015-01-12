package game;

import flixel.FlxSprite;

/**
 * ...
 * @author MintPaw
 */
class Enemy extends FlxSprite
{	
	public var angleFacing:Int = 0;
	public var gun:FlxSprite;
	
	public function new()
	{
		super();
		
		makeGraphic(20, 20, 0xFFFF00FF);
		
		gun = new FlxSprite();
		gun.makeGraphic(20, 5, 0xFF000000);
	}
	
	override public function update(elapsed:Float):Void 
	{
		gun.x = x;
		gun.y = y;
		
		super.update(elapsed);
	}
	
}