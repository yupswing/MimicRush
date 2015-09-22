package ;

import openfl.Lib;
import openfl.geom.Point;

import com.akifox.plik.SpriteContainer;
import com.akifox.plik.ShapeContainer;
import com.akifox.plik.PLIK;

import motion.Actuate;
import motion.easing.*;

class TileBoard extends SpriteContainer {

	var tiles:Array<Tile>;
	var ax:Array<Float>;
	var ay:Array<Float>;
	var aa:Array<Array<Int>> = [[0,2],[1,3],[2,4],[1,1],[2,2],[3,3],[2,0],[3,1],[4,2]];
	var refCircle:ShapeContainer;
	var refCircleCoords:Array<Array<Float>>;
		// tiles positions on the 5x5 grid
		//   . . . . .
		// .     7
		// .   4   8
		// . 1   5   9
		// .   2   6
		// .     3


    public override function toString():String {
        return '[GAME.TileBoard]';
    }

    public override function destroy() {
    	Actuate.stop(refCircle);
    	refCircle.destroy();
    	refCircle = null;

    	for (i in 0...tiles.length) {
    		tiles[i].destroy();
    		tiles[i] = null;
    	}

    	super.destroy();
    }
	
	public function new () {
		
		super ();
		
		init();
		
	}

	private function init():Void {

		tiles = new Array<Tile>();

		//  grid positions
		//  x
		//y 0. 1. 2. 3. 4.
		//  1.
		//  2.
		//  3.

		// tiles base position
		//   . . . . .
		// .     6
		// .   3   7
		// . 0   4   8
		// .   1   5
		// .     2

	 	var tw = Tile.tw;    //tile w
		var th = Tile.th;    //tile h
		var dx = Tile.dx;  //distance x
		var dy = Tile.dy;  //distance y

	    ax = [0,tw/2+dx,tw+2*dx,tw*1.5+3*dx,tw*2+4*dx]; // x coordinates
		ay = [0,th/2+dy,th+2*dy,th*1.5+3*dy,th*2+4*dy]; // y coordinates

		var pos:Array<Float>; //used for all positioning

		refCircleCoords = [[0,0],[0,0],[0,0],[0,0]];
		pos = this.getPosition(6);
		refCircleCoords[0] = [pos[0]+tw/2,pos[1]-th/5];
		pos = this.getPosition(0);
		refCircleCoords[1] = [pos[0]-tw/5,pos[1]+th/2];
		pos = this.getPosition(2);
		refCircleCoords[2] = [pos[0]+tw/2,pos[1]+th+th/5];
		pos = this.getPosition(8);
		refCircleCoords[3] = [pos[0]+tw+tw/5,pos[1]+th/2];

		pos = this.getPosition(6);

		refCircle = new ShapeContainer();
		refCircle.graphics.lineStyle(5*PLIK.pointFactor,GAME.COLOR_ORANGE,0.8);
		refCircle.graphics.beginFill(GAME.COLOR_ORANGE,1);
		refCircle.graphics.drawCircle(70*PLIK.pointFactor,50*PLIK.pointFactor,70/2.5*PLIK.pointFactor);
		refCircle.graphics.endFill();

		refCircle.t.setPivot(new Point(70*PLIK.pointFactor,70*PLIK.pointFactor));
		refCircle.t.x = refCircleCoords[0][0];
		refCircle.t.y = refCircleCoords[0][1];
		refCircle.alpha = 0;
		addChild(refCircle);
		//  4.

		for (i in 0...9) {
			pos = this.getPosition(i);
			tiles.push(new Tile(pos[0],pos[1],this));
			addChild(tiles[i]);
		}

	}

	public var isBoardRotating:Bool=false;
	public var isBoardRotated(get,never):Bool;
	private function get_isBoardRotated():Bool {
		return (currentRotation != 0);
	}
	private var currentRotation:Int = 0;

