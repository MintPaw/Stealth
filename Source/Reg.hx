package;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;

/**
 * ...
 * @author ...
 */
class Reg
{
	public static var rnd:FlxRandom = new FlxRandom();
	
	public function new() 
	{
		
	}
	
	public static function lineIntersectsRect(p1:FlxPoint, p2:FlxPoint, r:FlxRect):Bool
	{
		return lineIntersectsLine(p1, p2, new FlxPoint(r.x, r.y), new FlxPoint(r.x + r.width, r.y)) ||
			   lineIntersectsLine(p1, p2, new FlxPoint(r.x + r.width, r.y), new FlxPoint(r.x + r.width, r.y + r.height)) ||
			   lineIntersectsLine(p1, p2, new FlxPoint(r.x + r.width, r.y + r.height), new FlxPoint(r.x, r.y + r.height)) ||
			   lineIntersectsLine(p1, p2, new FlxPoint(r.x, r.y + r.height), new FlxPoint(r.x, r.y));
	}

	private static function lineIntersectsLine(l1p1:FlxPoint, l1p2:FlxPoint, l2p1:FlxPoint, l2p2:FlxPoint):Bool
	{
		var q:Float = (l1p1.y - l2p1.y) * (l2p2.x - l2p1.x) - (l1p1.x - l2p1.x) * (l2p2.y - l2p1.y);
		var d:Float = (l1p2.x - l1p1.x) * (l2p2.y - l2p1.y) - (l1p2.y - l1p1.y) * (l2p2.x - l2p1.x);
		
		if (d == 0) return false;
		
		var r:Float = q / d;
		
		q = (l1p1.y - l2p1.y) * (l1p2.x - l1p1.x) - (l1p1.x - l2p1.x) * (l1p2.y - l1p1.y);
		var s:Float = q / d;
		
		if (r < 0 || r > 1 || s < 0 || s > 1) return false;
		
		return true;
	}
	
}