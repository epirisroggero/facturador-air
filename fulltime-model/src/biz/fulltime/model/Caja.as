//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Caja")]
public class Caja extends CodigoNombreEntity {
	public static const CAJA_PRINCIPAL:Number = 1;
	
	public static const CAJA_COBRANZA:Number = 2;
	
	public function Caja() {
	}
}
}
