package game;

import flixel.FlxSprite;

/**
 * ...
 * @author MintPaw
 */
class Enemy extends FlxSprite
{

	public function new()
	{
		super();
		
		makeGraphic(20, 20, 0xFFFF00FF);
	}
	
}