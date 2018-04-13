//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Tarea")]
public class Tarea extends CodigoNombreEntity {
	
	private var _capituloId:String;
	
	public function Tarea(codigo:String = "", nombre:String = "") {
		super(codigo, nombre);
	}

	public function get capituloId():String {
		return _capituloId;
	}

	public function set capituloId(value:String):void {
		_capituloId = value;
	}

}
}
