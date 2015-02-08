package game;

import flixel.FlxG;
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
	public static var WATCHING:Int = 3;
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

		FlxG.watch.add(this, "_state");
		
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
		_stateMachineDocs.set(CHASING, [SHOOTING, WATCHING]);
		_stateMachineDocs.set(WATCHING, [SHOOTING, RESPOND_TO_CALL, MOVING_BACK]);
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
					
					chasePlayer();
				}
			}
			
			_framesTillNextShot -= 1;
			if (_framesTillNextShot <= 0) shoot();	
		}
		
		if (_state == CHASING)
		{
			aimAtPlayerPosition();
		}

		if (_state == MOVING_BACK)
		{
			
		}
		
		spread = Math.min(Math.max(spread - spreadDecreasePerFrame, spreadMinimum), 40);
		
		if (_player != null)
		{
			_player.getMidpoint(_lastSeenPlayer);
		}
		
		super.update(elapsed);

		updateAiming();
	}

	private function updateAiming():Void
	{
		gun.x = x + width / 2 - gun.width / 4;
		gun.y = y + height / 2 - gun.width / 4;

		var difference:Float = (angleFacing - gun.angle) + 180;
		if (difference > 180) difference -= 360 else if (difference < -180) difference += 360;

		gun.angle += difference / 6;
	}
	
	private function chasePlayer():Void
	{
		moveToPosition(_lastSeenPlayer, true, true, function () { watch(); } );
		switchState(CHASING);
	}
	
	private function moveBack():Void
	{
		if (canSwitchState(MOVING_BACK)) switchState(MOVING_BACK) else return;
		_lastSeenPlayer = null;
		moveToPosition(_spawnPoint, false, false, function () { angleFacing = _spawnAngle; switchState(1); } );
	}
	
	private function watch():Void
	{
		if (canSwitchState(WATCHING) && _path != null && _path.finished) switchState(WATCHING) else return;
		new FlxTimer().start(2, function (t:FlxTimer) { moveBack(); } ); 
	}
	
	private function moveToPosition(pos:FlxPoint, force:Bool = false, removeLastPoint:Bool = false, onComplete:Function = null):Void
	{
		if (!force)
		{
			if (_path != null && !_path.finished) return;
		}

		_path = new FlxPath();
		var route:Array<FlxPoint> = Reflect.callMethod(this, getRouteCallback, [getMidpoint(), pos]);
		if (removeLastPoint) route.pop();
		
		if (onComplete != null)
		{
			_path.onComplete = function (p:FlxPath) { Reflect.callMethod(this, onComplete, []); };
		}
		
		_path.start(this, route, speed);
	}
	
	private function aimAtPlayerPosition():Void
	{
		angleFacing = FlxAngle.angleBetweenPoint(this, _lastSeenPlayer, true) + 90;
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
