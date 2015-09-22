
package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end

import com.akifox.plik.PLIK;
import com.akifox.plik.Screen;
import com.akifox.plik.Gfx;
import com.akifox.plik.Sfx;
import com.akifox.plik.TextAA;
import com.akifox.transform.Transformation;


import motion.Actuate;
import motion.easing.*;

class ScreenOptions extends Screen
{
	private var _currentLanguage:Int = 0;

	private var optionsMenu:IsoButtonMenu;
	private var backMenu:IsoButtonMenu;

	private var _gametitle1:TextAA;
	private var _gametitle2:TextAA;
	private var _gametitle3:TextAA;

	private var parallax:Parallax;

	private var _ai:String->com.akifox.plik.atlas.AtlasRegion;

	public function new () {
		super();
		cycle = true;
		title = GAME.lang("$OPTIONS");

		_ai = GAME.atlasIcons.getRegion;
	}
	public override function initialize():Void {

		_currentLanguage = GAME.getLanguage();

		if (PLIK.getPref('effects')) {
			parallax = new Parallax();
			addChild(parallax);
		}

		var background = new Gfx('bg.png');
		background.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		background.t.x = rwidth/2;
		background.t.y = rheight/2;
		background.t.flipX();
		addChild(background);

		// TODO draw instead of sprite

		_gametitle1 = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_gametitle1.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle1.t.x = 1991*PLIK.pointFactor;
		_gametitle1.t.y = (290+10)*PLIK.pointFactor;
		_gametitle1.t.skewingX = -37.5;
		_gametitle1.t.rotation = 26.4;
		addChild(_gametitle1);

		_gametitle2 = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_DARK);
		_gametitle2.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle2.t.x = 1991*PLIK.pointFactor;
		_gametitle2.t.y = (290+5)*PLIK.pointFactor;
		_gametitle2.t.skewingX = -37.5;
		_gametitle2.t.rotation = 26.4;
		addChild(_gametitle2);

