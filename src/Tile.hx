
package ;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Assets;
import motion.Actuate;
import motion.easing.*;
import com.akifox.plik.PLIK;
import com.akifox.plik.atlas.AtlasRegion;
import com.akifox.plik.ShapeContainer;

enum TileStatus {
    BLANK;
    SELECT;
    MISTAKE;
}

class Tile extends ShapeContainer {

	public static var tileRegions:Array<AtlasRegion>;

	public static var tw(get,never):Int;
	private static function get_tw():Int {
		return Math.round(570*PLIK.pointFactor);
	}
	public static var th(get,never):Int;
	private static function get_th():Int {
		return Math.round(285*PLIK.pointFactor);
	}
	public static var dx(get,never):Int;
	private static function get_dx():Int {
		return Math.round(tw/10);
	}
	public static var dy(get,never):Int;
	private static function get_dy():Int {
		return Math.round(th/10);
	}

	//////////////////////////////////////////////////////////////////////////////////////////

    public override function toString():String {
        return '[GAME.Tile]';
    }

    public override function destroy() {
    	Actuate.stop(this);
    	tileboard = null;
    	super.destroy();
    }

	var status:TileStatus;
	var posx:Float;
	var posy:Float;
	var locked = false;
	var tileboard:TileBoard;

	public function getPosx():Float {
		return posx;
	}
	public function getPosy():Float {
		return posy;
	}
	
	public function new (posx:Float,posy:Float,tileboard:TileBoard) {
		
		super ();

		this.posx = posx;
		this.posy = posy;
		this.tileboard = tileboard;
		status = TileStatus.BLANK;


		this.drawTile(0);

		scaleX = 1;
		scaleY = 1;
		x = posx;
		y = posy;
		alpha = 0;
		locked = true;

	}

	public function getStatus():TileStatus {
		return status;
	}

	private function drawTile(index:Int) {
		graphics.clear();
		tileRegions[index].drawNow(graphics);
	}

	public function appear():Void{
		scaleX = 2;
		scaleY = 2;
		x = posx - Tile.tw / 2;
		y = posy - Tile.th / 2;
		alpha = 0;

		var d:Float = Std.random(Math.round(60*ScreenGame.TIMING_TILE_APPEAR_DELAY))/100; //delay 0.5 sec

		Actuate.tween (this, ScreenGame.TIMING_TILE_APPEAR, { scaleX: 1, scaleY: 1, x: posx, y: posy } ).ease(Elastic.easeOut).delay(d);
		Actuate.tween (this, ScreenGame.TIMING_TILE_APPEAR, { alpha: 1 } ).delay(d).onComplete(onAppear);
	}

	private function onAppear():Void{
		locked = false;
	}

	public function moveme(newx:Float,newy:Float,duration:Float):Void{
		posx = newx;
		posy = newy;
		Actuate.tween(this, duration, { x: newx, y: newy } ).ease(Quad.easeOut);
	}

	private function reset():Void{
		scaleX = 1;
		scaleY = 1;
		x = posx;
		y = posy;
		alpha = 1;
		locked = false;
	}

	public function highlight(?status:TileStatus,?force:Bool=false):Void {
		if (status == null) status = TileStatus.SELECT;
    	if (locked && !force) return;
    	if (force && !tileboard.isBoardRotating) this.reset();

		if (status != TileStatus.MISTAKE) this.status = status;
		locked = true;

    	if (status == TileStatus.SELECT) {
			this.drawTile(1);
			if (tileboard.isBoardRotating) Actuate.timer(ScreenGame.TIMING_TILE_HIGHLIGHT).onComplete(onHighlight);
			else Actuate.tween(this, ScreenGame.TIMING_TILE_HIGHLIGHT/2, { y: y + 17*PLIK.pointFactor } ).repeat(1).reflect().onComplete(onHighlight);
		} else if (status == TileStatus.BLANK) {
			this.drawTile(0);
			if (tileboard.isBoardRotating) Actuate.timer(ScreenGame.TIMING_TILE_HIGHLIGHT).onComplete(onHighlight);
			else Actuate.tween(this, ScreenGame.TIMING_TILE_HIGHLIGHT/2, { y: y + 17*PLIK.pointFactor } ).repeat(1).reflect().onComplete(onHighlight);
		} else if (status == TileStatus.MISTAKE) {
			this.drawTile(2);
			if (tileboard.isBoardRotating) Actuate.timer(ScreenGame.TIMING_TILE_HIGHLIGHT).onComplete(highlight,[TileStatus.BLANK,true]);
			else Actuate.tween(this, ScreenGame.TIMING_TILE_HIGHLIGHT/2, { y: y + 17*PLIK.pointFactor } ).repeat(1).reflect().onComplete(highlight,[TileStatus.BLANK,true]);
		}
		
	}
	
	private function onHighlight ():Void {
		locked = false;
	}


}