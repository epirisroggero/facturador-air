//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2012 Ernesto Piris.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
//------------------------------------------------------------------------------

package biz.fulltime.dto {
import mx.collections.ArrayCollection;

[RemoteClass(alias="uy.com.tmwc.facturator.dto.ArticuloQuery")]
public class ArticuloQuery {

	public function ArticuloQuery() {
	}

	public var activo:Boolean = true;

	public var familias:String;

	public var proveedor:String;
}
}
