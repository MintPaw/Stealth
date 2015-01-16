package game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flxMintInput.FlxMintInput;

class GameState extends FlxState
{	
	private var _level:Level;
	
	private var _players:FlxTypedGroup<Player>;
	private var _enemies:FlxTypedGroup<Enemy>;
	
	public function new()
	{
		super();
	}

	override public function create():Void
	{
		setupMap();
		setupPlayer();
		setupBinds();
	}
	
	private function setupMap():Void
	{
		_level = new Level("Assets/map/level0.tmx");
		
		add(_level.collisionLayer);
		add(_level.visualLayer);
		
		_enemies = new FlxTypedGroup<Enemy>();
		for (i in _level.enemies)
		{
			i.shootCallback = shoot;
			add(i);
			add(i.gun);
			
			_enemies.add(i);
		}
	}
	
	private function setupPlayer():Void
	{
		_players = new FlxTypedGroup<Player>();
		
		var p:Player = new Player();
		p.x = _level.spawnPoint.x + p.width / 2;
		p.y = _level.spawnPoint.y + p.height / 2;
		add(p);
		
		_players.add(p);
	}
	
	private function setupBinds():Void
	{
		FlxMintInput.bindToFunction("w", _players.members[0], "move", [FlxObject.UP], FlxMintInput.DOWN);
		FlxMintInput.bindToFunction("s", _players.members[0], "move", [FlxObject.DOWN], FlxMintInput.DOWN);
		FlxMintInput.bindToFunction("a", _players.members[0], "move", [FlxObject.LEFT], FlxMintInput.DOWN);
		FlxMintInput.bindToFunction("d", _players.members[0], "move", [FlxObject.RIGHT], FlxMintInput.DOWN);
	}
	
	override public function update(elapsed:Float):Void 
	{
		updateCollisions();
		updateEnemies();
		
		super.update(elapsed);
	}
	
	private function updateCollisions():Void
	{
		FlxG.collide(_players, _level.collisionLayer);
	}
	
	private function updateEnemies():Void
	{
		for (i in _enemies)
		{
			for (j in _players)
			{
				var ang:Float = FlxAngle.angleBetween(i, j, true) + 90;
				
				if (ang > i.angleFacing - i.angleVision && ang < i.angleFacing + i.angleVision && _level.collisionLayer.ray(i.getMidpoint(), j.getMidpoint()))
				{
					i.seePlayer(j);
				}
			}
		}
	}
	
	private function shoot(loc:FlxPoint, dir:Float):Void
	{
		var result:FlxPoint = new FlxPoint();
		var end:FlxPoint = new FlxPoint();
		
		loc.copyTo(end);
		
		end.x += Math.cos(dir * FlxAngle.TO_RAD) * 1500;
		end.y += Math.sin(dir * FlxAngle.TO_RAD) * 1500;
		
		_level.collisionLayer.ray(loc, end, result, 2);
		
		var hit:Bool = false;
		for (i in _players)
		{
			if (Reg.lineIntersectsRect(loc, result, new FlxRect(i.x, i.y, i.width, i.height)))
			{
				i.hurt(1);
				hit = true;
			}
		}
		
		if (!hit)
		{
			var f:FlxSprite = new FlxSprite(result.x, result.y);
			f.makeGraphic(4, 4, 0xFFCCCCCC);
			add(f);
		}
	}
}