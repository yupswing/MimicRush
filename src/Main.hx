package;

import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;

import motion.Actuate;

import com.akifox.plik.PLIK;
import com.akifox.plik.Gfx;
import com.akifox.plik.Utils;
import com.akifox.plik.Data;
import com.akifox.plik.TextAA;

import motion.Actuate;

import extension.share.Share;

class Main {
	var _logo:Bitmap;

	public function new () {
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, stageReady);
	}

	private function stageReady (event:Event):Void {
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, stageReady);

		// ------------------------------
		// CHECK ORIGIN ON FLASH
		#if (flash && !debug)
		if (!PLIK.checkOrigin("a"+"kif"+"ox\\.co"+"m/|dl\\.dro"+"pboxus"+"erconte"+"nt\\.c"+"om/u/68"+"3344/")) { // regexp ( akifox\.com/ | somethingelse\.com )
			//WRONG DOMAIN
			var _error = new TextAA("IF YOU WANT TO PLAY "+GAME.GAME_NAME+"\nPLEASE VISIT THE OFFICIAL PAGE\n" + GAME.LINK_WWW,36,GAME.COLOR_ORANGE,flash.text.TextFormatAlign.CENTER,GAME.FONT_DEFAULT);
			_error.x = Lib.current.stage.stageWidth/2-_error.width/2;
			_error.y = Lib.current.stage.stageHeight/2-_error.height/2;
			Lib.current.stage.addChild(_error);
			_error.addEventListener(MouseEvent.CLICK, function(_) { Utils.gotoWebsite(GAME.LINK_WWW); });
			Lib.current.stage.addEventListener(MouseEvent.CLICK, function(_) { Utils.gotoWebsite(GAME.LINK_WWW); });
			return;
		}
		#end

		#if debug
		trace('---- build active modes/ ----');
		#if app_demo trace('APP_DEMO'); #end
		#if app_submitscore trace('APP_SUBMITSCORE'); #end
		#if app_checkupdates trace('APP_CHECKUPDATES'); #end
		trace('---- /build active modes ----');
		#end

		// ------------------------------
		// "PRINT" LOADING SPLASH

    Lib.current.stage.color = GAME.GAME_BGCOLOR;
		_logo = new Bitmap(openfl.Assets.getBitmapData('assets/graphics/generic/loading.png',false));
		_logo.scaleX = _logo.scaleY = Lib.current.stage.stageWidth/_logo.width/2;
		_logo.smoothing = true;
		_logo.x = Lib.current.stage.stageWidth/2-_logo.width/2;
		_logo.y = Lib.current.stage.stageHeight/2-_logo.height/2;
		Lib.current.stage.addChild(_logo);

		// give a moment to show the preloader
		Actuate.timer(0.02).onComplete(initialize);
	}

	private function initialize(){
		// ------------------------------
		// SETUP AND PRELOAD

		#if app_checkupdates
		GAME.checkVersion();
		#end

		#if debug
		var _container = new Sprite();
		Lib.current.stage.addChild(_container);
		#else
		var _container = Lib.current.stage;
		#end

		PLIK.initialize(_container,GAME.GAME_PACKAGE);
		#if web //force resolution (for Gfx) to 1280 for web
		PLIK.setResolution(1280);
		#end

		//PLIK.setResolution(2560); //force resolution (TODO comment to deploy)

		PLIK.setDefaultFont(GAME.FONT_DEFAULT);

		// PREFERENCES
		PLIK.initPref();
		PLIK.setPrefField('effects',    Data.BOOL, true);
		PLIK.setPrefField('language',   Data.INT,  0);
		PLIK.setPrefField('first_run',  Data.INT,  1);

		// INITIALIZE GFX
		Gfx.setMultiResolutionBasePath("assets/graphics/"); // + RESOLUTION + "/" + filename

		// MANAGE MUSIC
		if (PLIK.getPref('music')) { // default state no music
			PLIK.toggleMusic();
		}
		// MANAGE SOUND
		if (PLIK.getPref('sound')) { // default state no sound
			PLIK.toggleSound();
		}
		// MANAGE FULLSCREEN
		if (PLIK.getPref('fullscreen')) { // default state no fullscreen
			PLIK.toggleFullscreen();
		}

		// EFFECTS DISABLE
		PLIK.transitionEnabled = PLIK.getPref('effects');

		// HIGHSCORE
		Data.loadData(GAME.HIGHSCORE_FILE);
		Data.setDataField(GAME.HIGHSCORE_FILE, 'high_score', Data.INT,      0);
		Data.setDataField(GAME.HIGHSCORE_FILE, 'last_score', Data.INT,      0);
		Data.setDataField(GAME.HIGHSCORE_FILE, 'statistics', Data.DYNAMIC,  null);

		// FIRST RUN
		if (PLIK.getPref('first_run')==1) {
			//FIRST RUN ONLY
			PLIK.setPref('first_run',0);

			GAME.isHelpMode = true;

			// get system language and set preference
			//var lang:String = extension.devicelang.DeviceLanguage.getLang();
			var lang:String = openfl.system.Capabilities.language;
			if (lang==null || lang=='null') lang = 'en';
			lang = lang.substr(0,2).toLowerCase();
			if (lang=='it') PLIK.setPref('language',1);
			PLIK.savePref();
		}

		// ------------------------------
		// ASSETS
        GAME.preloadAssets();

		// ------------------------------
		// INIT LANGUAGE
		GAME.loadLanguage();

		// ------------------------------
		// INIT SHARE EXTENSION
        Share.init(Share.FACEBOOK);
        Share.defaultURL = GAME.LINK_WWW;
        Share.defaultSubject = GAME.lang("$SHARE");
        Share.facebookRedirectURI = GAME.LINK_WWW;
        //Share.facebookAppID = '353897201467942'; //Facebook ID TODO

		// ------------------------------
        // DEBUG
       	#if debug
        var performance = new com.akifox.plik.debug.Performance(
        						PLIK.getFont(GAME.FONT_DEFAULT),
        						openfl.Assets.getBitmapData('assets/debug/akifox_logo_small.png',false),
        						true,
        						true);
        Lib.current.stage.addChild(performance);
        #end

		// ------------------------------
        // REMOVE AND DISPOSE LOADING SPLASH

		Lib.current.stage.removeChild(_logo);
		_logo.bitmapData.dispose();
		_logo=null;

		// ------------------------------
        // FIRST SCREEN

    #if !web
		PLIK.changeScreen(new ScreenSplash(),PLIK.TRANSITION_ALPHA);
		#else
		PLIK.changeScreen(new ScreenTitle(),PLIK.TRANSITION_ALPHA);
		#end

		Lib.current.stage.addEventListener (Event.RESIZE, onResize);
		//trace('END STARTUP');
	}

	private function onResize (event:Event):Void {
		PLIK.resize();
	}

}
