package game;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;

class GameState extends FlxState
{
	private var _players:FlxTypedGroup<Player>;
	
	public function new()
	{
		super();
	}

	override public function create():Void
	{
		addPlayer();
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
}