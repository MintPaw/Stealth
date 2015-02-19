package ;
import openfl.Assets;
import openfl.media.SoundChannel;

/**
 * ...
 * @author MintPaw
 */
class Sm
{
	public static inline var ENEMY_SHOOT:String =
                                "Assets/sound/enemyShoot.wav";
	
	private static var _effectChannel:SoundChannel;
	
	public function new() 
	{
		
	}
	
	public static function playEffect(effectName:String):Void
	{
		_effectChannel = Assets.getSound(effectName).play(0, 0);
	}
	
}
