//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009 Ernesto Piris.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF IdeaSoft Co. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import flash.events.Event;

public class MonedaEvent extends Event {

	private var _oldValue:Object;

	private var _newValue:Object;
	
	public static const MONEDA_CHANGED:String = "_monedaChanged";

	public function MonedaEvent(type:String, oldvalue:* = null, newvalue:* = null) {
		super(type);
		
		this._oldValue = oldvalue;
		this._newValue = newvalue;
	}

	public function get newValue():Object {
		return _newValue;
	}

	public function set newValue(value:Object):void {
		_newValue = value;
	}

	public function get oldValue():Object {
		return _oldValue;
	}

	public function set oldValue(value:Object):void {
		_oldValue = value;
	}

}
}
