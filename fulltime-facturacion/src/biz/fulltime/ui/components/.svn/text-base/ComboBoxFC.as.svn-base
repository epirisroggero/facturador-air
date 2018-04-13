//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.ui.components {

import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import biz.fulltime.model.CodigoNombreEntity;
import spark.components.ComboBox;

[Event(name = "helpFT", type = "flash.events.Event")]
public class ComboBoxFC extends ComboBox {
	public static var HELP_COMBO_FT:String = "helpFT";

	public function ComboBoxFC() {
		super();

		labelFunction = myLabelFunction;
	}

	public function myLabelFunction(item:Object):String {
		if (item is CodigoNombreEntity) {
			var codName:CodigoNombreEntity = item as CodigoNombreEntity;
			return codName.codigo + " - " + codName.nombre;
		} else {
			return item != null ? item.toString() : "";
		}
	}

	protected override function capture_keyDownHandler(event:KeyboardEvent):void {
		if (event.keyCode == Keyboard.ENTER) {
			event.preventDefault();
			this.textInput.selectAll();
			callLater(function():void {
				focusManager.getNextFocusManagerComponent().setFocus();
			});

			return;
		}

		super.capture_keyDownHandler(event);
		if (event.keyCode == 112) {
			var newEvent:Event = new Event(HELP_COMBO_FT, false);
			dispatchEvent(newEvent);
		}
	}
}
}
