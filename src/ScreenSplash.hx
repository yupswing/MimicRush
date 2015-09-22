
package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.PLIK;
import com.akifox.plik.Gfx;
import com.akifox.plik.Screen;
import com.akifox.transform.Transformation;
import com.akifox.plik.atlas.*;


class ScreenSplash extends Screen
{
	private var background:Gfx;
	private var logo:Gfx;

	public function new () {
		super();
		resizePow = false;
		cycle = false;
		title = "Splash";
	}

	public override function initialize():Void {

		background = new Gfx('bg_splash.jpg');
		background.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		background.t.x = rwidth/2;
		background.t.y = rheight/2;
		background.t.scaling = 3;
		background.t.rotation = 10;
        addChild(background);

		logo = new Gfx('akifox.png');
		logo.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		logo.t.x = rwidth/2;
		logo.t.y = rheight/2;
		logo.t.scaling = 0.5;
		logo.t.rotation = -30;
		logo.alpha = 0;
        addChild(logo);

        //PLIK.quit();

        Lib.current.stage.color = 0x852dff;

        super.initialize(); // init_super at the end
    }

	public override function unload():Void {
		super.unload();

		background.destroyCache();
		logo.destroyCache();
	}

	public override function start() {
		PLIK.startMusic(GAME.MUSIC_TITLE,true);

        Actuate.tween(logo.t,1.5,{scaling:1,rotation:0}).delay(0.8).ease(Sine.easeOut);
        Actuate.tween(logo,1.5,{alpha:1}).delay(0.8);
        Actuate.tween(background.t,3,{scaling:2,rotation:-5}).ease(Sine.easeInOut);

        Actuate.timer(3).onComplete(skip);

		super.start();  // call resume
	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
        #if !mobile
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);
		#end
		Lib.current.stage.removeEventListener(MouseEvent.CLICK, onClick);
	}

	public override function resume():Void {
		super.resume();

		// HOOKERS ON
        #if !mobile
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);
		#end
		Lib.current.stage.addEventListener(MouseEvent.CLICK, onClick);
	}

	//########################################################################################
	//########################################################################################

  #if !mobile
	private function onKeyPress(event:KeyboardEvent) {
		if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.SPACE) skip();
	}
	#end

	private function onClick(event:MouseEvent) {
		skip();
	}

	private function skip() {
		Actuate.reset();
    Lib.current.stage.color = GAME.GAME_BGCOLOR;
		#if app_donations
		PLIK.changeScreen(new ScreenDonate(),PLIK.TRANSITION_SLIDE_UP);
		#else
		PLIK.changeScreen(new ScreenTitle(),PLIK.TRANSITION_SLIDE_UP);
		#end
	}

}
