//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.ArticuloPrecio")]
public class ArticuloPrecio {
	
	public var precio:String;
	
	public var artId:String;
	
	public var mndIdPrecio:String;
	
	public var precioBaseId:String;

	public var precioBaseConIVA:Boolean;
	
	public var articulo:Articulo;
	
	public var moneda:Moneda;
	
	public function ArticuloPrecio() {
	}
}

}
