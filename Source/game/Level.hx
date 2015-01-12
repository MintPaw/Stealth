package game;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;

/**
 * ...
 * @author MintPaw
 */
class Level
{
	public static inline var META_SPAWN:Int = 1;
	
	public var collisionLayer:FlxTilemap;
	public var visualLayer:FlxTilemap;
	
	public var spawnPoint:FlxPoint;
	
	private var _tiledMap:TiledMap;
	
	public function new(mapString:String) 
	{
		_tiledMap = new TiledMap(mapString);
		
		setupMeta();
		setupCollision();
	}
	
	private function setupMeta():Void
	{
		var metaLayer:TiledLayer = _tiledMap.getLayer("Meta");
		
		for (i in 0...metaLayer.tileArray.length) 
			if (metaLayer.tileArray[i] == META_SPAWN)
				spawnPoint = new FlxPoint(i % metaLayer.width * _tiledMap.tileHeight, i / metaLayer.width * _tiledMap.tileWidth);
	}
	
	private function setupCollision():Void
	{
		var tiledCollisionLayer:TiledLayer = _tiledMap.getLayer("Collision");
		
		collisionLayer = new FlxTilemap();
		collisionLayer.loadMapFromArray(tiledCollisionLayer.tileArray, tiledCollisionLayer.width, tiledCollisionLayer.height, "Assets/img/tileset.png", _tiledMap.tileWidth, _tiledMap.tileHeight, null, 1);
	}
	
}