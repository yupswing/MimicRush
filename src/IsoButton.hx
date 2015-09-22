package;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.Tilesheet;
import openfl.filters.GlowFilter;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.text.TextFormatAlign;
import openfl.display.BitmapData;

import com.akifox.plik.PLIK;
import com.akifox.plik.TextAA;
import com.akifox.transform.Transformation;
import com.akifox.plik.SpriteContainer;

import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.atlas.AtlasRegion;

import motion.easing.*;
import motion.Actuate;
/**
 *  Based on https://github.com/dmitryhryppa/dhFramework
 * */
class IsoButton extends SpriteContainer
{

	private var _text:TextAA;
	private var _iconRegion:AtlasRegion;
	private var _baseRegions:Array<AtlasRegion>; // 0 : Quiet // 1 : Over
	private var _baseIndex:Int = 0;
	public var _height:Int;

	private var _disabled:Bool = false;
	public var disabled(get,set):Bool;

	public var alpha_over:Float = 1;
	public var alpha_base:Float = 1;


    public override function toString():String {
        return '[GAME.IsoButton <id '+id+'>]';
    }

	private function get_disabled():Bool{
		return _disabled;
	}
	private function set_disabled(value:Bool):Bool{
		_disabled=value;
		if (value) {
			alpha_base = 0.2;
		}
		else alpha_base = 1;
		this.reset();
		return _disabled;
	}

	public var action:Void->Void;
	public var id:String;

	public var startpos:Array<Int>;
	public var endpos:Array<Int>;

	public var rx:Float;
	public var ry:Float;

	private var _states:Int;
	public function new(id:String,action:Void->Void,text:String,size:Int,
						baseQuietRegion:AtlasRegion,
						baseOverRegion:AtlasRegion,
						iconRegion:AtlasRegion) {
		super(false); //no transformations			
		this.buttonMode = true;

		_baseRegions = [baseQuietRegion,baseOverRegion];
		_iconRegion = iconRegion;

		this.id = id;
		this.action = action;


		_height = Std.int(baseQuietRegion.height);

		if (text!="") {

			_text = new TextAA(text,size,GAME.COLOR_BLACK);
			_text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
			_text.t.x = 756*PLIK.pointFactor;
			_text.t.y = _height-Tile.th-102*PLIK.pointFactor;
		 	_text.t.skewingX = 37.5;
		 	_text.t.rotation = -26.4;
			addChild(_text);

		}


		this.drawIsoButton(alpha_base);
	}

	public function setText(value:String) {
		_text.setText(value);
	}

	public function setIcon(iconRegion:AtlasRegion) {
		_iconRegion = iconRegion;
		this.drawIsoButton();
	}

	public function mouseIn():Bool {
		if (_disabled || performaction) return false;
		_baseIndex = 1; this.drawIsoButton(alpha_over);
		Actuate.tween(this, 0.2, { y: ry+8*PLIK.pointFactor } ).ease(Quad.easeOut);
		return true;
	}

	public function mouseOut():Bool {
		if (_disabled || performaction) return false;
		_baseIndex = 0; this.drawIsoButton(alpha_base);
		Actuate.tween(this, 0.2, { y: ry } ).ease(Quad.easeOut);
		return true;
	}

	public function reset():Bool{
		_baseIndex = 0; this.drawIsoButton(alpha_base);
		Actuate.stop(this);
		this.x = rx;
		this.y = ry;
		return true;
	}

	var performaction:Bool = false;

	public function click():Bool {
		if (_disabled || performaction) return false;
		performaction = true;
		y = ry+25*PLIK.pointFactor;
		_baseIndex = 1; this.drawIsoButton(alpha_over);
		this.action();
		Actuate.tween(this, 0.2, { y: ry } ).ease(Back.easeOut).delay(0.1).onComplete(completeClick);
		return true;
	}

	private function completeClick(){
		performaction = false;
		this.mouseOut();
	}

	public function drawIsoButton(?alpha:Float=0) {
		if (alpha==0) alpha = alpha_base;
		graphics.clear();
		_baseRegions[_baseIndex].drawNow(graphics, 0, 0, alpha);
		_iconRegion.drawNow(graphics, 0, _height-Tile.th, 1);
	}
	
}