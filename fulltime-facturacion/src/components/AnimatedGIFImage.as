//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package components {

import flash.utils.ByteArray;
import mx.controls.Image;
import mx.core.UIComponent;

import org.gif.player.GIFPlayer;

public class AnimatedGIFImage extends Image {

	private var _gifImage:UIComponent;

	[Bindable]
	[Embed(source = "/assets/general/loader/loader.gif", mimeType = "application/octet-stream")]
	private var gifStream:Class;

	private var gifBytes:ByteArray = new gifStream();

	public function AnimatedGIFImage() {
		super();
		this._gifImage = new UIComponent();
	}

//		override public function set source(value:Object):void {
//			if (!value is String) {
//				throw new ArgumentError("Source must be of type String");
//			}
//			super.source=value;
//		}

	override protected function createChildren():void {
		super.createChildren();

		var gifPlayer:GIFPlayer = new GIFPlayer();
		gifPlayer.loadBytes(gifBytes);

		//			player.load(new URLRequest(this.source as String));
		this._gifImage.addChild(gifPlayer);
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		this.addChild(this._gifImage);
		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}
}
}