		_gametitle3 = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_WHITE);
		_gametitle3.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle3.t.x = 1991*PLIK.pointFactor;
		_gametitle3.t.y = 290*PLIK.pointFactor;
		_gametitle3.t.skewingX = -37.5;
		_gametitle3.t.rotation = 26.4;
		addChild(_gametitle3);

		// END

		optionsMenu = new IsoButtonMenu();
		#if (!mobile && !web)
		optionsMenu.x = 0*PLIK.pointFactor;
		optionsMenu.y = 250*PLIK.pointFactor;
		#else
		optionsMenu.x = -200*PLIK.pointFactor;
		optionsMenu.y = 150*PLIK.pointFactor;
		#end

		#if (!mobile && !web)
		optionsMenu.addIsoButton("FULLSCREEN",actionFullscreen,GAME.lang("$FULLSCREEN"),Std.int(117*PLIK.pointFactor),
			_ai(PLIK.getFullscreenOn()?GAME.ICON_SCREEN:GAME.ICON_SCREEN_NO),
			0,2,1);
		#end
		optionsMenu.addIsoButton("MUSIC",actionMusic,GAME.lang("$MUSIC"),Std.int(134*PLIK.pointFactor),
			_ai(PLIK.getMusicOn()?GAME.ICON_MUSIC:GAME.ICON_MUSIC_NO),
			1,3,1);
		optionsMenu.addIsoButton("SOUND",actionSound,GAME.lang("$SOUND"),Std.int(134*PLIK.pointFactor),
			_ai(PLIK.getSoundOn()?GAME.ICON_SOUND:GAME.ICON_SOUND_NO),
			2,4,1);
		optionsMenu.addIsoButton("EFFECTS",actionEffects,GAME.lang("$EFFECTS"),Std.int(134*PLIK.pointFactor),
			_ai(PLIK.getPref('effects')?GAME.ICON_MAGIC:GAME.ICON_MAGIC_NO),
			3,5,1);
		optionsMenu.addIsoButton("LANGUAGE",actionLanguage,GAME.lang("$LANGUAGE"),Std.int(134*PLIK.pointFactor),
			_ai(GAME.ICON_LANGUAGE),
			4,6,1);

		addChild(optionsMenu);

		backMenu = new IsoButtonMenu();
		backMenu.x = 100*PLIK.pointFactor;
		backMenu.y = 880*PLIK.pointFactor;

		backMenu.addIsoButton("BACK",actionBack,"",0,_ai(GAME.ICON_BACK_LEFT),0,2,0);
		addChild(backMenu);

		super.initialize();
	}

	public override function start() {
		super.start(); // call resume
		PLIK.startMusic(GAME.MUSIC_TITLE);
	}

	public override function unload():Void {
		super.unload();
	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
		#if !mobile
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, optionsMenu.onMouseMove);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, backMenu.onMouseMove);
		#end
		optionsMenu.removeEventListener(MouseEvent.CLICK, optionsMenu.onClick);
		backMenu.removeEventListener(MouseEvent.CLICK, backMenu.onClick);
	}

	public override function resume():Void {
		super.resume();

		// HOOKERS ON
		#if !mobile
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, optionsMenu.onMouseMove);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, backMenu.onMouseMove);
		#end
		optionsMenu.addEventListener(MouseEvent.CLICK, optionsMenu.onClick);
		backMenu.addEventListener(MouseEvent.CLICK, backMenu.onClick);
	}

	private override function update(delta:Float):Void {
		if (parallax!=null) parallax.update(delta);
	}

	//########################################################################################
	//########################################################################################


	#if !mobile
	private function onKeyDown(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.ESCAPE,Keyboard.SPACE: actionBack();
			case Keyboard.F: actionFullscreen();
			case Keyboard.M: actionMusic();
			case Keyboard.S: actionSound();
			case Keyboard.E: actionEffects();
			case Keyboard.L: actionLanguage();
		}
	}
	#end

	public function actionBack() {
		PLIK.changeScreen(new ScreenTitle(),PLIK.TRANSITION_SLIDE_RIGHT);
	}

	public function actionEffects() {
		var effects = PLIK.getPref('effects');
		effects = !effects;
		PLIK.setPref('effects',effects);
		PLIK.savePref();

		PLIK.transitionEnabled = effects;

		//see also Main.initialize<Void->Void>
		if (effects) {
			GAME.preloadAssets(); //reload effects
			parallax = new Parallax();
			addChild(parallax);
			setChildIndex(parallax,0);
			optionsMenu.setIcon("EFFECTS",_ai(GAME.ICON_MAGIC));
		} else {
			// destroy atlas
			removeChild(parallax);
			parallax.destroy();
			parallax = null;
			GAME.unloadEffectsAssets(); //unload effects
			optionsMenu.setIcon("EFFECTS",_ai(GAME.ICON_MAGIC_NO));
		}

		if (PLIK.hasHoldScene()) {
			var holdscene:ScreenGame;
			holdscene = PLIK.getHoldScene();
			holdscene.updateEffects();
			holdscene = null;
		}
	}

	public function actionLanguage() {
		var language = PLIK.getPref('language');
		language++;
		if (language>GAME.LANGUAGES_COUNT-1) language = 0;
		PLIK.setPref('language',language);
		PLIK.savePref();

		// reload language
		GAME.loadLanguage();

		// update screen
		_gametitle1.setText(GAME.lang("$OPTIONS"));
		_gametitle2.setText(GAME.lang("$OPTIONS"));
		_gametitle3.setText(GAME.lang("$OPTIONS"));
		#if (!mobile && !web)
		optionsMenu.setText("FULLSCREEN",GAME.lang("$FULLSCREEN"));
		#end
		optionsMenu.setText("MUSIC",GAME.lang("$MUSIC"));
		optionsMenu.setText("SOUND",GAME.lang("$SOUND"));
		optionsMenu.setText("EFFECTS",GAME.lang("$EFFECTS"));
		optionsMenu.setText("LANGUAGE",GAME.lang("$LANGUAGE"));
	}

	public function actionFullscreen() {
		if (PLIK.toggleFullscreen()) { //internal pref save
			optionsMenu.setIcon("FULLSCREEN",_ai(GAME.ICON_SCREEN));
		}
		else {
			optionsMenu.setIcon("FULLSCREEN",_ai(GAME.ICON_SCREEN_NO));
		}
	}

	public function actionMusic() {
		if (PLIK.toggleMusic()) { //internal pref save
			GAME.preloadAssets(); //reload music
			optionsMenu.setIcon("MUSIC",_ai(GAME.ICON_MUSIC));
		}
		else {
			GAME.unloadMusicAssets(); //unload music
			optionsMenu.setIcon("MUSIC",_ai(GAME.ICON_MUSIC_NO));
		}
	}

	public function actionSound() {
		if (PLIK.toggleSound()) { //internal pref save
			GAME.preloadAssets(); //reload sounds
			optionsMenu.setIcon("SOUND",_ai(GAME.ICON_SOUND));
		}
		else {
			GAME.unloadSoundAssets(); //unload sounds
			optionsMenu.setIcon("SOUND",_ai(GAME.ICON_SOUND_NO));
		}
	}
}
