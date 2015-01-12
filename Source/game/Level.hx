package game;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.math.FlxPoint;

/**
 * ...
 * @author MintPaw
 */
class Level
{
	public static inline var META_SPAWN:Int = 1;
	
	public var spawnPoint:FlxPoint;
	
	private var _tiledMap:TiledMap;
	
	public function new(mapString:String) 
	{
		_tiledMap = new TiledMap(mapString);
		
		setupMeta();
	}
	
	private function setupMeta():Void
	{
		var metaLayer:TiledLayer = _tiledMap.getLayer("Meta");
		
		for (i in 0...metaLayer.tileArray.length) 
			if (metaLayer.tileArray[i] == META_SPAWN)
				spawnPoint = new FlxPoint(i % metaLayer.width * _tiledMap.tileHeight, i / metaLayer.width * _tiledMap.tileWidth);
	}
	
}