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
    public static var IDLE:String = "idle";
    public static var SHOOTING:String = "shooting";
    public static var HEARING:String = "hearing";
    public static var WATCHING:String = "watching";
    public static var CHASING:String = "chasing";
    public static var MOVING_BACK:String = "moving back";
    public static var RESPOND_TO_CALL:String = "responding";

    // Callbacks
    public var shootCallback:Function;
    public var getRouteCallback:Function;

    // Gun vars
    public var gun:FlxSprite;

    // Misc public
    public var speed:Float = 150;
    public var hearingRange:Float = 300;

    // Vision vars
    public var angleFacing:Float = 0;
    public var angleVision:Float = 15;
    public var timeTillLoseVisionMax:Float = .5;
    public var timeTillLoseVision:Float;
    public var canSeePlayer:Bool = false;

    // Spread vars
    public var spreadMinimum:Float = 2;
    public var spread:Float = 0;
    public var spreadIncreasePerShot:Float = 4;
    public var spreadDecreasePerFrame:Float = .3;

    // FSM vars
    private var _state:String = IDLE;
    private var _stateMachineDocs:Map<String, Array<String>>;

    // Player vars
    private var _player:Player;
    private var _lastSeenPlayer:FlxPoint;

    // Misc
    private var _framesTillDoneHearing:Float = 0;
    private var _framesTillNextShot:Float = 0;
    private var _framesTillMoveBack:Float = 0;
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
        gun.makeGraphic(20, 5, 0xFF000000);
        gun.origin.x -= gun.width / 2 - gun.height / 2;

        buildStateMachineDocs();
    }

    public function seePlayer(p:Player):Void
    {
        switchState(SHOOTING, p);
    }

    public function hearPlayer(p:Player):Void
    {
        switchState(HEARING, p);
    }

    public function losePlayer():Void
    {
        canSeePlayer = false;
    }

    public function playerDead():Void
    {
        if (_state == SHOOTING)
        {
            switchState(CHASING);
        }
    }

    private function buildStateMachineDocs():Void
    {
        _stateMachineDocs = new Map();

        _stateMachineDocs.set(
                IDLE,
                [SHOOTING, HEARING, RESPOND_TO_CALL]);

        _stateMachineDocs.set(
                HEARING,
                [HEARING, CHASING, SHOOTING]);

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
                [IDLE, SHOOTING, HEARING, RESPOND_TO_CALL]);
    }

    private function switchState(s:String, p:Player = null):Void
    {
        if (_stateMachineDocs.get(_state).indexOf(s) == -1) return;

        var oldState:String = _state;
        _state = s;

        if (s == SHOOTING)
        {
            _player = p;
            canSeePlayer = true;
            _framesTillNextShot = 10;
            _lastSeenPlayer = _player.getMidpoint();

            if (_path != null && !_path.finished)
            {
                _path.cancel();
                _framesTillNextShot += 20;
            }
        }

        if (s == HEARING)
        {
            if (_lastSeenPlayer == null || Reg.rnd.int(0, 30) == 0)
                _lastSeenPlayer = p.getMidpoint();

            if (oldState != HEARING) _framesTillDoneHearing = 100;
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
            if (canSeePlayer)
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

        if (_state == HEARING)
        {
            _framesTillDoneHearing--;
            aimAtPlayerPosition();
            if (_framesTillDoneHearing <= 0)
            {
                switchState(CHASING);
            }
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
            if (_path.nodeIndex < _path.nodes.length) 
            {
                angleFacing = FlxAngle.angleBetweenPoint(this,
                        _path.nodes[_path.nodeIndex], true);
            }
        }

        spread = Math.min(Math.max(spread - spreadDecreasePerFrame
                    , spreadMinimum), 40);

        if (_player != null)
            _player.getMidpoint(_lastSeenPlayer);

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
            if (_path != null && !_path.finished) return;

        if (_path != null) _path.cancel();

        _path = new FlxPath();
        var route:Array<FlxPoint> =
            Reflect.callMethod(this, getRouteCallback, [getMidpoint(), pos]);

        if (route == null) return;

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

        _framesTillNextShot = FlxMath.lerp(9, 30, FlxMath.distanceToPoint(this,
                    _lastSeenPlayer) / 500);
        _framesTillNextShot *= Reg.rnd.float(0.8, 1.2);
    }

}
