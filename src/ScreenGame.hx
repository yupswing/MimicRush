package;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;
import openfl.geom.Point;

#if !mobile
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
#end

import motion.easing.*;
import motion.Actuate;

import com.akifox.plik.PLIK;
import com.akifox.plik.Utils;
import com.akifox.plik.Screen;
import com.akifox.plik.Data;
import com.akifox.plik.Sfx;
import com.akifox.plik.Gfx;
import com.akifox.plik.Drawing;
import com.akifox.plik.TextAA;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.ShapeContainer;
import com.akifox.transform.Transformation;

using StringTools;

class ScreenGame extends Screen {

	private var boardGame:TileBoard;
	private var boardCopy:TileBoard;

	//private var _pendingCheck:Bool = false;
	private var _isNewHighscore:Bool = false;

	private static inline var SUBMIT_MIN_SCORE:Int = 30; // mimimum score to be submitted
	private var _currentHighscore:Int; // current local highscore

	// GAMEPLAY

	private static inline var START_TIMER_SECONDS:Int = 60; // Seconds of game

	// INTERFACE

	private var background:Gfx;
	private var timerLabel:TextAA;
	private var timerCircle:ShapeContainer;
	private var scoreLabel:TextAA;
	private var scoreCircle:ShapeContainer;
	private var highscoreLabel:TextAA;
	private var pauseMenu:IsoButtonMenu;
	private var parallax:Parallax;
	private var screenOverlayMask:OverlayMask;
	private var _isOverlayMaskOnStage:Bool = false;
	private var screenOverlay:Overlay;
	private var _isOverlayOnStage:Bool = false;

	private var _ismousedown = false; 			// used by the touch system
	private var _acceptTileInput:Bool = false; 	// block input on tiles between rounds
	private var _lastTileMouseMove = -1; 		//avoid double clicks on same tile while moving
	private var _isGameActive:Bool = false; 	// the screen is active and going (accept input)

	private var timerCircleColor:Int; // will be changed and rendered on the update cycle
	private static inline var CIRCLE_RADIUS = 75;
	private static inline var CIRCLE_THICKNESS = 30;

	private var _currentScore:Int = 0; 		// the current Score
	private var _currentTimer:Float=0;		// the current Timer (seconds remaining)

	// SCREEN PHASES
	private var _isGameStarted:Bool=false;	// the screen is not booting anymore
	private var _isGameOver:Bool=false;	// the scree is unloading
	private var _isGameResuming:Bool=false;	// the screen was on hold and resuming
	private var _resumingPhase:Int=0;		// used in Resuming Cycle

	// HELP CONTROLS
	private var _isHelping:Bool = false;	// helping overlay is active
	private var _helpMode:Bool = false; 	// activated globally via GAME.isHelpMode
	// these elements got unchecked when displayed (no double help)
	private var _helpPP:Map<String,Bool> = ["score+time" => false, //activated by new_game
										    "introduction"=>true,
										    "highscore"=>true,
										    "newhighscore"=>true,
										    "mistake"=>true,
										    "rotation"=>true];

	// TIMING

	private var _timeoutBlipSeconds = 5; // from how many seconds it has to blip (it will be never reset)

	//startup
	private static inline var TIMING_LABELS_APPEAR:Float = 1; // labels appear at startup

	public static inline var TIMING_NEWHIGHSCORE_APPEAR:Float = 2;
	public static inline var TIMING_OVERLAY_APPEAR:Float = 1;
	public static inline var TIMING_OVERLAY_STAY:Float = 1;
	public static inline var TIMING_NEWROUND_GAP:Float = 0.35;
	public static inline var TIMING_NEWROUND_DELAY:Float = TIMING_NEWROUND_GAP-TIMING_TILE_HIGHLIGHT-0.05;
	public static inline var TIMING_CIRCLE_POP:Float = 0.3; // circle popping time on related value change
	public static inline var SCALE_CIRCLE_BASE:Float = 1; // circle base scale
	public static inline var SCALE_CIRCLE_MEDIUM:Float = 1.1; // circle medium scale (small + or -)
	public static inline var SCALE_CIRCLE_BIG:Float = 1.3; // circle medium scale (big + or -)

	public static inline var TIMING_TILE_APPEAR:Float = 1.2;
	public static inline var TIMING_TILE_APPEAR_DELAY:Float = 0.5;
	public static inline var TIMING_TILE_HIGHLIGHT:Float = 0.2;
	public static inline var TIMING_BOARD_ROTATION:Float = 0.8;

	public static inline var TIMING_ROTATION_LONG_BASE:Int = 10;
	public static inline var TIMING_ROTATION_LONG_RAND:Int = 5;
	public static inline var TIMING_ROTATION_SHORT_BASE:Int = 5;
	public static inline var TIMING_ROTATION_SHORT_RAND:Int = 3;

