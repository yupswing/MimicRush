
package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
#if !mobile
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
#end

import com.akifox.plik.PLIK;
import com.akifox.plik.Screen;
import com.akifox.plik.Data;
import com.akifox.plik.Gfx;
import com.akifox.plik.TextAA;
import com.akifox.plik.SpriteContainer;
import com.akifox.transform.Transformation;

import motion.Actuate;
import motion.easing.*;

class StatsBar extends SpriteContainer {

	var baseX:Float;
	var baseY:Float;
	var vertX:Float;
	var vertY:Float;
	var spanX:Float;
	var spanY:Float;
	var bspanX:Float;
	var bspanY:Float;
	var value:Float;
	var color:Int;
	var index:Int;

	var textValue:TextAA;

	public function new (index:Int, value:Float, color:Int,?score:Float=0,?hits:Float=0) {
		super();
		this.index = index;
		update(value, color,score,hits);
	}

	public function update(value:Float, color:Int,?score:Float=0,?hits:Float=0) {
		if (value<=0.01 && value>0) value = 0.01;
		if (value>1) value = 1;
		this.value = value;
		this.color = color;
		baseX = 150*PLIK.pointFactor;
		baseY = 650*PLIK.pointFactor;
		vertX = 900*PLIK.pointFactor;
		vertY = 450*PLIK.pointFactor;
		spanX = 60*PLIK.pointFactor;
		spanY = Std.int(spanX/2);
        bspanX = spanX*(index % 5 == 0?2:0.1);
        bspanY = spanY*(index % 5 == 0?2:0.1);
        if (index%5==0 && index>=5 && score>0) {
        	if (textValue!=null) {
        		removeChild(textValue);
        		textValue.destroy();
        		textValue = null;
        	}
        	textValue = new TextAA(Std.string(score),Std.int(80*PLIK.pointFactor),GAME.COLOR_LIGHT);
        	textValue.t.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
        	textValue.t.skewingX = -37.5;
        	textValue.t.rotation = 26.4;
        	textValue.t.x = baseX+index*spanX-40*PLIK.pointFactor;
        	textValue.t.y = baseY+index*spanY+30*PLIK.pointFactor;
        	addChild(textValue);
        }

		draw();
	}

	public function draw(rvalue:Float=0) {
		if (rvalue<=0.01) rvalue = 0.01;
		if (rvalue>1) rvalue = 1;
		rvalue *= value;

		graphics.clear();
       	graphics.lineStyle(30*PLIK.pointFactor, color, 0.75);
        graphics.moveTo(baseX+index*spanX,baseY+index*spanY);
        graphics.lineTo((baseX+vertX*rvalue+index*spanX),(baseY-vertY*rvalue+index*spanY));

       	graphics.lineStyle(30*PLIK.pointFactor, color, 0.2);
        graphics.moveTo(baseX+index*spanX,baseY+index*spanY);
        graphics.lineTo((baseX+vertX+index*spanX),(baseY-vertY+index*spanY));

	    graphics.lineStyle(5*PLIK.pointFactor, GAME.COLOR_ORANGE, 1);
	    graphics.moveTo(baseX-spanX/2+index*spanX,baseY+spanY/2+index*spanY);
	    graphics.lineTo(baseX-spanX/2+index*spanX-bspanX,baseY+spanY/2+index*spanY+bspanY);
	}

	public override function toString():String {
		return "[GAME.StatsBar <index "+index+">]";
	}

	public override function destroy() {
		if (textValue!=null) {
			removeChild(textValue);
			textValue.destroy();
			textValue = null;
		}
		super.destroy();
	}
}

class ScreenStatistics extends Screen
{

	public static inline var COLOR_HIGH_SCORE:Int = GAME.COLOR_RED;//0xff3800;
	public static inline var COLOR_LAST_SCORE:Int = GAME.COLOR_ORANGE;//0xffb500;
	public static inline var HOW_MANY_BARS:Int = 25;//0xffb500;

	private var backMenu:IsoButtonMenu;
	private var _loading:TextAA;

	private var bars:Array<StatsBar>;

	private var parallax:Parallax;

	public function new () {
		super();
		cycle = PLIK.getPref('effects');
		title = GAME.lang("$STATISTICS");
	}

	private var _highscore:Int = 0;
	private var _lastscore:Int = 0;

