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
		addPlayer();
		addBinds();
	}
	
	private function addPlayer():Void
	{
		_players = new FlxTypedGroup<Player>();
		
		var p:Player = new Player();
		p.x = FlxG.width / 2 - p.width / 2;
		p.y = FlxG.height / 2 - p.height / 2;
		add(p);
		
		_players.add(p);
	}
	
	private function addBinds():Void
	{
		FlxMintInput.bindToFunction("w", _players.members[0], "move", [FlxObject.UP], FlxMintInput.DOWN);
		FlxMintInput.bindToFunction("s", _players.members[0], "move", [FlxObject.DOWN], FlxMintInput.DOWN);
		FlxMintInput.bindToFunction("a", _players.members[0], "move", [FlxObject.LEFT], FlxMintInput.DOWN);
		FlxMintInput.bindToFunction("d", _players.members[0], "move", [FlxObject.RIGHT], FlxMintInput.DOWN);
	}
}