	public function rotate(position:Int):Void {

		if (isBoardRotating) return;

		if (position<0) position = 0;
		if (position>3) position = 3;

		var times:Int = 1;
		var verse:Bool = false;

		if (position !=0 && currentRotation != 0) return;

		switch(position) {
			case 0:
				switch (currentRotation) {
					case 1: verse = true; times = 1;
					case 2: verse = false; times = 2;
					case 3: verse = false; times = 1;
				}
			case 1: verse = false; times = 1;
			case 2: verse = false; times = 2;
			case 3: verse = true; times = 1;
		}

		isBoardRotating = true;

		var duration:Float = ScreenGame.TIMING_BOARD_ROTATION/times;
		rotate90(duration,verse);
		if (times>1) Actuate.timer(duration).onComplete(function() { rotate90(duration,verse); });
		Actuate.timer(ScreenGame.TIMING_BOARD_ROTATION+0.1).onComplete(function() {isBoardRotating = false;});
	}


	// tiles base position
	//   . . . . .
	// .     6
	// .   3   7
	// . 0   4   8
	// .   1   5
	// .     2

	private function rotate90(duration:Float,verse:Bool=true):Void{
		if (verse) { // --> rotation
			currentRotation--;
			if (currentRotation==-1) currentRotation = 3;

			this.shiftTiles([6,8,2,0],duration);
			this.shiftTiles([3,7,5,1],duration);

			Actuate.tween(refCircle.t,duration,{x:refCircleCoords[currentRotation][0],y:refCircleCoords[currentRotation][1]}).ease(Quad.easeOut);
		} else { 	 // <-- rotation
			currentRotation++;
			if (currentRotation==4) currentRotation = 0;

												  // 4 doesn't move
			this.shiftTiles([0,2,8,6],duration); // 0->2 2->8 8->6 6->0
			this.shiftTiles([1,5,7,3],duration); // 1->5 5->7 7->3 3->1

			Actuate.tween(refCircle.t,duration,{x:refCircleCoords[currentRotation][0],y:refCircleCoords[currentRotation][1]}).ease(Quad.easeOut);
		}
	}
	private function shiftTiles(tilesList:Array<Int>,duration:Float):Void {
		// shift position x,y of all tiles index in the List
		var startx = tiles[tilesList[0]].getPosx();
		var starty = tiles[tilesList[0]].getPosy();
		for (i in 0...tilesList.length-1) {
			tiles[tilesList[i]].moveme(tiles[tilesList[i+1]].getPosx(),tiles[tilesList[i+1]].getPosy(),duration);
		}
		tiles[tilesList[tilesList.length-1]].moveme(startx,starty,duration);
	}

	public function getPosition(index:Int):Array<Float>{
		return [ax[aa[index][0]],ay[aa[index][1]]];
	}

	public function hide():Void{
		Actuate.stop(this);
		alpha = 0.05;
	}

	public function show():Void{
		Actuate.tween(this,ScreenGame.TIMING_TILE_APPEAR,{alpha:1}).ease(Linear.easeNone);
	}

	public function appear():Void{
		alpha = 1;
		for (i in 0...tiles.length) {
		 	tiles[i].appear();
		}
		Actuate.tween(refCircle,ScreenGame.TIMING_TILE_APPEAR,{alpha:1});
	}

	public function select(index:Int):Void {
		tiles[index].highlight();
	}

	public function mistake(index:Int):Void {
		tiles[index].highlight(Tile.TileStatus.MISTAKE);
	}

	public function makeCopy():Void{
		for (i in 1...5) {
			tiles[Std.random(9)].highlight(Tile.TileStatus.SELECT,true);
		}
	}

	public function reset():Void{
		for (i in 0...tiles.length) {
		 	tiles[i].highlight(Tile.TileStatus.BLANK,true);
		}
	}

	public function getTileStatus(index:Int):Tile.TileStatus {
		return tiles[index].getStatus();
	}

	public function getTilesStatuses():Array<Tile.TileStatus> {
		var tilesArray:Array<Tile.TileStatus> = new Array<Tile.TileStatus>();
		for (i in 0...9) {
			tilesArray.push(this.getTileStatus(i));
		} 
		return tilesArray;
	}

}