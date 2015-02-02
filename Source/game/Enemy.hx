package game;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxPath;
import flixel.util.FlxTimer;
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
	
	// Callbacks
	public var shootCallback:Function;
	public var getRouteCallback:Function;
	
	// Gun vars
	public var gun:FlxSprite;
	
	// Misc public
	public var speed:Float = 100;
	
	// Vision vars
	public var angleFacing:Float = 0;
	public var angleVision:Float = 15;
	public var timeTillLoseVisionMax:Float = .5;
	public var timeTillLoseVision:Float;
	
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
	private var _canSeePlayer:Bool = false;
	
	// Misc
	private var _framesTillNextShot:Float = 0;
	private var _spawnPoint:FlxPoint;
	private var _spawnAngle:Float;
	private var _path:FlxPath;
	
	public function new(xpos:Float, ypos:Float, startAngle:Float)
	{
		super();
		
		makeGraphic(20, 20, 0xFFFF00FF);
		
		x = xpos + width / 2;
		y = ypos + height / 2;
		angleFacing = startAngle;
		_spawnAngle = startAngle;
		_spawnPoint = getMidpoint();
		
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
			_canSeePlayer = true;
			_lastSeenPlayer = _player.getMidpoint();
			switchState(SHOOTING);
		}
	}
	
	public function losePlayer():Void
	{
		_canSeePlayer = false;
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
			if (_canSeePlayer)
			{
				timeTillLoseVision = timeTillLoseVisionMax;
				aimAtPlayerPosition();
			} else {
				timeTillLoseVision -= elapsed;
				if (timeTillLoseVision <= 0)
				{
					_player = null;
					switchState(CHASING);
				}
			}
			
			_framesTillNextShot -= 1;
			if (_framesTillNextShot <= 0) shoot();	
		}
		
		if (_state == CHASING)
		{
			if (_lastSeenPlayer != null)
			{
				moveToPosition(_lastSeenPlayer, true, false, function () { _lastSeenPlayer = null; switchState(MOVING_BACK); } , null, 2);
				
				aimAtPlayerPosition();
			}
		}
		
		/*
		if (_state == MOVING_BACK)
		{
			if (_path == null)
			{
				moveToPosition(_spawnPoint);
			}
		}*/
		
		spread = Math.min(Math.max(spread - spreadDecreasePerFrame, spreadMinimum), 40);
		
		if (_player != null)
		{
			_player.getMidpoint(_lastSeenPlayer);
		}
		
		super.update(elapsed);
	}
	
	private function moveToPosition(pos:FlxPoint, removeLastPoint:Bool = false, force:Bool = false, onComplete:Function = null, onCompleteParams:Array<Dynamic> = null, onCompleteDelay:Float = 0):Void
	{
		if (_path != null && !force) return;
		
		_path = new FlxPath();
		var route:Array<FlxPoint> = Reflect.callMethod(this, getRouteCallback, [getMidpoint(), pos]);
		if (removeLastPoint) route.pop();
		_path.start(this, route, speed);
		
		if (onComplete == null) return;
		if (onCompleteParams == null) onCompleteParams = [];
		var timer:FlxTimer = new FlxTimer().start(onCompleteDelay, function (t:FlxTimer) { Reflect.callMethod(this, onComplete, onCompleteParams); } ) ;
		_path.onComplete = function (p:FlxPath) { timer.start(onCompleteDelay); };
	}
	
	private function aimAtPlayerPosition():Void
	{
		var playerAngle:Float = FlxAngle.angleBetweenPoint(this, _lastSeenPlayer, true);
		var difference:Float = (playerAngle - angleFacing) + 90;
		if (difference > 180) difference -= 360 else if (difference < -180) difference += 360;
		angleFacing += difference / 6;
	}
	
	private function shoot():Void
	{
		Sm.playEffect(Sm.ENEMY_SHOOT);
		
		var dir:Float = angleFacing + Reg.rnd.float( -spread, spread);
		Reflect.callMethod(this, shootCallback, [getMidpoint(), dir - 90]);
		spread += spreadIncreasePerShot;
		
		_framesTillNextShot = FlxMath.lerp(9, 45, FlxMath.distanceToPoint(this, _lastSeenPlayer) / 500);
		_framesTillNextShot *= Reg.rnd.float(0.8, 1.2);
	}
	
}