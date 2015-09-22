package ;

import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.Screen;
import com.akifox.asynchttp.*;
import motion.Actuate;
import motion.easing.*;
import com.akifox.plik.PLIK;
import com.akifox.plik.Data;
import com.akifox.plik.Gfx;
import com.akifox.plik.Sfx;
import openfl.events.*;
import haxe.Timer;

typedef OnlineStats = {
    var top_score:Float;
    var bottom_score:Float;
    var top_hits:Float;
    var tiers:Array<Array<Float>>;
}

class GAME
{

	///////////////////////////////////////////////////////////////////////////
	// Game Info

	public static inline var GAME_NAME = "Mimic Rush" ;
	public static inline var GAME_PACKAGE = "com.akifox.mimicrush" ;
	public static inline var GAME_BUILD = CompileTime.readFile("Export/.build");
	public static inline var GAME_BUILD_DATE = CompileTime.buildDateString();
	public static inline var GAME_VERSION = "1.2.0"; //TODEPLOY
	public static inline var GAME_PLATFORM =
	#if debug "dev"
  #elseif flash "swf"
  #elseif ios "ios"
  #elseif android	"and"
	#elseif mac "mac"
  #elseif windows "win"
  #elseif linux "lnx"
  #elseif web "web"
  #else "---"
  #end;
	public static inline var GAME_BGCOLOR = 0x242424 ;


	///////////////////////////////////////////////////////////////////////////
	// Atlases (faster retrive than asking to cache system)

	public static var atlasIcons:TextureAtlas=null;
	public static var atlasTiles:TextureAtlas=null;
	public static var atlasParallax:TextureAtlas=null;

	public static var isHelpMode:Bool = false;

	///////////////////////////////////////////////////////////////////////////
	// URLs and FILEs

	public static inline var HIGHSCORE_FILE = "highscore";
	private static inline var URL_SERVICE_STATS_SUBMIT = "http://akifox.com/mimicrush/service/stats/submit/";
	private static inline var URL_SERVICE_STATS_GET = "http://akifox.com/mimicrush/service/stats/get/";
	private static inline var URL_SERVICE_VERSION = "http://akifox.com/mimicrush/service/version/";

	public static inline var LINK_UPDATE = 	     "http://akifox.com/mimicrush/get/";
	public static inline var LINK_DONATE = 	     "http://akifox.com/donate/";

	public static inline var LINK_FACEBOOK =     "http://www.facebook.com/pages/Akifox-Studio-Games/1557970471141900";
	public static inline var LINK_TWITTER =      "http://twitter.com/AkifoxStudio";
	public static inline var LINK_WWW = 	       "http://akifox.com/mimicrush/";

  #if app_donations
	public static inline var LINK_APPSTORE =     "http://akifox.com/mimicrush/get/?p=ios";
	public static inline var LINK_GOOGLEPLAY =   "http://akifox.com/mimicrush/get/?p=android";
	public static inline var LINK_DOWNLOAD =     "http://akifox.com/mimicrush/get/";
  #end

	///////////////////////////////////////////////////////////////////////////
	// COLORS

	public static inline var FONT_DEFAULT:String = "assets/fonts/Square.ttf";

	public static inline var COLOR_WHITE:Int = 	0xFFFFFF;
	public static inline var COLOR_LIGHT:Int = 	0xDCDCDC;
	public static inline var COLOR_BLACK:Int = 	0x000000;
	public static inline var COLOR_DARK:Int = 	0x242424;
	public static inline var COLOR_ORANGE:Int = 0xffb500;
	public static inline var COLOR_RED:Int = 	0xcf2d00;
	public static inline var COLOR_GREEN:Int = 	0x98ca00;

	///////////////////////////////////////////////////////////////////////////
	// SOUNDS

	// game
	public static inline var SOUND_ROUND:String = 		"assets/sound/new";
	public static inline var SOUND_RIGHT:String = 		"assets/sound/click";
	public static inline var SOUND_MISTAKE:String = 	"assets/sound/mistake";
	public static inline var SOUND_COUNTDOWN1:String = 	"assets/sound/countdown1";
	public static inline var SOUND_COUNTDOWN2:String = 	"assets/sound/countdown2";
	public static inline var SOUND_GAMEOVER:String = 	"assets/sound/gameover";
	public static inline var SOUND_HIGHSCORE:String = 	"assets/sound/highscore";

	// ui
	public static inline var SOUND_CLICK:String = 		"assets/sound/click";
	public static inline var SOUND_FOCUS:String = 		"assets/sound/focus";

	// overlay
	public static inline var SOUND_OVERLAY_LONG:String = "assets/sound/overlay_long";
	public static inline var SOUND_OVERLAY_SHORT:String ="assets/sound/overlay_short";

