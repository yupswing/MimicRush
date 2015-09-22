
package ;

import com.akifox.plik.PLIK;
import com.akifox.plik.ShapeContainer;

import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.events.Event;
import motion.Actuate;

import openfl.geom.Rectangle;
import openfl.display.Tilesheet;

class ParallaxSprite {

	public var speed:Float; //pixel*second
	public var x:Float;
	public var y:Float;
	public var region:com.akifox.plik.atlas.AtlasRegion;
	public var alpha:Float;


	public function new(size:Int,color:Int,x:Float,y:Float,speed:Float) { //size 0,1,2 // color 0,1
		this.speed = speed/(size+1)+speed/(size+1)*Math.random()/Parallax.SPEED_VAR; //speed+speed/10
		this.x = x;
		this.y = y;
		this.alpha = 1;
		var s = "4x";
		if (size==1) s = "2x";
		if (size==2) s = "";
		var c = "white";
		if (color==1) c="yellow";
		region = GAME.atlasParallax.getRegion('tile'+s+'_'+c+'.png');
	}

    public function toString():String {
        return '[ParallaxSprite x=$x, y=$y, speed=$speed]';
    }

}


class Parallax extends ShapeContainer {
	public static inline var SPEED = 200; //(pixel * 100) speed per frame (minimum)
	public static inline var SPEED_VAR = 10; // 1/x swing speed same layer
	private static inline var STAGE_WIDTH = 2560;
	private static inline var STAGE_HEIGHT = 1446;
	private static inline var BOUND_WIDTH = 3200;
	private static inline var BOUND_HEIGHT = 2000;
	private static inline var BIGGEST_TILE_WIDTH = 311;
	private static inline var ALPHA_OFFSET = 200;
	private var _minX:Float;
	private var _maxX:Float;
	private var _minY:Float;
	private var _maxY:Float;

	//private static inline var FREQUENCY = 980;
	private static inline var START_TILE = 60;//100;

	private var sprites:Array<ParallaxSprite>;

	private var speed:Float = 1;
	private var stage_width:Float = 1;
	private var stage_height:Float = 1;
	private var bound_width:Float = 1;
	private var bound_height:Float = 1;
	private var alpha_offset:Float = 1;
	private var base_alpha:Float = 1;

	public function new (?base_alpha:Float=1) {
		super();
		_data = new Array<Float>();
		_dataIndex = 0;
		this.base_alpha = base_alpha;
		//_renderFlags = Tilesheet.TILE_TRANS_2x2 | Tilesheet.TILE_ALPHA | Tilesheet.TILE_BLEND_NORMAL | Tilesheet.TILE_RGB | Tilesheet.TILE_RECT;
		#if !flash //fix for flash no alpha on tileDraw
		_renderFlags = Tilesheet.TILE_RECT | Tilesheet.TILE_ALPHA ;
		#else //fix for flash no alpha on tileDraw
		alpha = base_alpha;
		_renderFlags = Tilesheet.TILE_RECT;
		#end

		sprites = new Array<ParallaxSprite>();
		speed = SPEED*PLIK.pointFactor/100;
		stage_width = STAGE_WIDTH*PLIK.pointFactor;
		stage_height = STAGE_HEIGHT*PLIK.pointFactor;
		bound_width = BOUND_WIDTH*PLIK.pointFactor;
		bound_height = BOUND_HEIGHT*PLIK.pointFactor;
		alpha_offset = ALPHA_OFFSET*PLIK.pointFactor;
		super ();

		_minX = (-(bound_width-stage_width)-BIGGEST_TILE_WIDTH)/2;
		_maxX = bound_width+_minX;
		_minY = -(bound_height-stage_height)/2;
		_maxY = bound_height+_minY;

		for (i in 0...START_TILE) {
			addTile(true);
		}

/*		2560 3000

		1446 2000*/

		//GAME.atlasParallax.getRegion('tile4x_white.png');
		//GAME.atlasParallax.getRegion('tile4x_yellow.png');

	}

