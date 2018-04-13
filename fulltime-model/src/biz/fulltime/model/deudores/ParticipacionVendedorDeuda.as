//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model.deudores {

import biz.fulltime.dto.CodigoNombre;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.deudores.ParticipacionVendedorDeuda")]
public class ParticipacionVendedorDeuda {

	public var vendedor:CodigoNombre;
	public var porcentaje:String;

	public function ParticipacionVendedorDeuda() {
	}
	
	public function getPorcentaje():BigDecimal {
		if (porcentaje == null) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(porcentaje).setScale(2);	
	}
}
}