	public static var SOUND_ALL =   ["assets/sound/new","assets/sound/click","assets/sound/mistake",
									 "assets/sound/countdown1","assets/sound/countdown2","assets/sound/gameover",
									 "assets/sound/highscore","assets/sound/focus","assets/sound/overlay_long",
									 "assets/sound/overlay_short"];

	///////////////////////////////////////////////////////////////////////////
	// MUSIC
	public static inline var MUSIC_GAME:String = 		"assets/music/wearetheresistors";
	public static inline var MUSIC_TITLE:String = 	"assets/music/chibininja";

	///////////////////////////////////////////////////////////////////////////
	// atlasIcon REGIONS

	public static inline var ICON_ARROW_LEFT = 'arrow-l.png';
	public static inline var ICON_ARROW_RIGHT = 'arrow-r.png';
	public static inline var ICON_BACK_DOWN = 'back-d.png';
	public static inline var ICON_BACK_LEFT = 'back-l.png';
	public static inline var ICON_BACK_RIGHT = 'back-r.png';
	public static inline var ICON_COG = 'cog.png';
	public static inline var ICON_INFO = 'credits.png';
	public static inline var ICON_MAGIC = 'effects.png';
	public static inline var ICON_MAGIC_NO = 'effects-no.png';
	public static inline var ICON_HELP = 'help.png';
	public static inline var ICON_MOBILE = 'mobile.png';
	public static inline var ICON_LINK_FACEBOOK = 'link_facebook.png';
	public static inline var ICON_LINK_TWITTER = 'link_twitter.png';
	public static inline var ICON_LINK_HOME = 'link_home.png';
	public static inline var ICON_MUSIC = 'music.png';
	public static inline var ICON_MUSIC_NO = 'music-no.png';
	public static inline var ICON_PAUSE = 'pause.png';
	public static inline var ICON_PLAY = 'play.png';
	public static inline var ICON_QUIT = 'quit.png';
	public static inline var ICON_SHARE = 'share.png';
	public static inline var ICON_RESTART = 'restart.png';
	public static inline var ICON_SCREEN = 'screen.png';
	public static inline var ICON_SCREEN_NO = 'screen-no.png';
	public static inline var ICON_SOUND = 'sound.png';
	public static inline var ICON_SOUND_NO = 'sound-no.png';
	public static inline var ICON_TROPHY = 'trophy.png' ;
	public static inline var ICON_LANGUAGE = 'language.png';

	///////////////////////////////////////////////////////////////////////////
	// MULTILANGUAGE vars and getter

	private static var tongue:firetongue.FireTongue;
	private static var languages = ["en-US","it-IT"];
	public static inline var LANGUAGES_COUNT = 2;

	private static var currentLanguage = 0;

	public static function getLanguage():Int {
		return currentLanguage;
	}

	public static function loadLanguage() {
		currentLanguage = PLIK.getPref('language');

		if (currentLanguage<0)
				currentLanguage = 0;
		if (currentLanguage>LANGUAGES_COUNT-1)
				currentLanguage = LANGUAGES_COUNT-1;

		GAME.tongue = new firetongue.FireTongue();
		GAME.tongue.init(languages[currentLanguage],null,true,true);
	}

	public static function lang(value:String):String {
		return GAME.tongue.get(value);
	}

	///////////////////////////////////////////////////////////////////////////
	// MEMORY MANAGEMENT

	public static function preloadAssets():Void {

		PLIK.preloadFont(GAME.FONT_DEFAULT);

		if (GAME.atlasIcons==null) GAME.atlasIcons = Gfx.getTextureAtlas('icons.xml');
		if (GAME.atlasTiles==null) GAME.atlasTiles = Gfx.getTextureAtlas('tiles.xml');

		Gfx.preloadBitmap("bg.png");

		if (PLIK.getPref('effects')) {
			//trace('load effects');
			//see also ScreenOptions.actionEffects<Void->Void>
			if (GAME.atlasParallax==null) GAME.atlasParallax = Gfx.getTextureAtlas('bg_parallax.xml');
		}

		if (PLIK.getPref('music')) {
			//trace('load music');
			Sfx.preloadSound(GAME.MUSIC_GAME,true);
			Sfx.preloadSound(GAME.MUSIC_TITLE,true);
		}

		if (PLIK.getPref('sound')) {
			//trace('load sound');
			for (sound in SOUND_ALL) {
				Sfx.preloadSound(sound);
			}
		}

	}

	public static function unloadMusicAssets():Void {
		// very expensive to reload
		// will not do anything
		/*Sfx.removeSound(GAME.MUSIC_TITLE);
		Sfx.removeSound(GAME.MUSIC_GAME);*/
	}