	private function addTile(?randomx:Bool=false){
		var s:Int=Math.round(Math.random()*2);
		var c:Int = Math.round(Math.random()*1);
		var sprite = new ParallaxSprite(s,c,0,0,speed);
		resetTile(sprite,randomx);
		sprites.push(sprite);
	}

	private function resetTile(sprite:ParallaxSprite,?randomx:Bool=false):ParallaxSprite {
		sprite.x = _maxX;
		if (randomx) sprite.x = (Math.random()*bound_width)+_minX;
		sprite.y = (Math.random()*bound_height)+_minY;
		return sprite;
	}

	private var skipped:Float=0;
	private var skip:Float=2;
	private var deltasum:Float=0;
	public function update(delta:Float){
		deltasum+=delta;
        if (skipped < skip) {
			skipped++;
        	return;
        }

/*		if (numChildren<100 && Math.round(Math.random()*1000) >= FREQUENCY) {
			addTile();
		}*/
		for (el in sprites) {
			el.x-=el.speed;

			// LEFT
			// RIGHT

			if (el.x<_minX) {
				resetTile(el);
			}
			if (el.x<_minX+alpha_offset) {
				el.alpha = (el.x-_minX)/alpha_offset*base_alpha;
			} else if (el.x>_maxX-alpha_offset) {
				el.alpha = (_maxX-el.x)/alpha_offset*base_alpha;
			} else if (el.alpha!=base_alpha) el.alpha = base_alpha;
			prepareTile(el);
		}

		graphics.clear();
		drawTiles();

        skipped = 0;
		deltasum = 0;
	}

	private var _data:Array<Float>;
	private var _dataIndex:Int = 0;
	private var _renderFlags:Int;

	private function prepareTile(el:ParallaxSprite) {

		var _data = _data;
		var _dataIndex = _dataIndex;

		// Destination point
		_data[_dataIndex++] = el.x;
		_data[_dataIndex++] = el.y;

		// Source rectangle
		_data[_dataIndex++] = el.region.rect.x;
		_data[_dataIndex++] = el.region.rect.y;
		_data[_dataIndex++] = el.region.rect.width;
		_data[_dataIndex++] = el.region.rect.height;

		// matrix transformation
/*		if (angle == 0)
		{
			// fast defaults for non-rotated tiles (cos=1, sin=0)
			_data[_dataIndex++] = scaleX; // m00
			_data[_dataIndex++] = 0; // m01
			_data[_dataIndex++] = 0; // m10
			_data[_dataIndex++] = scaleY; // m11
		}
		else
		{
			var cos = Math.cos(angle * PLIK.DEG2RAD);
			var sin = Math.sin(angle * PLIK.DEG2RAD);
			_data[_dataIndex++] = cos * scaleX; // m00
			_data[_dataIndex++] = -sin * scaleY; // m10
			_data[_dataIndex++] = sin * scaleX; // m01
			_data[_dataIndex++] = cos * scaleY; // m11
		}*/

/*		if (_flagRGB)
		{
			_data[_dataIndex++] = red;
			_data[_dataIndex++] = green;
			_data[_dataIndex++] = blue;
		}*//*
		if (_flagAlpha)
		{*/
		#if !flash //fix for flash no alpha on tileDraw
		_data[_dataIndex++] = el.alpha;
		#end
		// }

		this._dataIndex = _dataIndex;
	}

	private function drawTiles() {
		if (_dataIndex > 0)
		{
			GAME.atlasParallax.drawNowBatch(graphics, _data, true, _renderFlags, _dataIndex);
			_dataIndex = 0;
		}
	}

	public override function toString():String {
		return "[GAME.Parallax]";
	}
	public override function destroy() {
		var el:ParallaxSprite;
		while (sprites.length > 0) {
			el = sprites.pop();
			el = null;
		}
		super.destroy();
	}
}
