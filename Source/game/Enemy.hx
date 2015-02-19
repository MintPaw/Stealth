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
	private var _framesTillMoveBack:Float = 0;
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
		gun.makeGraphic(20, 5, 0xFF000000);
		gun.origin.x -= gun.width / 2 - gun.height / 2;
		
		buildStateMachineDocs();
		FlxG.watch.add(this, "angleFacing");
	}

	public function seePlayer(p:Player):Void
	{
		switchState(SHOOTING, p);
	}
	
	public function losePlayer():Void
	{
		_canSeePlayer = false;
	}

	private function buildStateMachineDocs():Void
	{
		_stateMachineDocs = new Map();

		_stateMachineDocs.set(
            IDLE,
            [SHOOTING, RESPOND_TO_CALL]);

		_stateMachineDocs.set(
            SHOOTING,
            [CHASING]);

		_stateMachineDocs.set(
            CHASING,
            [SHOOTING, WATCHING]);

		_stateMachineDocs.set(
            WATCHING,
            [SHOOTING, RESPOND_TO_CALL, MOVING_BACK]);

		_stateMachineDocs.set(
            MOVING_BACK,
            [IDLE, SHOOTING, RESPOND_TO_CALL]);
	}
	
	private function canSwitchState(s:Int):Bool
	{
		return _stateMachineDocs.get(_state).indexOf(s) >= 0;
	}

	private function switchState(s:Int, p:Player = null):Void
	{
		if (_stateMachineDocs.get(_state).indexOf(s) == -1) return;

		_state = s;

		if (s == SHOOTING)
		{
			_player = p;
			_canSeePlayer = true;
			_lastSeenPlayer = _player.getMidpoint();
		}

		if (s == CHASING)
		{
			moveToPosition(
                _lastSeenPlayer,
                true,
                true,
                switchState,
                [WATCHING]);

			angleVision *= 5;
		}

		if (s == MOVING_BACK)
		{
			_lastSeenPlayer = null;
			moveToPosition(
                _spawnPoint,
                false,
                false,
                switchState,
                [IDLE]);
		}

		if (s == IDLE)
		{
			angleFacing = _spawnAngle;
			angleVision /= 5;
		}

		if (s == WATCHING)
		{
			_framesTillMoveBack = 120;
		}
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
					
					switchState(CHASING);
				}
			}
			
			_framesTillNextShot -= 1;
			if (_framesTillNextShot <= 0) shoot();	
		}
		
		if (_state == CHASING)
		{
			aimAtPlayerPosition();
		}

		if (_state == WATCHING)
		{
			_framesTillMoveBack--;
			if (_framesTillMoveBack <= 0) switchState(MOVING_BACK);
		}

		if (_state == MOVING_BACK)
		{
			FlxG.log.add("index " + _path.nodeIndex);
			FlxG.log.add("length " + _path.nodes.length);
			if (_path.nodeIndex < _path.nodes.length) 
			{
				angleFacing = FlxAngle.angleBetweenPoint(this,
                                _path.nodes[_path.nodeIndex], true);
			}
		}
		
		spread = Math.min(Math.max(spread - spreadDecreasePerFrame
                    , spreadMinimum), 40);
		
		if (_player != null)
		{
			_player.getMidpoint(_lastSeenPlayer);
		}
		
		super.update(elapsed);

		updateAiming();
	}

	private function updateAiming():Void
	{
		gun.x = x + width / 2 - gun.height / 4;
		gun.y = y + height / 2 - gun.height / 4;

		var difference:Float = (angleFacing - gun.angle);
		if (difference > 180)
            difference -= 360;
        else if (difference < -180)
            difference += 360;

		gun.angle += difference / 6;
	}
	
	private function moveToPosition(
		pos:FlxPoint,
		force:Bool = false,
		removeLastPoint:Bool = false,
		onComplete:Function = null,
		onCompleteParams:Array<Dynamic> = null):Void
	{
		if (!force)
		{
			if (_path != null && !_path.finished) return;
		}

		if (_path != null) _path.cancel();

		_path = new FlxPath();
		var route:Array<FlxPoint> = Reflect.callMethod(this, getRouteCallback,
                                        [getMidpoint(), pos]);
		if (removeLastPoint) route.pop();
		
		if (onComplete != null)
		{
			if (onCompleteParams == null) onCompleteParams = [];
			_path.onComplete = function (p:FlxPath) {
			Reflect.callMethod(this, onComplete, onCompleteParams); };
		}
		
		_path.start(this, route, speed);
	}
	
	private function aimAtPlayerPosition():Void
	{
		angleFacing = FlxAngle.angleBetweenPoint(this, _lastSeenPlayer, true); 
	}
	
	private function shoot():Void
	{
		Sm.playEffect(Sm.ENEMY_SHOOT);
		
		var dir:Float = angleFacing + Reg.rnd.float( -spread, spread);
		Reflect.callMethod(this, shootCallback, [getMidpoint(), dir]);
		spread += spreadIncreasePerShot;
		
		_framesTillNextShot = FlxMath.lerp(9, 45, FlxMath.distanceToPoint(this,
                                                    _lastSeenPlayer) / 500);
		_framesTillNextShot *= Reg.rnd.float(0.8, 1.2);
	}
	
}