	public static inline var POINTS_SCORE_BOARDCLEAR:Int = 5;
	public static inline var POINTS_TIME_BOARDCLEAR:Int = 1;
	public static inline var POINTS_SCORE_TILEMISTAKE:Int = 0;
	public static inline var POINTS_TIME_TILEMISTAKE:Int = -1;
	public static inline var POINTS_SCORE_TILERIGHT:Int = 1;
	public static inline var POINTS_TIME_TILERIGHT:Int = 0;

	// CYCLE SKIPPERS
	private static inline var SKIP_FRAME:Float=5; // how many frame to be skipped in the update
	private var _frameSkipped:Float=0;

	// CYCLE COUNTERS
	private var _cycleBaseDelta:Float=0;
	private var _cycleRotationDelta:Float=0;

	private var _nextRotationSeconds:Float = 0;


	public function new () {
		super();
		cycle = true;
		holdable = true;
		title = "MRGame " + Math.round(Math.random()*1000);
	}

	public override function initialize():Void {

		_currentHighscore = Data.readData(GAME.HIGHSCORE_FILE,'high_score');
		if (_currentHighscore<SUBMIT_MIN_SCORE) _currentHighscore = SUBMIT_MIN_SCORE;

		_helpMode = GAME.isHelpMode;
		GAME.isHelpMode = false;

		screenOverlay = new Overlay();

		Tile.tileRegions = [GAME.atlasTiles.getRegion('tile_white.png'),
							GAME.atlasTiles.getRegion('tile_yellow.png'),
							GAME.atlasTiles.getRegion('tile_red.png')];

		background = new Gfx ("bg.png");
		background.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		background.t.x = rwidth/2;
		background.t.y = rheight/2;
    addChild(background);

		timerLabel = new TextAA(Std.string(START_TIMER_SECONDS),Std.int(180*PLIK.pointFactor),GAME.COLOR_LIGHT);
		timerLabel.t.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_RIGHT);
		timerLabel.t.x = 182*PLIK.pointFactor;
		timerLabel.t.y = 413*PLIK.pointFactor;
	 	timerLabel.t.skewingX = -37.5;
	 	timerLabel.t.rotation = 26.4;
	 	timerLabel.alpha = 0;
		addChild(timerLabel);

		timerCircleColor = GAME.COLOR_LIGHT;
		timerCircle = new ShapeContainer();
		drawTimerCircle();
		timerCircle.updateTransformation();
		timerCircle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
	 	timerCircle.t.skewingX = -37.5;
	 	timerCircle.t.rotation = 26.4;
		timerCircle.t.x = timerLabel.t.x+230*PLIK.pointFactor;
		timerCircle.t.y = timerLabel.t.y+35*PLIK.pointFactor;
		timerCircle.t.scaling = SCALE_CIRCLE_BASE;
		timerCircle.alpha = 0;
		addChild(timerCircle);

