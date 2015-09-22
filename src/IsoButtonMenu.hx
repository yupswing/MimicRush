package ;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.Lib;

import com.akifox.plik.PLIK;
import com.akifox.plik.Screen;
import com.akifox.plik.Sfx;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.atlas.AtlasRegion;

class IsoButtonMenu extends SpriteContainer {

	private var _buttons:Array<IsoButton>;
	private static var _spany:Int = 90;
	private var currentScene:Screen;

	public function setAlphaOver(alpha:Float) {
		for (el in _buttons) {
			el.alpha_over = alpha;
			el.drawIsoButton();
		}
	}

	public function setAlphaBase(alpha:Float) {
		for (el in _buttons) {
			el.alpha_base = alpha;
			el.drawIsoButton();
		}
	}
    public override function toString():String {
        return '[GAME.IsoButtonMenu]';
    }

    public override function destroy() {
    	for (i in 0..._buttons.length) {
    		_buttons[i].destroy();
    		_buttons[i] = null;
    	}

    	super.destroy();
    }

	public function new(){
		super(false); //no transformations

		_buttons = new Array<IsoButton>();

/*		// DEBUG CLICK
        var xx = Std.int(2500*PLIK.pointFactor);
        var yy = Std.int(1500*PLIK.pointFactor);
        var _spany = 145*PLIK.pointFactor;

        var test = new BitmapData(xx,yy,true,0);

		var a = Tile.tw+2*Tile.dx; // tile width
		var b = Tile.th+2*Tile.dy;   // tile height (has to be half width)

		var rx = 0;
		var ry = 0;

		test.lock();
		var color = [[0xFFFF0000,0xFF00FF00,0xFFFF0000,0xFF00FF00],
					 [0xFF00FF00,0xFFFF0000,0xFF00FF00,0xFFFF0000],
					 [0xFFFF0000,0xFF00FF00,0xFFFF0000,0xFF00FF00],
					 [0xFF00FF00,0xFFFF0000,0xFF00FF00,0xFFFF0000]];
        for (x in 0...xx) {
        	for (y in 0...yy) {
        		rx=x;//Std.int(x+Tile.dx/2);
        		ry=y;//Std.int(y+Tile.dy/2);
				// var c = b/2;   // half tile height
				// var x1 = b*x + b*y - a; //give board coordinates x',y' and get mouse x,y
				// var y1 = - c*x + c*y;
				var tx = Math.round(1/a*rx - 1/b*ry + 1);   // give mouse x,y and get board coordinates x',y'
				var ty = Math.round(1/a*rx + 1/b*ry + 1)-3; // -3 to adjust y offset

				//ignore outer box
				if (tx >= 0 && tx <= 2 && ty >= 0 && ty <= 3) {
					//use coordinates to get the tile
					//tx*3+ty is a number between 0 and 8 (9 total tiles)
					test.setPixel32(rx-Tile.dx,ry-Tile.dy,color[tx][ty]);
				}
        	}
        }
        test.unlock();

        var testBitmap = new Bitmap(test);
        testBitmap.x = this.x;
        testBitmap.y = this.y-_spany;

        addChild(testBitmap);*/
	}

	public function addIsoButton(id:String,action:Void->Void,text:String,size:Int,iconRegion:AtlasRegion,posx:Int,posy:Int,type:Int) {

		var baseQuietRegion = GAME.atlasTiles.getRegion('longtile_white.png');
		var baseOverRegion = GAME.atlasTiles.getRegion('longtile_yellow.png');
		if (type==0) {
			baseQuietRegion = GAME.atlasTiles.getRegion('tile_white.png');
			baseOverRegion = GAME.atlasTiles.getRegion('tile_yellow.png');
		}

		var button = new IsoButton(id,action,text,size,
						baseQuietRegion,
						baseOverRegion,
						iconRegion);
		var pos = calcCoord(posx,posy);
		button.x = button.rx = pos[0];
		button.y = button.ry = pos[1] - (button._height-Tile.th/2);

		var at:Array<Array<Array<Int>>> = [for (x in 0...6) [for (y in 0...7) [0,0]]];
		at[0][2] = [0,0];
		at[1][3] = [0,1];
		at[2][4] = [0,2];
		at[3][5] = [0,3];
		at[4][6] = [0,4];
		at[1][1] = [1,0];
		at[2][2] = [1,1];
		at[3][3] = [1,2];
		at[4][4] = [1,3];
		at[5][5] = [1,4];
		at[2][0] = [2,0];
		at[3][1] = [2,1];
		at[4][2] = [2,2];
		at[5][3] = [2,3];
		at[4][2] = [2,2];
		at[5][3] = [2,3];

		var xx = at[posx][posy][0];
		var yy = at[posx][posy][1];

		var startpos = [xx,yy];
		var endpos = [xx,yy];
		if (type==1) endpos = [xx+2,yy];

		button.startpos = startpos;
		button.endpos = endpos;

		_buttons.push(button);
		addChild(button);
		button = null;
	}