	public override function initialize():Void {
		_highscore = Data.readData(GAME.HIGHSCORE_FILE,'high_score');
		_lastscore = Data.readData(GAME.HIGHSCORE_FILE,'last_score');

		GAME.getLanguage();

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

		var _gametitle = new TextAA(GAME.lang("$STATISTICS_TITLE1"),Std.int(130*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 2171*PLIK.pointFactor;
		_gametitle.t.y = (200+10)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(GAME.lang("$STATISTICS_TITLE1"),Std.int(130*PLIK.pointFactor),GAME.COLOR_DARK);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 2171*PLIK.pointFactor;
		_gametitle.t.y = (200+5)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(GAME.lang("$STATISTICS_TITLE1"),Std.int(130*PLIK.pointFactor),GAME.COLOR_WHITE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 2171*PLIK.pointFactor;
		_gametitle.t.y = 200*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);


		var _gametitle = new TextAA(GAME.lang("$STATISTICS_TITLE2"),Std.int(200*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 1991*PLIK.pointFactor;
		_gametitle.t.y = (290+10)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(GAME.lang("$STATISTICS_TITLE2"),Std.int(200*PLIK.pointFactor),GAME.COLOR_DARK);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 1991*PLIK.pointFactor;
		_gametitle.t.y = (290+5)*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		var _gametitle = new TextAA(GAME.lang("$STATISTICS_TITLE2"),Std.int(200*PLIK.pointFactor),GAME.COLOR_WHITE);
		_gametitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_gametitle.t.x = 1991*PLIK.pointFactor;
		_gametitle.t.y = 290*PLIK.pointFactor;
	 	_gametitle.t.skewingX = -37.5;
	 	_gametitle.t.rotation = 26.4;
		addChild(_gametitle);

		// END

		var _scoreInfo = new TextAA(GAME.lang("$STATISTICS_SUBMISSIONS"),Std.int(60*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_scoreInfo.t.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
		_scoreInfo.t.x = 1700*PLIK.pointFactor;
		_scoreInfo.t.y = 1350*PLIK.pointFactor;
		_scoreInfo.t.skewingX = 37.5;
		_scoreInfo.t.rotation = -26.4;
		addChild(_scoreInfo);

		_scoreInfo = new TextAA(GAME.lang("$STATISTICS_SCORE"),Std.int(60*PLIK.pointFactor),GAME.COLOR_ORANGE);
		_scoreInfo.t.setAnchoredPivot(Transformation.ANCHOR_TOP_LEFT);
		_scoreInfo.t.x = 110*PLIK.pointFactor;
		_scoreInfo.t.y = 690*PLIK.pointFactor;
		_scoreInfo.t.skewingX = -37.5;
		_scoreInfo.t.rotation = 26.4;
		addChild(_scoreInfo);

		//=========

		var highscore:TextAA;

		var infolabelcenterx = 577;
		var infolabelcentery = 230;
		var infolabelspan = 70;
		var infolabelscorespan = 20;

		highscore = new TextAA(GAME.lang("$BEST_SCORE"),Std.int(80*PLIK.pointFactor),COLOR_HIGH_SCORE);
		highscore.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_RIGHT);
		highscore.t.x = (infolabelcenterx+infolabelspan)*PLIK.pointFactor;
		highscore.t.y = (infolabelcentery+infolabelspan/2)*PLIK.pointFactor;
	 	highscore.t.skewingX = 37.5;
	 	highscore.t.rotation = -26.4;
		addChild(highscore);

		highscore = new TextAA(Std.string(_highscore),Std.int(140*PLIK.pointFactor),GAME.COLOR_WHITE);
		highscore.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_LEFT);
		highscore.t.x = (infolabelcenterx+infolabelspan+infolabelscorespan)*PLIK.pointFactor;
		highscore.t.y = (infolabelcentery+infolabelspan/2-infolabelscorespan/2)*PLIK.pointFactor;
	 	highscore.t.skewingX = 37.5;
	 	highscore.t.rotation = -26.4;
		addChild(highscore);

		highscore = new TextAA(GAME.lang("$LAST_SCORE"),Std.int(80*PLIK.pointFactor),COLOR_LAST_SCORE);
		highscore.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_RIGHT);
		highscore.t.x = (infolabelcenterx-infolabelspan)*PLIK.pointFactor;
		highscore.t.y = (infolabelcentery-infolabelspan/2)*PLIK.pointFactor;
	 	highscore.t.skewingX = 37.5;
	 	highscore.t.rotation = -26.4;
		addChild(highscore);

		highscore = new TextAA(Std.string(_lastscore),Std.int(100*PLIK.pointFactor),GAME.COLOR_WHITE);
		highscore.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_LEFT);
		highscore.t.x = (infolabelcenterx-infolabelspan+infolabelscorespan)*PLIK.pointFactor;
		highscore.t.y = (infolabelcentery-infolabelspan/2-infolabelscorespan/2)*PLIK.pointFactor;
	 	highscore.t.skewingX = 37.5;
	 	highscore.t.rotation = -26.4;
		addChild(highscore);

		highscore = null;

		//=========

		_loading = new TextAA(GAME.lang("$LOADING_SCORE"),Std.int(100*PLIK.pointFactor),GAME.COLOR_WHITE,openfl.text.TextFormatAlign.CENTER);
		_loading.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_loading.t.x = rwidth/2;
		_loading.t.y = rheight/2;
	 	_loading.t.skewingX = -37.5;
	 	_loading.t.rotation = 26.4;
		addChild(_loading);

		// ***

		backMenu = new IsoButtonMenu();
		backMenu.x = 100*PLIK.pointFactor;
		backMenu.y = 880*PLIK.pointFactor;

		backMenu.addIsoButton("BACK",actionBack,"",0,GAME.atlasIcons.getRegion(GAME.ICON_BACK_RIGHT),0,2,0);
		addChild(backMenu);

		makeEmptyBars();

		super.initialize();
	}

	public override function start() {
		super.start(); // call resume
		PLIK.startMusic(GAME.MUSIC_TITLE);

		GAME.retriveScore(updateBars,makeError);
	}

	public override function unload():Void {
		super.unload();
	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
		#if !mobile
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, backMenu.onMouseMove);
		#end
		backMenu.removeEventListener(MouseEvent.CLICK, backMenu.onClick);
	}

	public override function resume():Void {
		super.resume();

		// HOOKERS ON
		#if !mobile
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, backMenu.onMouseMove);
		#end
		backMenu.addEventListener(MouseEvent.CLICK, backMenu.onClick);
	}

