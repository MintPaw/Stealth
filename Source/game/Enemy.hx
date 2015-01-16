package game;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

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
	public static var RESPOND_TO_CALL:Int = 6;
	
	public var gun:FlxSprite;
	
	public var angleFacing:Int = 0;
	public var angleVision:Int = 15;
	
	private var _state:Int = IDLE;
	private var _stateMachineDocs:Map<Int, Array<Int>>;

	private var _player:Player;
	private var _lastSeenPlayer:FlxPoint;

	private var _tweens:Array<FlxTween> = [];
	
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
		if (canSwitchState(SHOOTING))
		{
			_player = p;
			switchState(SHOOTING);
		}
	}

	private function buildStateMachineDocs():Void
	{
		_stateMachineDocs = new Map();
		_stateMachineDocs.set(IDLE, [SHOOTING, RESPOND_TO_CALL]);
		_stateMachineDocs.set(SHOOTING, [GUESS_SHOOTING, CHASING]);
		_stateMachineDocs.set(GUESS_SHOOTING, [MOVING_BACK, RESPOND_TO_CALL]);
		_stateMachineDocs.set(CHASING, [SHOOTING, MOVING_BACK]);
		_stateMachineDocs.set(MOVING_BACK, [IDLE, SHOOTING, RESPOND_TO_CALL]);
	}
	
	private function canSwitchState(s:Int):Bool
	{
		return _stateMachineDocs.get(_state).indexOf(s) >= 0;
	}

	private function switchState(s:Int):Void
	{
		_state = s;

		if (s == SHOOTING)
		{
			_tweens.push(FlxTween.tween(this, { angleFacing: FlxAngle.angleBetween(this, _player, true) }, .5, { onComplete: startShooting }));
		}
	}

	private function startShooting(t:FlxTween):Void
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