	private static function calcCoord(xpos:Float,ypos:Float) {
	 	var tw = Tile.tw;    //tile w
		var th = Tile.th;    //tile h
		var dx = Tile.dx;  //distance x
		var dy = Tile.dy;  //distance y

		// + 0 1 2 3 4 5
		// 0     .
		// 1   .   .
		// 2 .   .   .
		// 3   .   .   .
		// 4     .   .
		// 5       .   .
		// 6         .

	    //var ax = [0,tw/2+dx,tw+2*dx,tw*1.5+3*dx,tw*2+4*dx,tw*2.5+5*dx]; // x coordinates
		//var ay = [0,th/2+dy,th+2*dy,th*1.5+3*dy,th*2+4*dy,th*2.5+5*dy]; // y coordinates

		return [tw*0.5*xpos+xpos*dx,th*0.5*ypos+ypos*dy];
	}

	public function setText(id:String,value:String) {
		var button = getIsoButtonFromId(id);
		if (button==null) return;
		button.setText(value);
	}

	public function setIcon(id:String,iconRegion:AtlasRegion) {
		var button = getIsoButtonFromId(id);
		if (button==null) return;
		button.setIcon(iconRegion);
	}

	public function disable(id:String) {
		var button = getIsoButtonFromId(id);
		if (button==null) return;
		button.disabled = true;
	}

	public function enable(id:String) {
		var button = getIsoButtonFromId(id);
		if (button==null) return;
		button.disabled = false;
	}

	private function getIsoButton(posx:Int,posy:Int) {

		for (el in _buttons) {
			if (posx >= el.startpos[0] && posx <= el.endpos[0] &&
				posy >= el.startpos[1] && posy <= el.endpos[1]) {
				//this is the button
				return el;
			}
		}
		return null;
	}

	public function getIsoButtonFromId(id:String) {
		for (el in _buttons) {
			if (el.id==id) {
				return el;
			}
		}
		return null;
	}

	private function getIsoButtonFromCoords(x:Float,y:Float) {

		//TODO better boundaries based on actual buttons
        var xx = 2500*PLIK.pointFactor;
        var yy = 1500*PLIK.pointFactor;
        var _spany = 145*PLIK.pointFactor;
		if (x>this.x && x<this.x+xx && y>this.y-100 && y<this.y-100+yy) {
			var rx = x-this.x+Tile.dx;
			var ry = y-(this.y-_spany)+Tile.dy;
			var a = Tile.tw+2*Tile.dx; // tile width
			var b = Tile.th+2*Tile.dy;   // tile height (has to be half width)
			//inside the menu square
			var tx = Math.round(1/a*rx - 1/b*ry + 1);   // give mouse x,y and get board coordinates x',y'
			var ty = Math.round(1/a*rx + 1/b*ry + 1)-3; // -3 to adjust y offset

			//ignore outer box
			if (tx >= 0 && tx <= 2 && ty >= 0 && ty <= 4) {
				return getIsoButton(tx,ty);
			}
		}
		return null;
	}

	private var currentButton:IsoButton = null;


	public function onClick (event:Dynamic):Void {
		currentScene = PLIK.getScene();

		var x = (event.stageX - currentScene.x) / currentScene.currentScale;
		var y = (event.stageY - currentScene.y) / currentScene.currentScale;

		var button = getIsoButtonFromCoords(x,y);
		if (button!=null) {
			if (button.click()) Sfx.fastPlay(GAME.SOUND_CLICK);
		}
	}

	public function onMouseMove (event:MouseEvent):Void {
		currentScene = PLIK.getScene();

		var x = (event.stageX - currentScene.x) / currentScene.currentScale;
		var y = (event.stageY - currentScene.y) / currentScene.currentScale;

		var button = getIsoButtonFromCoords(x,y);

		if (button==currentButton) return; //no action

		if (currentButton!=null) currentButton.mouseOut();
		if (button!=null) {
			if (button.mouseIn()) Sfx.fastPlay(GAME.SOUND_FOCUS);
		}

		currentButton = button;
	}
}
