package game;

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
		
		makeGraphic(20, 20, 0xFF0000FF);
	}
	
}