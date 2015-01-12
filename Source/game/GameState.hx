package game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flxMintInput.FlxMintInput;

class GameState extends FlxState
{	
	private var _level:Level;
	
	private var _players:FlxTypedGroup<Player>;
	
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
	}
	
	private function setupPlayer():Void
	{
		_players = new FlxTypedGroup<Player>();
		
		var p:Player = new Player();
		p.x = _level.spawnPoint.x - p.width / 2;
		p.y = _level.spawnPoint.y - p.height / 2;
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
}