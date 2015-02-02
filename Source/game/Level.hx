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
	public static inline var META_ENEMY_START:Int = 5;
	public static inline var META_ENEMY_END:Int = 12;
	
	public var collisionLayer:FlxTilemap;
	public var visualLayer:FlxTilemap;
	
	public var spawnPoint:FlxPoint;
	public var enemies:Array<Enemy> = [];
	
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
			
			if (metaLayer.tileArray[i] >= META_ENEMY_START && metaLayer.tileArray[i] <= META_ENEMY_END)
			{
				var angle:Float = 0;
				
				if (metaLayer.tileArray[i] == 5) angle = 0;
				if (metaLayer.tileArray[i] == 6) angle = 180;
				if (metaLayer.tileArray[i] == 7) angle = 270;
				if (metaLayer.tileArray[i] == 8) angle = 90;
				if (metaLayer.tileArray[i] == 9) angle = 45;
				if (metaLayer.tileArray[i] == 10) angle = 135;
				if (metaLayer.tileArray[i] == 11) angle = 225;
				if (metaLayer.tileArray[i] == 12) angle = 315;
				
				var e:Enemy = new Enemy(
					i % metaLayer.width * _tiledMap.tileHeight, 
					Std.int(i / metaLayer.width) * _tiledMap.tileWidth, 
					angle);
				enemies.push(e);
			}
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