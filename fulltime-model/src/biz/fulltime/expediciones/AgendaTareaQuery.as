//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.expediciones {

import mx.collections.ArrayCollection;

[RemoteClass(alias = "uy.com.tmwc.facturator.expediciones.AgendaTareaQuery")]
public class AgendaTareaQuery {
	public var start:int;
	public var limit:int;
	
	public var pendientes:Boolean;

	public var usuario:String;
	public var fecha:Date;
	public var fechaDesde:Date;
	public var fechaHasta:Date;
	public var state:String;
	public var usuarios:ArrayCollection;
	public var tareas:ArrayCollection;
	public var contacto:String;
	public var asignado:String;
	public var supervisor:String;
	public var capituloId:String;

	public function AgendaTareaQuery() {
	}
}
}
