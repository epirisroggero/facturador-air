//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import flash.events.Event;

public class FacturasPendientesEvent extends Event {

	public static const FACTURAS_PENDIENTES_CHANGED:String = "_facturasPendientesCliente";
	
	public static const LIMITE_CREDITO_EXCEDIDO:String = "_limiteCreditoExcedido";

	private var _data:Object;

	public function FacturasPendientesEvent(type:String, value:* = null) {
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
