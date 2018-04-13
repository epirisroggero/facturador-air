package skin.components.buttonBar {

import flash.display.Graphics;

import spark.filters.GlowFilter;
import spark.primitives.Rect;

public class HatchRect extends Rect {
	public var angleOffset:Number = 80;

	[Bindable]
	public var textH:Number = 20;

	public var hideBottomLine:Boolean = false;

	public var alwaysDrawBottomLine:Boolean = false;

	public function HatchRect() {
		super();
	}

	/**
	 *  @inheritDoc
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override protected function draw(g:Graphics):void {
		var w:Number = width;
		var h:Number = height;

		var angRadians:Number = angleOffset * Math.PI / 180;
		var xDisp:Number = h / Math.tan(angRadians);
		textH = w - xDisp - drawX;

		g.moveTo(drawX, h);
		if (alwaysDrawBottomLine || !hideBottomLine) {
			g.lineTo(drawX + textH, h);
		} else {
			g.moveTo(drawX + textH, h);
		}
		g.lineTo(drawX + textH + xDisp, drawY);
		g.lineTo(drawX + xDisp, drawY);
		g.lineTo(drawX, h);
	}
}
}