		scoreLabel = new TextAA("0",Std.int(180*PLIK.pointFactor),GAME.COLOR_LIGHT);
		scoreLabel.t.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_RIGHT);
		scoreLabel.t.x = 434*PLIK.pointFactor;
		scoreLabel.t.y = 287*PLIK.pointFactor;
	 	scoreLabel.t.skewingX = -37.5;
	 	scoreLabel.t.rotation = 26.4;
	 	scoreLabel.alpha = 0;
		addChild(scoreLabel);

		highscoreLabel = new TextAA(GAME.lang("$NEW_HIGHSCORE"),Std.int(60*PLIK.pointFactor),GAME.COLOR_ORANGE);
		highscoreLabel.t.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_RIGHT);
		highscoreLabel.t.x = scoreLabel.t.x+440*PLIK.pointFactor;
		highscoreLabel.t.y = scoreLabel.t.y+10*PLIK.pointFactor;
	 	highscoreLabel.t.skewingX = -37.5;
	 	highscoreLabel.t.rotation = 26.4;
	 	highscoreLabel.alpha = 0;
	 	//addChild(highscoreLabel); //will be added only if necessary

		scoreCircle = new ShapeContainer();
		drawScoreCircle();
		scoreCircle.updateTransformation();
		scoreCircle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
	 	scoreCircle.t.skewingX = -37.5;
	 	scoreCircle.t.rotation = 26.4;
		scoreCircle.t.x = scoreLabel.t.x+230*PLIK.pointFactor;
		scoreCircle.t.y = scoreLabel.t.y+35*PLIK.pointFactor;
		scoreCircle.t.scaling = SCALE_CIRCLE_BASE;
		scoreCircle.alpha = 0;
		addChild(scoreCircle);

		boardGame = new TileBoard();
		boardGame.x = 126*PLIK.pointFactor;
		boardGame.y = 356*PLIK.pointFactor;
		addChild(boardGame);

		boardCopy = new TileBoard();
		boardCopy.x = 1468*PLIK.pointFactor;
		boardCopy.y = 104*PLIK.pointFactor;
		boardCopy.scaleX = 0.5;
		boardCopy.scaleY = 0.5;
		addChild(boardCopy);

		pauseMenu = new IsoButtonMenu();
		pauseMenu.x = 1890*PLIK.pointFactor;
		pauseMenu.y = 880*PLIK.pointFactor;
		pauseMenu.addIsoButton("PAUSE",actionPause,"",0,GAME.atlasIcons.getRegion(GAME.ICON_PAUSE),0,2,0);
		pauseMenu.setAlphaBase(0.5);
		addChild(pauseMenu);

		updateEffects();

		super.initialize();
	}

	public override function resize():Void {
		super.resize();  // call resume
		if (_isOverlayMaskOnStage) screenOverlayMask.redraw();
	}


	public override function start():Void {
		super.start();  // call resume
	}

	public override function unload():Void {
		super.unload();
		// Already done a RESET on game over
		//Actuate.stop(Actuate.timer); // destroy timer to free objects that are having tweens timer based
		if (!_isOverlayOnStage) {
			removeChild(screenOverlay);
			screenOverlay.destroy();
			screenOverlay = null;
		}
		if (_isNewHighscore) {
			removeChild(highscoreLabel);
			highscoreLabel.destroy();
			highscoreLabel = null;
		}
	}

	public override function hold():Void {

		if (_isHelping) return;

		boardGame.hide();
		boardCopy.hide();

		if (!_isGameOver) {
			screenOverlay.setText("",GAME.lang("$PAUSED"));
			if (!_isOverlayOnStage) {
				addChild(screenOverlay);
				_isOverlayOnStage = true;
			}
		}

		_isGameActive = false;
		_ismousedown = false;
		hookersOff();

		super.hold();

	}


	public override function resume():Void {

		if (_isHelping) return;

		PLIK.startMusic(GAME.MUSIC_GAME);

		if (!_isGameOver) _isGameResuming = true;
		_resumingPhase = 0;

		super.resume();
	}

	private function hookersOn():Void {
		if (PLIK.multitouchOn) {
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onMouseUp);
			boardGame.addEventListener(TouchEvent.TOUCH_MOVE, onMouseMove);
			boardGame.addEventListener(TouchEvent.TOUCH_BEGIN, onMouseDown);
		} else {
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			boardGame.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			boardGame.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		#if !mobile
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, pauseMenu.onMouseMove);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		#end
		pauseMenu.addEventListener(MouseEvent.CLICK, pauseMenu.onClick);
	}

	private function hookersOff():Void {
		if (PLIK.multitouchOn) {
			Lib.current.stage.removeEventListener(TouchEvent.TOUCH_END, onMouseUp);
			boardGame.removeEventListener(TouchEvent.TOUCH_MOVE, onMouseMove);
			boardGame.removeEventListener(TouchEvent.TOUCH_BEGIN, onMouseDown);
		} else {
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			boardGame.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			boardGame.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		#if !mobile
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, pauseMenu.onMouseMove);
		Lib.current.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyDown);
		#end
		pauseMenu.removeEventListener(MouseEvent.CLICK, pauseMenu.onClick);
	}

	private override function update(delta:Float):Void {
		if (parallax!=null) parallax.update(delta);
		if (_isGameActive) {

			//normal cycle
			_cycleBaseDelta+=delta;
			_cycleRotationDelta+=delta;
	        if (_frameSkipped == SKIP_FRAME) {
	            _frameSkipped = 0;

	            // START timer cycle
				setTimer(-_cycleBaseDelta,false,true);
				if (_currentTimer <=1) gameOver();
				_cycleBaseDelta = 0;
				// END

//				trace(_nextRotationSeconds,_cycleRotationDelta);
				// START rotation cycle
				if (_cycleRotationDelta>_nextRotationSeconds) {
					if (boardCopy.isBoardRotated) {
						//to be reset
						boardCopy.rotate(0); // go back to 0
						setNextRotation(true); //reset rotation long
					} else {
						//to be rotated
						boardCopy.rotate(Math.round(Math.random()*2+1)); // go to 1, 2 or 3
						setNextRotation(false); //set next rotation short
					}
					_cycleRotationDelta = 0; //reset delta

					if (_helpMode) helpCall("rotation");

				}
				// END
	        }
	        _frameSkipped++;

       	} else if (_isGameResuming) {
			_cycleBaseDelta+=delta;
			resuming();
       	}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	private function newGame():Void {
		// called by the last booting phase
		//_pendingCheck = false;
		_cycleBaseDelta = 0;
		_cycleRotationDelta = 0;

		setTimer(START_TIMER_SECONDS,true); // set the countdown
		setNextRotation(true);  			// set the next rotation long
		setScore(0,true);					// set the score to 0
		newRound();							// start a round

		if (_helpMode) helpCall("introduction");
	}


	private function newRound():Void {
		_acceptTileInput = false;
		Sfx.fastPlay(GAME.SOUND_ROUND);
		Actuate.timer(TIMING_NEWROUND_DELAY).onComplete(function() {
			boardGame.reset();
			boardCopy.reset();
		});
		Actuate.timer(TIMING_NEWROUND_GAP).onComplete (function() {
			boardCopy.makeCopy();
			_acceptTileInput = true;
		});

		if (_helpMode) helpCall("score+time");
	}

	private function newHighscore() {
		if (_isNewHighscore) return;

		Sfx.fastPlay(GAME.SOUND_HIGHSCORE);
		addChild(highscoreLabel);
		Actuate.tween(highscoreLabel,TIMING_NEWHIGHSCORE_APPEAR,{alpha:1});
		_isNewHighscore = true;


		if (_helpMode) helpCall("newhighscore");
	}

    private function actionPause() {
	 	PLIK.holdScreen(new ScreenTitle(),PLIK.TRANSITION_SLIDE_DOWN);
	}

	private function checkBoard():Void {
		//pendingcheck avoid double check (since it follows a timer to show an animation)
		//if (!_pendingCheck) return;
		//_pendingCheck = false;
		if (Utils.isArrayEqual(boardGame.getTilesStatuses(),boardCopy.getTilesStatuses())) {
			setScore(POINTS_SCORE_BOARDCLEAR);
			setTimer(POINTS_TIME_BOARDCLEAR);
			newRound();
		}
	}

	private function setNextRotation(long:Bool) {
		// value = range[BASE to BASE+RAND]
		_nextRotationSeconds = Math.random()*
								(long?TIMING_ROTATION_LONG_RAND:TIMING_ROTATION_SHORT_RAND)+
								(long?TIMING_ROTATION_LONG_BASE:TIMING_ROTATION_SHORT_BASE);
	}

	private function gameOver() {
		if (_isGameOver) return;

		// game over
		_isGameOver = true;
		_isGameActive = false;
		hold();
		if (_currentScore<=0) _currentScore = 0;
		setTimer(0,true);

		Sfx.fastPlay(GAME.SOUND_GAMEOVER);

		// show score
		if (!_isOverlayOnStage) {
			addChild(screenOverlay);
			_isOverlayOnStage = true;
		}
		screenOverlay.alpha = 0;
		screenOverlay.setText(GAME.lang((_isNewHighscore?"$NEW_HIGHSCORE":"$SCORE")),Std.string(_currentScore));
		Actuate.tween(screenOverlay,TIMING_OVERLAY_APPEAR,{alpha:1}).onComplete(_postGameOver);
	}

	// GAME OVER second phase
	// divided because the score submission often can cause some delays
	// so the overlay screen is shown before (if the user waits, waits on something)
	private function _postGameOver() {

		#if app_submitscore
		// submit online highscore
		if (_currentScore > SUBMIT_MIN_SCORE) GAME.submitScore(_currentScore);
		#end

		// set local highscore
		if (_currentScore > Data.readData(GAME.HIGHSCORE_FILE,'high_score'))
			Data.writeData(GAME.HIGHSCORE_FILE,'high_score',_currentScore);
		Data.writeData(GAME.HIGHSCORE_FILE,'last_score',_currentScore);
		Data.saveData(GAME.HIGHSCORE_FILE);

		Actuate.reset(); //Finally able to reset everything! NOTHING ON HOLD

		Actuate.timer(TIMING_OVERLAY_STAY).onComplete(function() {
	 		PLIK.changeScreen(new ScreenStatistics(),PLIK.TRANSITION_SLIDE_DOWN);
		});
		// THIS IS THE END
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	private function setScore(value:Int,?absolute:Bool=false) {
		if (absolute) {
			_currentScore=value;
		} else{
			if (value==0) return; //relative change, 0 dosn't change anything
			_currentScore+=value;
			highlightScore((value>0?GAME.COLOR_GREEN:GAME.COLOR_RED),(Math.abs(value)==1?SCALE_CIRCLE_MEDIUM:SCALE_CIRCLE_BIG));
		}
		if (_currentScore<0) _currentScore = 0; //no negative score

		if (_helpMode && _currentScore>_currentHighscore-10) helpCall("highscore");

		// CHECK if new highscore
		if (_currentScore>_currentHighscore) newHighscore();

		// CHANGE THE TEXT
		scoreLabel.setText(Std.string(_currentScore));
	}

	private function setTimer(value:Float,?absolute:Bool=false,?fromcycle=false) {
		if (absolute) {
			_currentTimer=value;
		} else{
			if (value==0) return; //relative change, 0 dosn't change anything
			_currentTimer+=value;
			if (!fromcycle) highlightTimer((value>0?GAME.COLOR_GREEN:GAME.COLOR_RED),(Math.abs(value)==1?SCALE_CIRCLE_MEDIUM:SCALE_CIRCLE_BIG));
		}

		/*timerLabel.setText((''+Std.int(Std.int(_currentTimer)/60)).lpad('0',2) + ':' +
						  ((''+Std.int(_currentTimer)%60).lpad('0',2) +
						  '.'+Std.int((_currentTimer-Std.int(_currentTimer))*10)));*/

		// CHANGE THE LABEL
		timerLabel.setText(Std.string(Std.int(_currentTimer)));

		// REDRAW THE CIRCLE
		drawTimerCircle();

		// COUNTDOWN SOUND
		if (Std.int(_currentTimer)==_timeoutBlipSeconds) {
			Sfx.fastPlay(GAME.SOUND_COUNTDOWN1);
			_timeoutBlipSeconds--;
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	private function highlightTimer(color:Int,scale:Float) {
		Actuate.stop(timerCircle);
		timerCircle.t.scaling = SCALE_CIRCLE_BASE;
		timerCircleColor = color;
		Actuate.tween(timerCircle.t,TIMING_CIRCLE_POP,{scaling:scale}).ease(Quad.easeInOut).reverse().onComplete(function() {
			timerCircleColor = GAME.COLOR_LIGHT;
		});
	}

	private function highlightScore(color:Int,scale:Float) {
		Actuate.stop(scoreCircle);
		scoreCircle.t.scaling = SCALE_CIRCLE_BASE;
		drawScoreCircle(color);
		Actuate.tween(scoreCircle.t,TIMING_CIRCLE_POP,{scaling:scale}).ease(Quad.easeInOut).reverse().onComplete(function() {
			drawScoreCircle();
		});
	}


	//########################################################################################
	//########################################################################################

	// var to avoid allocations
	private var _dtc_full:Float;

	private function drawTimerCircle(){
		timerCircle.graphics.clear();

		_dtc_full = (_currentTimer-1)/START_TIMER_SECONDS; //-1 to show the circle better
		if (_dtc_full>1) _dtc_full = 1;
		if (_dtc_full<0) _dtc_full = 0;

		timerCircle.graphics.lineStyle(CIRCLE_THICKNESS/2*PLIK.pointFactor,GAME.COLOR_LIGHT,1);
		timerCircle.graphics.moveTo(CIRCLE_RADIUS*1.35*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor);
		timerCircle.graphics.lineTo(CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor);
		timerCircle.graphics.lineTo(CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*0.55*PLIK.pointFactor);

		timerCircle.graphics.lineStyle(CIRCLE_THICKNESS*PLIK.pointFactor,timerCircleColor,0.5);
		timerCircle.graphics.drawCircle(CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor);
		if (_dtc_full>0) {

		 	timerCircle.graphics.lineStyle(CIRCLE_THICKNESS*PLIK.pointFactor,timerCircleColor,1);
		 	Drawing.circleSegment(timerCircle.graphics,
		 						  CIRCLE_RADIUS*PLIK.pointFactor,
		 						  CIRCLE_RADIUS*PLIK.pointFactor,
		 						  -90*PLIK.DEG2RAD,
		 						  (360*_dtc_full-90)*PLIK.DEG2RAD,
		 						  CIRCLE_RADIUS*PLIK.pointFactor);
		}
	}

	private function drawScoreCircle(?color:Int=GAME.COLOR_LIGHT){

		var _dsc_full:Float = _currentScore/_currentHighscore;

		scoreCircle.graphics.clear();
		scoreCircle.graphics.lineStyle(CIRCLE_THICKNESS*PLIK.pointFactor,(_dsc_full>1?color:GAME.COLOR_LIGHT),(_isNewHighscore?1:0.5));
		scoreCircle.graphics.drawCircle(CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor);

		scoreCircle.graphics.lineStyle(5*PLIK.pointFactor,(_isNewHighscore?GAME.COLOR_ORANGE:color),0.8);
		scoreCircle.graphics.beginFill((_isNewHighscore?GAME.COLOR_ORANGE:color),1);
		scoreCircle.graphics.drawCircle(CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS*PLIK.pointFactor,CIRCLE_RADIUS/2.5*PLIK.pointFactor);
		scoreCircle.graphics.endFill();

		if (!_isNewHighscore) {
		 	scoreCircle.graphics.lineStyle(CIRCLE_THICKNESS*PLIK.pointFactor,color,1);
		 	Drawing.circleSegment(scoreCircle.graphics,
		 						  CIRCLE_RADIUS*PLIK.pointFactor,
		 						  CIRCLE_RADIUS*PLIK.pointFactor,
		 						  -90*PLIK.DEG2RAD,
		 						  (360*_dsc_full-90)*PLIK.DEG2RAD,
		 						  CIRCLE_RADIUS*PLIK.pointFactor);
		 }
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////

	private function select(index:Int):Void {
		if (!_acceptTileInput) return;
		var status:Tile.TileStatus = boardGame.getTileStatus(index);
		var statusCopy:Tile.TileStatus = boardCopy.getTileStatus(index);
		if (status == Tile.TileStatus.BLANK) {
			if (statusCopy == Tile.TileStatus.SELECT) {
				// GOT IT
				Sfx.fastPlay(GAME.SOUND_RIGHT);
				boardGame.select(index);
				//_pendingCheck = true;
				// CHECK the board to see if it is completed
				checkBoard();
				setScore(POINTS_SCORE_TILERIGHT);
				setTimer(POINTS_TIME_TILERIGHT);
			} else {
				// MISTAKE
				Sfx.fastPlay(GAME.SOUND_MISTAKE);
				boardGame.mistake(index);
				setScore(POINTS_SCORE_TILEMISTAKE);
				setTimer(POINTS_TIME_TILEMISTAKE);

				if (_helpMode) helpCall("mistake",index);
			}
		}
	}

	#if !mobile
	private function onKeyDown(event:KeyboardEvent):Void {
		if (event.keyCode == Keyboard.ESCAPE || event.keyCode == Keyboard.SPACE) actionPause();
		if (!_isGameActive) return;

		switch (event.keyCode) {
			case Keyboard.Z: this.select(0);
			case Keyboard.X: this.select(1);
			case Keyboard.C: this.select(2);
			case Keyboard.A: this.select(3);
			case Keyboard.S: this.select(4);
			case Keyboard.D: this.select(5);
			case Keyboard.Q: this.select(6);
			case Keyboard.W: this.select(7);
			case Keyboard.E: this.select(8);
		}

	}
	#end

	// shared var to avoid lots of allocations
	private var _tempTile:Int = 0;

	private function onMouseDown (event:Dynamic):Void {
		if (!_isGameActive) return;
		if (!PLIK.multitouchOn) _ismousedown = true;
		_tempTile = getTileFromEvent(event);
		if (_tempTile > -1) {
			this.select(_tempTile);
			return;
		}

	}

	private function onMouseMove (event:Dynamic):Void {
		if (!_isGameActive) return;
		if (!PLIK.multitouchOn && !_ismousedown) return;
		_tempTile = getTileFromEvent(event);

		//avoid double clicks on same tile while moving
		if (_lastTileMouseMove == _tempTile) return;
		_lastTileMouseMove = _tempTile;

		if (_tempTile > -1) {
			this.select(_tempTile);
			return;
		}

	}

	private function onMouseUp (event:Dynamic):Void {
		if (!_isGameActive) return;
		if (!PLIK.multitouchOn) _ismousedown = false;
	}


	// shared var to avoid lots of allocations
	private var _tfe_x:Float;
	private var _tfe_y:Float;
	private var _tfe_a:Float;
	private var _tfe_b:Float;
	private var _tfe_tx:Int;
	private var _tfe_ty:Int;

	private function getTileFromEvent(event:Dynamic):Int {
		// determine x,y using Board as reference 0,0
		_tfe_x = (event.stageX - this.x) / this.currentScale - boardGame.x + Tile.dx;
		_tfe_y = (event.stageY - this.y) / this.currentScale - boardGame.y + Tile.dy;
		if (_tfe_x==0) _tfe_x=0.01; // no division by zero
		if (_tfe_y==0) _tfe_y=0.01;


		// rotate mouseclick x,y coordinates to determine board coordinates x',y'
		// 1,2 = board coordinates x',y'
		//    .  .  .  .  .
		// .       2,0
		// .    1,0   2,1
		// . 0,0   1,1   2,2
		// .    0,1   1,2
		// .       0,2
		_tfe_a = Tile.tw+2*Tile.dx; // tile width
		_tfe_b = Tile.th+2*Tile.dy;   // tile height (has to be half width)
		// var c = b/2;   // half tile height
		// var x1 = b*_tfe_x + b*y - a; //give board coordinates x',y' and get mouse x,y
		// var y1 = - c*_tfe_x + c*y;
		_tfe_tx = Math.round(1/_tfe_a*_tfe_x - 1/_tfe_b*_tfe_y + 1);   // give mouse x,y and get board coordinates x',y'
		_tfe_ty = Math.round(1/_tfe_a*_tfe_x + 1/_tfe_b*_tfe_y + 1)-3; // -3 to adjust y offset

		//ignore outer box
		if (_tfe_tx >= 0 && _tfe_tx <= 2 && _tfe_ty >= 0 && _tfe_ty <= 2) {
			//use coordinates to get the tile
			//tx*3+ty is a number between 0 and 8 (9 total tiles)
			return _tfe_tx*3+_tfe_ty;
		}
		return -1;

	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////


	// handle the passage between the hold and complete resume
	// with an overlay
	// (could be the boot or the pause, depends by _isGameStarted)
	private function resuming() {
		if (_resumingPhase == 0) {
			_cycleBaseDelta = 0; _resumingPhase = 1;
			if (!_isOverlayOnStage) {
				screenOverlay.setText("","");
				addChild(screenOverlay);
				_isOverlayOnStage = true;
			}
		}
		if (_cycleBaseDelta>0.2 && _resumingPhase==1) {
			_cycleBaseDelta = 0; _resumingPhase++;
			screenOverlay.setText("","3");
			Sfx.fastPlay(GAME.SOUND_COUNTDOWN1);
		}
		if (_cycleBaseDelta>0.3 && _resumingPhase==2) {
			_cycleBaseDelta = 0; _resumingPhase++;
			screenOverlay.setText(GAME.lang("$READY"),"2");
			if (_isGameStarted) {
				boardGame.show();
				boardCopy.show();
			} else {
				boardGame.appear();
				boardCopy.appear();
				Actuate.tween(timerLabel,TIMING_LABELS_APPEAR,{alpha:1});
				Actuate.tween(timerCircle,TIMING_LABELS_APPEAR,{alpha:1});
				Actuate.tween(scoreLabel,TIMING_LABELS_APPEAR,{alpha:1});
				Actuate.tween(scoreCircle,TIMING_LABELS_APPEAR,{alpha:1});
			}
			Sfx.fastPlay(GAME.SOUND_COUNTDOWN1);
		}
		if (_cycleBaseDelta>0.3 && _resumingPhase==3) {
			_cycleBaseDelta = 0; _resumingPhase++;
			screenOverlay.setText(GAME.lang("$SET"),"1");
			Sfx.fastPlay(GAME.SOUND_COUNTDOWN1);
		}
		if (_cycleBaseDelta>0.3 && _resumingPhase==4) {
			_cycleBaseDelta = 0; _resumingPhase++;
			screenOverlay.setText("",GAME.lang("$GO"));
			Sfx.fastPlay(GAME.SOUND_COUNTDOWN2);
		}
		if (_cycleBaseDelta>0.2 && _resumingPhase==5) {
			_cycleBaseDelta = 0; _resumingPhase++;
			removeChild(screenOverlay);
			_isOverlayOnStage = false;
			_isGameResuming = false;
			_isGameActive = true;
			hookersOn();
			if (!_isGameStarted) {
				_isGameStarted = true;
				newGame();
			}
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	// CALLED BY SCREENOPTIONS

	public function updateEffects():Void{
		// PLIK.getPref('language')
		if (PLIK.getPref('effects')) {
			// what to do if active
			parallax = new Parallax(0.2);
			addChild(parallax);
			setChildIndex(parallax,0);
		} else if (parallax!=null){
			// what to do if unactive
			removeChild(parallax);
			parallax.destroy();
			parallax = null;
		}
	}

	////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	// HELP MANAGEMENT

	private function helpGo(ovmp:Array<OverlayMask.OverlayMaskPanel>) {
		if (_isHelping) return;
		_isHelping = true;
		screenOverlayMask = new OverlayMask(this,ovmp,helpBack);
		addChild(screenOverlayMask);
		_isOverlayMaskOnStage = true;

		// HOLD THE GAME
		_ismousedown = false;
		_isGameActive = false;
		hookersOff();
		super.hold();
		// END
	}

	public function helpBack() {
		if (!_isHelping) return;
		Actuate.resumeAll();
		_isHelping = false;
		removeChild(screenOverlayMask);
		screenOverlayMask = null;
		_isOverlayMaskOnStage = false;

		// RESUME THE GAME
		_isGameActive = true;
		hookersOn();
		super.resume();
		// END

	}

	private function helpCall(what:String,?param:Dynamic=null) {
		//if (!_helpMode) return;
		if (!_helpPP[what]) return;
		_helpPP[what] = false; // DONE: only one call for every help

		switch (what) {
			case "introduction":
				_helpPP["score+time"] = true; //activate score+time introduction at first round finished
				helpGo([helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_0"),
									   'black'),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_1")),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_2"),
									   'boardGame'),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_3")),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_4"),
									   'boardCopy'),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_5"),
									   'full'),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_6")),
						helpMakeCircle(GAME.lang("$HELP_INTRODUCTION_7"))
					   ]);
			case "score+time":
				helpGo([helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_0"),
									   'boardGame'),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_1"),
									   'score'),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_2")),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_3"),
									   'full'),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_4"),
									   'timer'),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_5")),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_6"),
									   'full'),
						helpMakeCircle(GAME.lang("$HELP_FIRSTROUND_7"))
					   ]);
			case "rotation":
				helpGo([helpMakeCircle(GAME.lang("$HELP_ROTATION_0"),
						 	           'boardCopy'),
						helpMakeCircle(GAME.lang("$HELP_ROTATION_1")),
						helpMakeCircle(GAME.lang("$HELP_ROTATION_2")),
						helpMakeCircle(GAME.lang("$HELP_ROTATION_3"),
									   'orangeDot'),
						helpMakeCircle(GAME.lang("$HELP_ROTATION_4"),
									   'boardCopy'),
						helpMakeCircle(GAME.lang("$HELP_ROTATION_5"),
									   "full"),
						helpMakeCircle(GAME.lang("$HELP_ROTATION_6"))
					   ]);
			case "mistake":
				helpGo([helpMakeCircle(GAME.lang("$HELP_MISTAKE_0"),
									   'tile'+param),
						helpMakeCircle(GAME.lang("$HELP_MISTAKE_1")),
						helpMakeCircle(GAME.lang("$HELP_MISTAKE_2"),
									   'timer'),
						helpMakeCircle(GAME.lang("$HELP_MISTAKE_3"),
									   'full'),
						helpMakeCircle(GAME.lang("$HELP_MISTAKE_4"))
					   ]);
			case "highscore":
				helpGo([helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_0"),
									   'black'),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_1"),
									   'score'),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_2")),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_3")),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_4"),
									   'timer'),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_5"),
									   "full"),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_6")),
						helpMakeCircle(GAME.lang("$HELP_HIGHSCORE_7"))
					   ]);
			case "newhighscore":
				helpGo([helpMakeCircle(GAME.lang("$HELP_NEWHIGHSCORE_0"),
									   'score'),
						helpMakeCircle(GAME.lang("$HELP_NEWHIGHSCORE_1"),
									   "full"),
						helpMakeCircle(GAME.lang("$HELP_NEWHIGHSCORE_2")),
						helpMakeCircle(GAME.lang("$HELP_NEWHIGHSCORE_3")),
						helpMakeCircle(GAME.lang("$HELP_NEWHIGHSCORE_4"))
					   ]);
		}
	}

	private function helpMakeCircle(_text:String,?target:String="NULL"):OverlayMask.OverlayMaskPanel {
		var _draw = false;
		var _x:Float = 0;
		var _y:Float = 0;
		var _width:Float = 0;
		var _height:Float = 0;
		var object:Dynamic = null;

		var c_x:Float = 0;
		var c_y:Float = 0;
		var c_width:Float = 0;
		var c_height:Float = 0;

		switch (target) {
			case 'black':
				_draw = true;
				_x = 0;
				_y = 0;
				_width = 0;
				_height = 0;
			case 'boardGame':
				object = boardGame;
				c_y = -100*PLIK.pointFactor;
				c_width = 200*PLIK.pointFactor;
				c_height = 100*PLIK.pointFactor;

			case 'boardCopy':
				object = boardCopy;
				c_width = 300*PLIK.pointFactor;
				c_height = 150*PLIK.pointFactor;
				c_y = -30*PLIK.pointFactor;

			case 'timer':
				object = timerLabel;
				c_x = -300*PLIK.pointFactor;
				c_y = 0;//*PLIK.pointFactor;
				_width = 600*PLIK.pointFactor;
				_height = 300*PLIK.pointFactor;
				c_width = 100*PLIK.pointFactor;
				c_height = 50*PLIK.pointFactor;

			case 'score':
				object = scoreLabel;
				c_x = -300*PLIK.pointFactor;
				c_y = -30*PLIK.pointFactor;
				_width = 600*PLIK.pointFactor;
				_height = 300*PLIK.pointFactor;
				c_width = 100*PLIK.pointFactor;
				c_height = 50*PLIK.pointFactor;

			case 'orangeDot':
				_draw = true;
				_width = 400*PLIK.pointFactor;
				_height = 200*PLIK.pointFactor;
				_x = boardGame.x+boardGame.width/2;
				_y = boardGame.y-75*PLIK.pointFactor;

			case 'full':
				_draw = true;
				_width = rwidth;
				_height = rheight;
				_x = _width/2;
				_y = _height/2;
				c_width = 600*PLIK.pointFactor;
				c_height = 300*PLIK.pointFactor;

		}

		if (target.substring(0,4)=='tile') {
			_draw = true;
			_width = Tile.tw;
			_height = Tile.th;
			_x = boardGame.x+_width/2;
			_y = boardGame.y+_height/2;

			var tilepos = boardGame.getPosition(Std.parseInt(target.substr(4,1)));
			c_x = tilepos[0];
			c_y = tilepos[1];
			c_width = 100*PLIK.pointFactor;
			c_height = 50*PLIK.pointFactor;
		}

		if (object != null) {
			_draw = true;
			if (_width<=0)  _width = Reflect.getProperty(object,"width");
			if (_height<=0) _height = Reflect.getProperty(object,"height");
			_x = Reflect.getProperty(object,"x")+_width/2;
			_y = Reflect.getProperty(object,"y")+_height/2;
		}
		return {text:_text,draw:_draw,mask_x:_x+c_x,mask_y:_y+c_y,mask_width:_width+c_width,mask_height:_height+c_height};
	}
}
