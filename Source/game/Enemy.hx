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
	public static var MOVING_BACK:Int = 5;
	
	public var gun:FlxSprite;
	
	public var angleFacing:Int = 0;
	public var angleVision:Int = 15;
	
	private var _idle:Bool = true;
	private var _state:Int = 0;
	private var _stateMachineDocs:Map<Int, Array<Int>>;

	private var _player:Player;
	private var _lastSeenPlayer:FlxPoint;
	
	public function new()
	{
		super();
		
		makeGraphic(20, 20, 0xFFFF00FF);
		
		gun = new FlxSprite();
		gun.makeGraphic(5, 20, 0xFF000000);
		gun.origin.y -= gun.height / 2 - gun.width / 2;
		
		buildStateMachineDocs();
	}

	public function seePlayer(p:Player):Void
	{
		
	}

	private function buildStateMachineDocs():Void
	{
		_stateMachineDocs = new Map();
		_stateMachineDocs.set(IDLE, [SHOOTING, CHASING]);
		_stateMachineDocs.set(SHOOTING, [GUESS_SHOOTING, CHASING]);
		_stateMachineDocs.set(GUESS_SHOOTING, [MOVING_BACK]);
		_stateMachineDocs.set(CHASING, [SHOOTING, MOVING_BACK]);
	}
	

	private function switchState(s:Int):Bool
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