	private var skipped:Float=0;
	private var skip:Float=2;
	private var deltasum:Float=0;
	private var appearperc:Float=1;
	private var appearaddperc:Float=70;
	private var drawbarscycle:Bool=false; //makebars activate it
	public override function update(delta:Float){
		if (parallax!=null) parallax.update(delta);

		// cycle skipper
		deltasum+=delta;
        if (skipped < skip) {
			skipped++;
        	return;
        }
		// end cycle skipper

		if (drawbarscycle) {
			if (appearaddperc<0.1 || appearperc>1000) {
				drawbarscycle = false;
				appearperc = 1000;
			}

			for (barindex in 0...HOW_MANY_BARS) {
				bars[barindex].draw((appearperc)/1000);
			}
			appearaddperc*=0.936; //friction
			appearperc+=appearaddperc;
		}

		// cycle skipper
        skipped = 0;
		deltasum = 0;
		// end cycle skipper
	}

	//########################################################################################
	//########################################################################################

	private function makeEmptyBars() {
		bars = new Array<StatsBar>();
		var bar:StatsBar;
		for (i in 0...HOW_MANY_BARS) {
			bar = new StatsBar(i,0,GAME.COLOR_BLACK);
			bars.push(bar);
			if (!cycle) {
				bar.draw(0);
			}
			addChild(bar);
		}
	}

	public function updateBars() {
		var top_hits:Float = GAME.getScoreTopHits(); //top bar
		if (top_hits==0) {
			makeError();
			return;
		}
		var bar:StatsBar;
		removeChild(_loading);
		var hits:Array<Array<Float>> = GAME.getScoreTiers();
		var hit:Float;
		var color:Int;
		for (i in 0...HOW_MANY_BARS) {

			color = GAME.COLOR_WHITE;
			if (_lastscore >= hits[i][0] && _lastscore <= hits[i][1]) color = ScreenStatistics.COLOR_LAST_SCORE;
			if (_highscore >= hits[i][0] && _highscore <= hits[i][1]) color = ScreenStatistics.COLOR_HIGH_SCORE;

			hit = hits[i][2];
			bar = bars[i];
			bar.update(hit/top_hits,color,hits[i][0],hits[i][2]);
			if (!cycle) {
				bar.draw(1); //draw the bar if no cycle
			}
			addChild(bar);
			bar = null;
		}
		drawbarscycle = cycle; //cycle active
	}

	public function makeError() {

		removeChild(_loading);
		_loading.destroy();
		_loading = null;

		var _error = new TextAA(GAME.lang("$ERROR_SCORE"),Std.int(100*PLIK.pointFactor),GAME.COLOR_LIGHT,openfl.text.TextFormatAlign.CENTER);
		_error.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		_error.t.x = rwidth/2;
		_error.t.y = rheight/2;
	 	_error.t.skewingX = -37.5;
	 	_error.t.rotation = 26.4;
		addChild(_error);
	}

	//########################################################################################
	//########################################################################################


	#if !mobile
	private function onKeyDown(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.SPACE)
			actionBack();
	}
	#end

	private function actionBack() {
		PLIK.changeScreen(new ScreenTitle(),PLIK.TRANSITION_SLIDE_LEFT);
	}
}
