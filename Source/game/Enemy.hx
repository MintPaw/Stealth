package game;

import flixel.FlxSprite;

/**
 * ...
 * @author MintPaw
 */
class Enemy extends FlxSprite
{	
	public var playerList:Array<Player>;
	public var gun:FlxSprite;
	
	public var angleFacing:Int = 0;
	
	public function new()
	{
		super();
		
		makeGraphic(20, 20, 0xFFFF00FF);
		
		gun = new FlxSprite();
		gun.makeGraphic(5, 20, 0xFF000000);
		gun.origin.y -= gun.height / 2 - gun.width / 2;
	}
	
	override public function update(elapsed:Float):Void 
	{
		gun.x = x + width / 2 - gun.width / 2;
		gun.y = y + height / 2 - gun.width / 2;
		gun.angle = angleFacing + 180;
		
		super.update(elapsed);
	}
	
}