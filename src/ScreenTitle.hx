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
import com.akifox.plik.Utils;
import com.akifox.plik.Screen;
import com.akifox.plik.Gfx;
import com.akifox.plik.TextAA;
import com.akifox.transform.Transformation;
import openfl.geom.Point;

import motion.Actuate;
import motion.easing.*;

import extension.share.Share;

class ScreenTitle extends Screen
{
	private var background:Gfx;
	private var screenOverlay:Overlay;
	private var titleMenu:IsoButtonMenu;
	private var shareMenu:IsoButtonMenu;
	private var buyMenu:IsoButtonMenu;

	private var parallax:Parallax;

	public function new () {
		super();
		cycle = PLIK.getPref('effects');
		title = GAME.GAME_NAME;
	}

	public override function initialize():Void {

		GAME.getLanguage();

		if (PLIK.getPref('effects')) {
			parallax = new Parallax();
			addChild(parallax);
		}

		background = new Gfx('bg.png');
		background.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		background.t.x = rwidth/2;
		background.t.y = rheight/2;
		background.t.flipX();
		addChild(background);

		// TODO draw instead of sprite

		var _gametitle = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 1991*PLIK.pointFactor;
		_gametitle.t.y = (290+10)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_DARK);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 1991*PLIK.pointFactor;
		_gametitle.t.y = (290+5)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_WHITE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 1991*PLIK.pointFactor;
		_gametitle.t.y = 290*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		// END

		var _gameinprogress = PLIK.hasHoldScene();

		titleMenu = new IsoButtonMenu();
		#if (!mobile && !web)
			if (_gameinprogress) {
				titleMenu.x = 0*PLIK.pointFactor;
				titleMenu.y = 250*PLIK.pointFactor;
			} else {
				titleMenu.x = -200*PLIK.pointFactor;
				titleMenu.y = 150*PLIK.pointFactor;
			}
		#else
			if (_gameinprogress) {
				titleMenu.x = 200*PLIK.pointFactor;
				titleMenu.y = 350*PLIK.pointFactor;
			} else {
				titleMenu.x = 0*PLIK.pointFactor;
				titleMenu.y = 250*PLIK.pointFactor;
			}
		#end

		var _ai = GAME.atlasIcons.getRegion;

		var playtext = GAME.lang("$PLAY");
		if (_gameinprogress) {
			titleMenu.addIsoButton("RESTART",actionRestart,GAME.lang("$NEWGAME"),Std.int(134*PLIK.pointFactor),_ai(GAME.ICON_RESTART),0,2,1);
			playtext = GAME.lang("$RESUME");
		}
		titleMenu.addIsoButton("PLAY",actionPlay,playtext,Std.int(168*PLIK.pointFactor),_ai(GAME.ICON_PLAY),1,3,1);
		titleMenu.addIsoButton("STATISTICS",actionStats,GAME.lang("$STATISTICS"),Std.int(118*PLIK.pointFactor),_ai(GAME.ICON_TROPHY),2,4,1);
		titleMenu.addIsoButton("OPTIONS",actionOptions,"",0,_ai(GAME.ICON_COG),3,5,0);
		titleMenu.addIsoButton("HELP",actionHelp,"",0,_ai(GAME.ICON_HELP),4,4,0);
		titleMenu.addIsoButton("INFO",actionCredits,"",0,_ai(GAME.ICON_INFO),5,3,0);
		#if (!mobile && !web)
		titleMenu.addIsoButton("QUIT",actionQuit,GAME.lang("$QUIT"),Std.int(134*PLIK.pointFactor),_ai(GAME.ICON_QUIT),4,6,1);
		#end

		addChild(titleMenu);

		#if mobile
		shareMenu = new IsoButtonMenu();
		shareMenu.x = 100*PLIK.pointFactor;
		shareMenu.y = 880*PLIK.pointFactor;
		shareMenu.addIsoButton("SHARE",actionShare,"",0,_ai(GAME.ICON_SHARE),0,2,0);
		addChild(shareMenu);
		#end

		#if app_donations
		buyMenu = new IsoButtonMenu();
		buyMenu.x = 100*PLIK.pointFactor;
		buyMenu.y = 880*PLIK.pointFactor;
		buyMenu.addIsoButton("BUY",actionBuy,"",0,_ai(GAME.ICON_MOBILE),0,2,0);
		addChild(buyMenu);
		#end

