package game;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import haxe.Constraints.Function;

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
	public var shootCallback:Function;
	
	public var angleFacing:Float = 0;
	public var angleVision:Float = 15;
	
	public var spread:Float = 0;
	public var spreadMinimum:Float = 5;
	public var spreadIncreasePerShot:Float = 5;
	public var spreadDecreasePerFrame:Float = .2;
	
	private var _state:Int = IDLE;
	private var _stateMachineDocs:Map<Int, Array<Int>>;

	private var _player:Player;
	private var _lastSeenPlayer:FlxPoint;

	private var _tweens:Array<FlxTween> = [];
	
	private var _framesTillNextShot:Float = 0;
	
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
	}
	
	override public function update(elapsed:Float):Void 
	{
		gun.x = x + width / 2 - gun.width / 4;
		gun.y = y + height / 2 - gun.width / 4;
		gun.angle = angleFacing + 180;
		
		if (_state == SHOOTING)
		{
			var playerAngle:Float = FlxAngle.angleBetween(this, _player, true);
			var difference:Float = (playerAngle - angleFacing) + 90;
			
			if (difference > 180) difference -= 360 else if (difference < -180) difference += 360;
			
			angleFacing += difference / 6;
			
			_framesTillNextShot -= 1;
			if (_framesTillNextShot <= 0) shoot();
		}
		
		spread = Math.min(Math.max(spread - spreadDecreasePerFrame, spreadMinimum), 40);
		
		super.update(elapsed);
	}
	
	private function shoot():Void
	{
		var dir:Float = angleFacing + Reg.rnd.float( -spread, spread);
		Reflect.callMethod(this, shootCallback, [getMidpoint(), dir - 90]);
		spread += spreadIncreasePerShot;
		
		//((limitMax - limitMin) * (valueIn - baseMin) / (baseMax - baseMin)) + limitMin;
		_framesTillNextShot = ((45 - 6) * (FlxMath.distanceBetween(this, _player) - 50) / (500 - 50)) + 6;
		_framesTillNextShot *= Reg.rnd.float(0.8, 1.2);
	}
	
}