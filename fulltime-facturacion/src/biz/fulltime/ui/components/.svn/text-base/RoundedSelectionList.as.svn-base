// ActionScript file
package biz.fulltime.ui.components {


import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.SpreadMethod;
import flash.display.Sprite;
import flash.geom.Matrix;

import mx.controls.List;
import mx.controls.listClasses.IListItemRenderer;
import mx.styles.StyleManager;

public class RoundedSelectionList extends List {

	private var _color1:uint = 0xb30000;

	private var _color2:uint = 0xb30000;

	public function RoundedSelectionList() {
		super();
	}

	override protected function drawSelectionIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void {
		var g:Graphics = indicator.graphics;
		g.clear();

		var fillType:String = GradientType.LINEAR;
		var colors:Array = [_color1, _color2, _color1];
		var alphas:Array = [1.0, 1.0, 1.0];
		var ratios:Array = [0, 176, 255];
		var matr:Matrix = new Matrix();
		matr.createGradientBox(width, height, 0, x, y);
		var spreadMethod:String = SpreadMethod.PAD;
		g.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);
		g.drawRect(x, y + height - 10, itemRenderer.width, 8);
		g.endFill();
	}

	override protected function drawHighlightIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void {
		var g:Graphics = indicator.graphics;
		g.clear();
		g.beginFill(0xfafafa);
		g.lineStyle(2, 0xfdfdfd);
		g.drawRoundRect(x, y, itemRenderer.width, height, 8, 8);
		g.endFill();
	}
}
}
