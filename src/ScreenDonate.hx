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
import com.akifox.plik.Utils;
import com.akifox.plik.Gfx;
import com.akifox.plik.TextAA;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.Screen;
import com.akifox.transform.Transformation;
import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.atlas.*;


class ScreenDonate extends Screen
{
	//private var background:Gfx;

	private var parallax:Parallax;
	private var logo:Gfx;

	private var atlasBadges:TextureAtlas;

	private var badgeAppStore:SpriteContainer;
	private var badgeGooglePlay:SpriteContainer;
	private var badgeOthers:SpriteContainer;
	private var desktopInfo:TextAA;

	public function new () {
		super();
		cycle = PLIK.getPref('effects');
		title = "Buy";
	}

	public override function initialize():Void {

		if (PLIK.getPref('effects')) {
			parallax = new Parallax(0.1);
			addChild(parallax);
		}

		atlasBadges = Gfx.getTextureAtlas('badges.xml');
		var badgesRegion = [atlasBadges.getRegion('ios.png'),
									  		atlasBadges.getRegion('android.png'),
									  		atlasBadges.getRegion('others.png')];

		logo = new Gfx('logo.png');
		logo.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_RIGHT);
		logo.t.x = rwidth/2-400*PLIK.pointFactor;
		logo.t.y = 200*PLIK.pointFactor;
		//logo.t.scaling = 0.5;
		addChild(logo);

		var titleText = new TextAA(GAME.GAME_NAME,Std.int(250*PLIK.pointFactor),GAME.COLOR_ORANGE);
		titleText.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_LEFT);
		titleText.t.x = rwidth/2-(400-100)*PLIK.pointFactor;
		titleText.t.y = 200*PLIK.pointFactor;
		addChild(titleText);

		var titleText = new TextAA(GAME.lang("$DESKTOP_INFO") ,Std.int(80*PLIK.pointFactor),GAME.COLOR_LIGHT,openfl.text.TextFormatAlign.CENTER);
		titleText.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		titleText.t.x = rwidth/2;
		titleText.t.y = 625*PLIK.pointFactor;
		addChild(titleText);

		var subtitleText = new TextAA(GAME.lang("$DESKTOP_SKIP") ,Std.int(80*PLIK.pointFactor),GAME.COLOR_ORANGE, openfl.text.TextFormatAlign.CENTER);
		subtitleText.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_RIGHT);
		subtitleText.t.x = rwidth-100*PLIK.pointFactor;
		subtitleText.t.y = rheight-100*PLIK.pointFactor;
		addChild(subtitleText);

		var subtitleText = new TextAA(GAME.lang("$DESKTOP_THANKS"),Std.int(50*PLIK.pointFactor),GAME.COLOR_LIGHT,openfl.text.TextFormatAlign.CENTER);
		subtitleText.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_LEFT);
		subtitleText.t.x = 100*PLIK.pointFactor;
		subtitleText.t.y = rheight-100*PLIK.pointFactor;
		addChild(subtitleText);

		badgeAppStore = new SpriteContainer();
		atlasBadges.getRegion("ios.png").drawNow(badgeAppStore.graphics);
		badgeAppStore.t.updateSize();
		badgeAppStore.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		badgeAppStore.t.x = rwidth/2-badgeAppStore.width-50*PLIK.pointFactor;
		badgeAppStore.t.y = 1050*PLIK.pointFactor;
		addChild(badgeAppStore);

		badgeGooglePlay = new SpriteContainer();
		atlasBadges.getRegion("android.png").drawNow(badgeGooglePlay.graphics);
		badgeGooglePlay.t.updateSize();
		badgeGooglePlay.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		badgeGooglePlay.t.x = rwidth/2;
		badgeGooglePlay.t.y = 1050*PLIK.pointFactor;
		addChild(badgeGooglePlay);


		badgeOthers = new SpriteContainer();
		atlasBadges.getRegion("others.png").drawNow(badgeOthers.graphics);
		badgeOthers.t.updateSize();
		badgeOthers.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		badgeOthers.t.x = rwidth/2+badgeOthers.width+50*PLIK.pointFactor;
		badgeOthers.t.y = 1050*PLIK.pointFactor;
		addChild(badgeOthers);

		super.initialize(); // init_super at the end
	}

	public override function unload():Void {
		super.unload();
		Gfx.removeTextureAtlas('badges.xml');
		logo.destroyCache();
	}

	public override function start() {
		PLIK.startMusic(GAME.MUSIC_TITLE,true);

		super.start();  // call resume
	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyPress);

		badgeAppStore.removeEventListener(MouseEvent.CLICK, gotoAppStore);
		badgeGooglePlay.removeEventListener(MouseEvent.CLICK, gotoGooglePlay);
		badgeOthers.removeEventListener(MouseEvent.CLICK, gotoDownloads);
		this.removeEventListener(MouseEvent.CLICK, gotoDonate);
	}

	public override function resume():Void {
		super.resume();

		// HOOKERS ON
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyPress);

		badgeAppStore.addEventListener(MouseEvent.CLICK, gotoAppStore);
		badgeGooglePlay.addEventListener(MouseEvent.CLICK, gotoGooglePlay);
		badgeOthers.addEventListener(MouseEvent.CLICK, gotoDownloads);
		this.addEventListener(MouseEvent.CLICK, gotoDonate);
	}

	private override function update(delta:Float):Void {
		if (parallax!=null) parallax.update(delta);
	}

	//########################################################################################
	//########################################################################################

	private function onKeyPress(event:KeyboardEvent) {
		if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.SPACE) actionBack();
	}

	private function actionBack() {
		PLIK.changeScreen(new ScreenTitle(),PLIK.TRANSITION_SLIDE_UP);
	}

	private function gotoAppStore(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_APPSTORE);
	}

	private function gotoGooglePlay(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_GOOGLEPLAY);
	}

	private function gotoDonate(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_DONATE);
	}

	private function gotoDownloads(event:MouseEvent):Void {
		Utils.gotoWebsite(GAME.LINK_DOWNLOAD);
	}

}
