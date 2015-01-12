package game;

import flixel.FlxSprite;

/**
 * ...
 * @author MintPaw
 */
class Enemy extends FlxSprite
{	
	public static var IDLE:Int = 1;
	public static var SHOOTING:Int = 2;
	public static var GUESS_SHOOTING:Int = 3;
	public static var CHASING:Int = 4;
	public static var MOVE_BACK:Int = 5;
	
	public var gun:FlxSprite;
	
	public var angleFacing:Int = 0;
	public var angleVision:Int = 15;
	
	private var _idle:Bool = true;
	private var _state:Int = 0;
	private var _stateMachineDocs:Map<Int, Array<Int>>;
	
	public function new()
	{
		super();
		
		makeGraphic(20, 20, 0xFFFF00FF);
		
		gun = new FlxSprite();
		gun.makeGraphic(5, 20, 0xFF000000);
		gun.origin.y -= gun.height / 2 - gun.width / 2;
		
		buildStateMachineDocs();
	}
	
	
	private function buildStateMachineDocs():Void
	{
		_stateMachineDocs = new Map();
	}
	
	public function seePlayer(p:Player):Void
	{
		
	}
	
	override public function update(elapsed:Float):Void 
	{
		gun.x = x + width / 2 - gun.width / 2;
		gun.y = y + height / 2 - gun.width / 2;
		gun.angle = angleFacing + 180;
		
		super.update(elapsed);
	}
	
}