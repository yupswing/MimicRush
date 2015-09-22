
package ;

import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end
import openfl.Lib;

import com.akifox.plik.PLIK;
import com.akifox.plik.Utils;
import com.akifox.plik.Screen;
import com.akifox.plik.Data;
import com.akifox.plik.Gfx;
import com.akifox.transform.Transformation;
import com.akifox.plik.TextAA;
import com.akifox.plik.SpriteContainer;

import motion.Actuate;
import motion.easing.*;

class ScreenCredits extends Screen
{
	private var backMenu:IsoButtonMenu;
	var _logo:Gfx;
	var _credits:Gfx;
	private var parallax:Parallax;
	var _linkTwitter:SpriteContainer;
	var _linkFacebook:SpriteContainer;
	var _linkWWW:SpriteContainer;

	public function new () {
		super();
		cycle = PLIK.getPref('effects');
		title = GAME.lang("$CREDITS");
	}

	public override function initialize():Void {

		GAME.getLanguage();

		if (PLIK.getPref('effects')) {
			parallax = new Parallax();
			addChild(parallax);
		}

		var background = new Gfx('bg.png');
		background.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		background.t.x = rwidth/2;
		background.t.y = rheight/2;
		addChild(background);

		// TODO draw instead of sprite

		var _gametitle = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 536*PLIK.pointFactor;
		_gametitle.t.y = (290+10)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = 37.5;
	 	_gametitle.t.rotation = -26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_DARK);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 536*PLIK.pointFactor;
		_gametitle.t.y = (290+5)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = 37.5;
	 	_gametitle.t.rotation = -26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(title,Std.int(250*PLIK.pointFactor),GAME.COLOR_WHITE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 536*PLIK.pointFactor;
		_gametitle.t.y = 290*PLIK.pointFactor;
	 	_gametitle.t.skewingX = 37.5;
	 	_gametitle.t.rotation = -26.4;
		addChild(_gametitle);

		// END

		_credits = new Gfx('credits.png');
		_credits.t.x = 210*PLIK.pointFactor;
		_credits.t.y = 350*PLIK.pointFactor;
		addChild(_credits);

		_linkWWW = new SpriteContainer();
		GAME.atlasIcons.getRegion(GAME.ICON_LINK_HOME).drawNow(_linkWWW.graphics);
		_linkWWW.t.x = 10*PLIK.pointFactor;
		_linkWWW.t.y = 840*PLIK.pointFactor;
		addChild(_linkWWW);

		_linkFacebook = new SpriteContainer();
		GAME.atlasIcons.getRegion(GAME.ICON_LINK_FACEBOOK).drawNow(_linkFacebook.graphics);
		_linkFacebook.t.x = _linkWWW.x+_linkWWW.width*0.8;
		_linkFacebook.t.y = _linkWWW.y+_linkWWW.height*0.8;
		addChild(_linkFacebook);

		_linkTwitter = new SpriteContainer();
		GAME.atlasIcons.getRegion(GAME.ICON_LINK_TWITTER).drawNow(_linkTwitter.graphics);
		_linkTwitter.t.x = _linkFacebook.x+_linkFacebook.width*0.8;
		_linkTwitter.t.y = _linkFacebook.y+_linkFacebook.height*0.8;
		addChild(_linkTwitter);


		_logo = new Gfx('logo.png');
		_logo.t.x = 1130*PLIK.pointFactor;
		_logo.t.y = 63*PLIK.pointFactor;
		addChild(_logo);

		var _creditsTitle = new TextAA(GAME.GAME_NAME,Std.int(120*PLIK.pointFactor),GAME.COLOR_WHITE);
		_creditsTitle.t.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
		_creditsTitle.t.x = 1950*PLIK.pointFactor;
		_creditsTitle.t.y = 415*PLIK.pointFactor;
	 	_creditsTitle.t.skewingX = -37.5;
	 	_creditsTitle.t.rotation = 26.4;
		addChild(_creditsTitle);

		var _creditsSubTitle = new TextAA('version '+GAME.GAME_VERSION+'\n' + GAME.GAME_BUILD + ' ' + GAME.GAME_PLATFORM,Std.int(54*PLIK.pointFactor),GAME.COLOR_WHITE);
		_creditsSubTitle.t.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
		_creditsSubTitle.t.x = 1800*PLIK.pointFactor;
		_creditsSubTitle.t.y = 495*PLIK.pointFactor;
	 	_creditsSubTitle.t.skewingX = -37.5;
	 	_creditsSubTitle.t.rotation = 26.4;
		addChild(_creditsSubTitle);

		backMenu = new IsoButtonMenu();
		backMenu.x = 1890*PLIK.pointFactor;
		backMenu.y = 880*PLIK.pointFactor;

		backMenu.addIsoButton("BACK",actionBack,"",0,GAME.atlasIcons.getRegion(GAME.ICON_BACK_DOWN),0,2,0);
		addChild(backMenu);

		super.initialize();
	}

	public override function start() {
		super.start(); // call resume
		PLIK.startMusic(GAME.MUSIC_TITLE);
	}

	public override function unload():Void {
		super.unload();

		_logo.destroyCache();
		_credits.destroyCache();

	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
		#if !mobile
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, backMenu.onMouseMove);
		#end
		backMenu.removeEventListener(MouseEvent.CLICK, backMenu.onClick);
		_linkWWW.removeEventListener(MouseEvent.CLICK, gotoWWW);
		_linkFacebook.removeEventListener(MouseEvent.CLICK, gotoFacebook);
		_linkTwitter.removeEventListener(MouseEvent.CLICK, gotoTwitter);
	}

	public override function resume():Void {
		super.resume();

		// HOOKERS ON
		#if !mobile
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, backMenu.onMouseMove);
		#end
		backMenu.addEventListener(MouseEvent.CLICK, backMenu.onClick);
		_linkWWW.addEventListener(MouseEvent.CLICK, gotoWWW);
		_linkFacebook.addEventListener(MouseEvent.CLICK, gotoFacebook);
		_linkTwitter.addEventListener(MouseEvent.CLICK, gotoTwitter);
	}

	private override function update(delta:Float):Void {
		if (parallax!=null) parallax.update(delta);
	}

	//########################################################################################
	//########################################################################################


	private function gotoFacebook(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_FACEBOOK);
	}

	private function gotoTwitter(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_TWITTER);
	}

	private function gotoWWW(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_WWW);
	}

	#if !mobile
	private function onKeyDown(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.SPACE)
			actionBack();
	}
	#end

	public function actionBack() {
		PLIK.changeScreen(new ScreenTitle(),PLIK.TRANSITION_SLIDE_UP);
	}
}
