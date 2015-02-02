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
	// FSM consts
	public static var IDLE:Int = 1;
	public static var SHOOTING:Int = 2;
	public static var CHASING:Int = 4;
	public static var MOVING_BACK:Int = 5;
	public static var RESPOND_TO_CALL:Int = 6;
	
	// Gun vars
	public var gun:FlxSprite;
	public var shootCallback:Function;
	
	// Vision vars
	public var angleFacing:Float = 0;
	public var angleVision:Float = 15;
	public var timeTillLoseVisionMax:Float = 1.5;
	public var timeTillLoseVision:Float = 1.5;
	
	// Spread vars
	public var spreadMinimum:Float = 5;
	public var spread:Float = 0;
	public var spreadIncreasePerShot:Float = 5;
	public var spreadDecreasePerFrame:Float = .2;
	
	// FSM vars
	private var _state:Int = IDLE;
	private var _stateMachineDocs:Map<Int, Array<Int>>;
	
	// Player vars
	private var _player:Player;
	private var _lastSeenPlayer:FlxPoint = new FlxPoint();
	
	// Note: may remove
	private var _tweens:Array<FlxTween> = [];
	
	// Misc
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
	
	public function losePlayer():Void
	{
		_player = null;
	}

	private function buildStateMachineDocs():Void
	{
		_stateMachineDocs = new Map();
		_stateMachineDocs.set(IDLE, [SHOOTING, RESPOND_TO_CALL]);
		_stateMachineDocs.set(SHOOTING, [CHASING]);
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
			// Update time till the enemy loses vision on the player and chases
			if (_player == null)
			{
				timeTillLoseVision -= elapsed;
				if (timeTillLoseVision <= 0) switchState(CHASING);
			} else {
				_player.getMidpoint(_lastSeenPlayer);
				timeTillLoseVision = timeTillLoseVisionMax;
			}
			
			// Aim and shoot at the player's last known position
			var playerAngle:Float = FlxAngle.angleBetweenPoint(this, _lastSeenPlayer, true);
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
		Sm.playEffect(Sm.ENEMY_SHOOT);
		
		var dir:Float = angleFacing + Reg.rnd.float( -spread, spread);
		Reflect.callMethod(this, shootCallback, [getMidpoint(), dir - 90]);
		spread += spreadIncreasePerShot;
		
		_framesTillNextShot = FlxMath.lerp(3, 45, FlxMath.distanceToPoint(this, _lastSeenPlayer) / 500);
		_framesTillNextShot *= Reg.rnd.float(0.8, 1.2);
	}
	
}