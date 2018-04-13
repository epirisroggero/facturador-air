//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import flash.events.Event;

public class FacturasGrabadasEvent extends Event {

	public static const FACTURAS_GRABADAS_CHANGED:String = "_facturasGrabadasCliente";

	private var _data:Object;

	public function FacturasGrabadasEvent(type:String, value:* = null) {
		super(type);

		this._data = value;
	}

	public function get data():Object {
		return _data;
	}

	public function set data(value:Object):void {
		_data = value;
	}
}
}
