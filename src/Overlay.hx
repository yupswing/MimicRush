
package ;

import com.akifox.plik.PLIK;
import com.akifox.plik.TextAA;
import com.akifox.plik.Gfx;
import com.akifox.transform.Transformation;
import com.akifox.plik.SpriteContainer;

import openfl.display.Sprite;
import motion.Actuate;


class Overlay extends SpriteContainer {

	private var label:TextAA;
	private var labelTitle:TextAA;
	private var background:Gfx;

	public function new () {
		super ();

		background = new Gfx('bg_overlay.png');
		background.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		background.t.x = PLIK.resolutionX/2;
		background.t.y = PLIK.resolutionY/2;
		background.alpha=0.9;
		background.t.scaling = 2;
		addChild(background);

		label = new TextAA("",Std.int(200*PLIK.pointFactor),GAME.COLOR_WHITE);
		label.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		label.t.x = PLIK.resolutionX/2-50*PLIK.pointFactor;
		label.t.y = PLIK.resolutionY/2+25*PLIK.pointFactor;
	 	label.t.skewingX = -37.5;
	 	label.t.rotation = 26.4;
		addChild(label);

		labelTitle = new TextAA("",Std.int(80*PLIK.pointFactor),GAME.COLOR_ORANGE);
		labelTitle.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		labelTitle.t.x = PLIK.resolutionX/2+100*PLIK.pointFactor;
		labelTitle.t.y = PLIK.resolutionY/2-50*PLIK.pointFactor;
	 	labelTitle.t.skewingX = -37.5;
	 	labelTitle.t.rotation = 26.4;
		addChild(labelTitle);

	}

	public function setText(title:String,message:String) {
		labelTitle.setText(title);
		label.setText(message);
	}

	public override function toString():String {
		return "[GAME.Overlay]";
	}

	public override function destroy() {
		label.destroy();
		removeChild(label);
		label = null;

		labelTitle.destroy();
		removeChild(labelTitle);
		label = null;

		background.destroy();
		removeChild(background);
		background = null;

		super.destroy();
	}
}
