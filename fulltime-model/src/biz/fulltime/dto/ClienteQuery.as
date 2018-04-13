//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009 Ernesto Piris.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

[RemoteClass(alias = "uy.com.tmwc.facturator.dto.ClienteQuery")]
public class ClienteQuery {
	
	public var activo:Boolean;
	
	public var nombre:String;
	public var vendedor:String;
	public var zona:String;
	public var categoria:String;
	public var especialista:String;
	public var giro:String;
	public var encargadoCuenta:String; 
	public var razonSocial:String;
	
	public var proveedor:Boolean; 
	
	public function ClienteQuery() {
	}
}
}