		super.initialize();
	}

	public override function start() {
		super.start();  // call resume
		PLIK.startMusic(GAME.MUSIC_TITLE);

		#if app_checkupdates
		if (GAME.showUpdate) {
			hookersOff();
			screenOverlay = new Overlay();
			screenOverlay.setText(GAME.lang("$UPDATE_CONTENT"),GAME.lang("$UPDATE_TITLE"));
			screenOverlay.addEventListener(MouseEvent.CLICK,actionUpdate);
			addChild(screenOverlay);
		}
		#end
	}

	public override function unload():Void {
		super.unload();
	}

	public override function hold():Void {
		super.hold();
		hookersOff();
	}

	public override function resume():Void {
		super.resume();
		hookersOn();
	}

	private override function update(delta:Float):Void {
		if (parallax!=null) parallax.update(delta);
	}

	//########################################################################################
	//########################################################################################


	public function hookersOn() {
		// HOOKERS ON
		#if !mobile

		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, titleMenu.onMouseMove);
		//Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, shareMenu.onMouseMove);

		#else

		shareMenu.addEventListener(MouseEvent.CLICK, shareMenu.onClick);

		#end

		#if app_donations

		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, buyMenu.onMouseMove);
		buyMenu.addEventListener(MouseEvent.CLICK, buyMenu.onClick);

		#end
		titleMenu.addEventListener(MouseEvent.CLICK, titleMenu.onClick);
	}

	public function hookersOff() {
		// HOOKERS OFF
		#if !mobile

		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, titleMenu.onMouseMove);
		//Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, shareMenu.onMouseMove);

		#else

		shareMenu.removeEventListener(MouseEvent.CLICK, shareMenu.onClick);

		#end

		#if app_donations
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, buyMenu.onMouseMove);
		buyMenu.removeEventListener(MouseEvent.CLICK, buyMenu.onClick);
		#end

		titleMenu.removeEventListener(MouseEvent.CLICK, titleMenu.onClick);
	}

	#if !mobile
	private function onKeyDown(event:KeyboardEvent):Void {
		switch (event.keyCode) {
			case Keyboard.SPACE: actionPlay();
			case Keyboard.ESCAPE: actionQuit();
			case Keyboard.N: actionRestart();
			case Keyboard.O: actionOptions();
			case Keyboard.S: actionStats();
			case Keyboard.H: actionHelp();
			case Keyboard.C,Keyboard.I: actionCredits();
		}
	}
	#end

	#if app_checkupdates
	public function actionUpdate(e:MouseEvent) {
		Utils.gotoWebsite(GAME.LINK_UPDATE);
		screenOverlay.removeEventListener(MouseEvent.CLICK,actionUpdate);
		removeChild(screenOverlay);
		screenOverlay.destroy();
		screenOverlay = null;
		GAME.showUpdate = false;
		hookersOn();
	}
	#end

	public function actionQuit() {
		PLIK.quit();
	}

	public function actionPlay() {
		if (!PLIK.hasHoldScene()) {
			actionRestart();
			return;
		}
		PLIK.resumeScreen(PLIK.TRANSITION_SLIDE_UP); //recover hold scene
	}

	#if mobile
	public function actionShare() {
		Share.share(GAME.lang("$SHARE"));
	}
	#end

	#if app_donations
	public function actionBuy() {
		PLIK.changeScreen(new ScreenDonate(),PLIK.TRANSITION_SLIDE_DOWN); //start a new scene
	}
	#end

	public function actionRestart() {
		PLIK.changeScreen(new ScreenGame(),PLIK.TRANSITION_SLIDE_UP); //start a new scene
	}

	public function actionOptions() {
		PLIK.changeScreen(new ScreenOptions(),PLIK.TRANSITION_SLIDE_LEFT); //start a new scene
	}

	public function actionCredits() {
		PLIK.changeScreen(new ScreenCredits(),PLIK.TRANSITION_SLIDE_DOWN); //start a new scene
	}

	public function actionStats() {
		PLIK.changeScreen(new ScreenStatistics(),PLIK.TRANSITION_SLIDE_RIGHT); //start a new scene
	}

	public function actionHelp() {
		GAME.isHelpMode = true;
		actionRestart();
	}
}
