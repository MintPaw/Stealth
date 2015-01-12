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
	public static inline var META_ENEMY:Int = 5;
	
	public var collisionLayer:FlxTilemap;
	public var visualLayer:FlxTilemap;
	
	public var spawnPoint:FlxPoint;
	public var enemies:Array<FlxPoint> = [];
	
	private var _tiledMap:TiledMap;
	
	public function new(mapString:String) 
	{
		_tiledMap = new TiledMap(mapString);
		
		setupMeta();
		setupCollision();
		setupVisual();
	}
	
	private function setupMeta():Void
	{
		var metaLayer:TiledLayer = _tiledMap.getLayer("Meta");
		
		for (i in 0...metaLayer.tileArray.length) 
		{
			if (metaLayer.tileArray[i] == META_SPAWN)
				spawnPoint = new FlxPoint(i % metaLayer.width * _tiledMap.tileHeight, Std.int(i / metaLayer.width) * _tiledMap.tileWidth);
			
			if (metaLayer.tileArray[i] == META_ENEMY)
				enemies.push(new FlxPoint(i % metaLayer.width * _tiledMap.tileHeight, Std.int(i / metaLayer.width) * _tiledMap.tileWidth));
		}
		
	}
	
	private function setupCollision():Void
	{
		var tiledCollisionLayer:TiledLayer = _tiledMap.getLayer("Collision");
		
		collisionLayer = new FlxTilemap();
		collisionLayer.loadMapFromArray(
			tiledCollisionLayer.tileArray,
			tiledCollisionLayer.width,
			tiledCollisionLayer.height,
			"Assets/img/tileset.png",
			_tiledMap.tileWidth,
			_tiledMap.tileHeight,
			null,
			1);
	}
	
	private function setupVisual():Void
	{
		var tiledVisualLayer:TiledLayer = _tiledMap.getLayer("Visual");
		
		visualLayer = new FlxTilemap();
			visualLayer.loadMapFromArray(
			tiledVisualLayer.tileArray,
			tiledVisualLayer.width,
			tiledVisualLayer.height,
			"Assets/img/tileset.png",
			_tiledMap.tileWidth,
			_tiledMap.tileHeight,
			null,
			1);
	}
	
}