
package ;

import openfl.Lib;
import openfl.events.MouseEvent;
import com.akifox.plik.ShapeContainer;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.Screen;
import com.akifox.plik.TextAA;
import com.akifox.plik.Sfx;
import com.akifox.transform.Transformation;
import com.akifox.plik.PLIK;
#if !mobile
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
#end

import motion.Actuate;


typedef OverlayMaskPanel = {
    var text:String;
    var draw:Bool;
    var mask_x:Float;
    var mask_y:Float;
    var mask_width:Float;
    var mask_height:Float;
}

class OverlayMask extends SpriteContainer
{

	private var _maskX:Float = 0;
	private var _maskY:Float = 0;
	private var _maskWidth:Float = 0;
	private var _maskHeight:Float = 0;
	private var _endF:Void->Void;

	private var _panels:Array<OverlayMaskPanel>;
	private var _activePanel:Int = -1;

	private var _screen:Screen;

	private var _infoText:TextAA;
	private var _infoTextSprite:SpriteContainer;

	private var screen_width:Float = 1;
	private var screen_height:Float = 1;
	private var span0X:Float = 1;
	private var span0Y:Float = 1;

	private var bgh:Float = 1;
	private static inline var BGH:Int = 400;

	private static inline var SPAN:Int = 50;

	public function new(screen:Screen,ovmp:Array<OverlayMaskPanel>,endF:Void->Void) {
		super();
		_screen = screen;
		_endF = endF;
		_panels = ovmp;


		bgh = BGH*PLIK.pointFactor;

		_infoTextSprite = new SpriteContainer();
		addChild(_infoTextSprite);

		_infoText = new TextAA("",Std.int(130*PLIK.pointFactor),GAME.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER);
		_infoText.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_infoTextSprite.addChild(_infoText);

		goNextPanel();
		addEventListener(MouseEvent.CLICK, onClick);
		#if !mobile
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		#end

		Sfx.fastPlay(GAME.SOUND_OVERLAY_LONG);
	}

	private var _inTransition:Bool = false;

	private static inline var TIMING_TRANSITION = 0.5;
	private static inline var TIMING_CLICKENABLE = 0.7;

	private function goNextPanel() {

		if (_inTransition) return;
		_inTransition = true;

		if (_activePanel>=0) {
			disappear();
		}
		else appear();

	}

	private function disappear() {

		Sfx.fastPlay(GAME.SOUND_OVERLAY_SHORT);

		//Actuate.tween(_infoTextSprite,TIMING_TRANSITION/2,{alpha:0,y:screen_height});
		Actuate.tween(_infoTextSprite,TIMING_TRANSITION/2,{y:screen_height});
		Actuate.timer(TIMING_TRANSITION/2).onComplete(function() {
			appear();
		});
	}


	private function appear() {

		_activePanel++;

		if (_activePanel>_panels.length-1) {
			this.destroy();
			_endF();
			return;
		}

		redraw(true);

		_infoTextSprite.y = screen_height;

		//Actuate.tween(_infoTextSprite,TIMING_TRANSITION,{alpha:1,y:screen_height-bgh});
		Actuate.tween(_infoTextSprite,TIMING_TRANSITION,{y:screen_height-bgh});
		Actuate.timer(TIMING_CLICKENABLE).onComplete(function() {
			_inTransition = false;
		});

	}

	public function redraw(force:Bool=false) {
		if (_inTransition && !force) return;
		screen_width = Lib.current.stage.stageWidth/_screen.currentScale;
		screen_height = Lib.current.stage.stageHeight/_screen.currentScale;
		span0X = _screen.x/_screen.currentScale;
		span0Y = _screen.y/_screen.currentScale;
		x = -span0X;
		y = -span0Y;

		if (_panels[_activePanel].draw) {
			graphics.clear();
			var ww = _panels[_activePanel].mask_width;
			if (ww>0) {
				var hh = _panels[_activePanel].mask_height;
				var _colours:Array<UInt> = [0x242424, 0x000000];
				var _alphas = [0, 0.85];
				var _ratios = [0, 0xFF];
				var _matrix = new openfl.geom.Matrix();

				_matrix.createGradientBox(ww, hh, 0, _panels[_activePanel].mask_x-ww/2+span0X, _panels[_activePanel].mask_y-hh/2+span0Y);
				graphics.beginGradientFill(openfl.display.GradientType.RADIAL, _colours, _alphas, _ratios, _matrix);
			} else {
				graphics.beginFill(0,0.8);
			}
			graphics.drawRect(0,0,screen_width,screen_height);
			graphics.endFill();
		}

		_infoTextSprite.graphics.clear();
		_infoTextSprite.graphics.beginFill(0x000000,0.8);
		_infoTextSprite.graphics.drawRect(0,0,screen_width,bgh);
		_infoTextSprite.graphics.endFill();
		_infoTextSprite.graphics.beginFill(GAME.COLOR_ORANGE,1);
		_infoTextSprite.graphics.drawRect(0,0,screen_width,25*PLIK.pointFactor);
		_infoTextSprite.graphics.endFill();
		_infoTextSprite.x = 0;
		_infoTextSprite.y = screen_height-bgh;

		_infoText.setText(_panels[_activePanel].text);
		_infoText.t.x = screen_width/2;
		_infoText.t.y = bgh/2;
	}

	public override function destroy() {
		removeEventListener(MouseEvent.CLICK, onClick);
		#if !mobile
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		#end
		_panels = null;
		_screen = null;
		_infoTextSprite.removeChild(_infoText);
		_infoText.destroy();
		_infoText = null;
		_infoTextSprite.destroy();
		_infoTextSprite = null;
	}

	private function onClick(_) {
		goNextPanel();
	}

	#if !mobile
	private function onKeyUp(event:KeyboardEvent):Void {
		if (event.keyCode== Keyboard.SPACE || event.keyCode == Keyboard.ESCAPE) 
			goNextPanel();
		
	}
	#end

}