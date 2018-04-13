//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

[RemoteClass(alias = "uy.com.tmwc.facturator.dto.CreditoInfo")]
public class CreditoInfo {
	
	public var cliente:String;
	public var deuda:String;
	public var topeCredito:Number;
	public var solicitado:String;
	
	public function CreditoInfo() {
	}
	
	public function tieneCredito():Boolean {
		var tc:BigDecimal = new BigDecimal(topeCredito);
		var dd:BigDecimal = new BigDecimal(deuda);
		var sol:BigDecimal = new BigDecimal(solicitado);
		
		if (dd.add(sol).compareTo(tc) ==  1) {
		 	return false; 	
		}
		return true;
			
	}
}
}
