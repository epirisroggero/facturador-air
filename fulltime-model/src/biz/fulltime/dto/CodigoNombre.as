//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

import biz.fulltime.model.CodigoNombreEntity;

[RemoteClass(alias = "uy.com.tmwc.facturator.dto.CodigoNombre")]
public class CodigoNombre extends CodigoNombreEntity {
	public function CodigoNombre(codigo:String = null, nombre:String = null) {
		super(codigo, nombre);
	}
}
}