	public static function unloadSoundAssets():Void {
		for (sound in SOUND_ALL) {
			Sfx.removeSound(sound);
		}
	}

	public static function unloadEffectsAssets():Void {
		//trace('unload effects');
		Gfx.removeTextureAtlas('bg_parallax.xml');
		GAME.atlasParallax = null;
	}

	///////////////////////////////////////////////////////////////////////////
	// HIGHSCORE MANAGEMENT

	#if app_submitscore

	private static function stc(seed:Int):Array<String>{
    // #TODEPLOY Put here the real stc function
		// This is a dummy function
		// It is the only part of the game kept private to avoid
		// fake score submissions
		return ['','0',''];
	}

	@:allow(ScreenGame)
	private static function submitScore(score:Int) {
		onlineStatsTime = 0; //invalidate score data to force reload on request

		var r = stc(score);
		var apiURL = URL_SERVICE_STATS_SUBMIT;
		var data = "s=" + r[0] + "&t=" + r[1] + "&c=" + r[2];
		//trace(apiURL);

		var request =  new HttpRequest({
      url:apiURL,
			callback :function(response:HttpResponse){
			    var json:Dynamic = response.toJson();
		    	if (json == null || Std.parseInt(json.e) > 0) {
		    		//error
            #if debug
				    trace('SUBMIT SCORE ERROR: ' + json);
            #end
		    	}
			},
      callbackError : function(response:HttpResponse) {
        #if debug
        trace('SUBMIT SCORE ERROR: ' + response.status);
        #end
      }
    });
		request.method = HttpMethod.POST;
		request.content = data;
		request.send(); //async send
	}

	#end // app_submitscore

	private static var onlineStats:OnlineStats=null;
	private static var onlineStatsTime:Float=0;

	@:allow(ScreenStatistics)
	private static function getScoreTopHits():Float {
		if (onlineStats==null) return 0;
		return onlineStats.top_hits;
	}
	@:allow(ScreenStatistics)
	private static function getScoreTiers():Array<Array<Float>> {
		if (onlineStats==null) return null;
		return onlineStats.tiers;
	}

	@:allow(ScreenStatistics)
	private static function retriveScore(done:Void->Void,error:Void->Void) {
		// > 0 needed as "first run" (==0 is setup variable)
		if (onlineStatsTime > 0 && onlineStatsTime>Timer.stamp()-600) { // restore 10 minutes cache
			done();
			return;
		}

		var apiURL = URL_SERVICE_STATS_GET;

		var request = new HttpRequest({
           url : apiURL,
			callback : function(response:HttpResponse) {
                    var freshData:Bool = false;
                    if (!response.isOK) {
                      retriveScoreFallback(done,error);
                      return;
                    }

                    var json:Dynamic = response.toJson();
                    if (json == null || Std.int(json.e) > 0) {
                      #if debug
                      trace('GET SCORE ERROR: ' + json);
                      #end
                      retriveScoreFallback(done,error);
                      return;
                    } else {
                      GAME.onlineStats = json.c;
                      freshData = true;
                    }

                    if (freshData) {
                      // save cache on file
                      Data.writeData(GAME.HIGHSCORE_FILE,'statistics',onlineStats);
                      Data.saveData(GAME.HIGHSCORE_FILE);
                    }

                    GAME.onlineStatsTime = Timer.stamp();
                    if (Type.getClass(PLIK.getScene())==ScreenStatistics) {
                      done();
                    }
                 }
    });

		request.send(); //async send

	}

	private static function retriveScoreFallback(done:Void->Void,error:Void->Void) {
		onlineStatsTime = 0; // disable cache to force reload every time
    	if (onlineStats==null) {
    		// try to load from highscore cache file
    		try {
    			onlineStats = Data.readData(GAME.HIGHSCORE_FILE,'statistics');
    		}
    	}
    	if (Type.getClass(PLIK.getScene())==ScreenStatistics) {
			if (onlineStats!=null) {
				done(); //fallback on cached data
			} else {
				error();
			}
		}
	}



	///////////////////////////////////////////////////////////////////////////

	#if app_checkupdates
	public static var onlineVersion:String = GAME_VERSION;
	public static var showUpdate:Bool = false;

	@:allow(Main)
	private static function checkVersion() {

		var apiURL = URL_SERVICE_VERSION;

		var request = new HttpRequest({
      url:apiURL,
			callback:function(response:HttpResponse) {
          				if (!response.isOK) return;

          				var json:Dynamic = response.toJson();
          		    	if (json == null || Std.int(json.e) > 0) return;

          		    	GAME.onlineVersion = Std.string(json.c.version);
          		    	if (GAME.onlineVersion != GAME_VERSION) GAME.showUpdate = true;

          			}
    });

		request.send(); //async send

	}
	#end // app_checkupdates
}
