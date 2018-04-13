//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model.deudores {

import biz.fulltime.dto.CodigoNombre;
import biz.fulltime.model.Cliente;

import mx.collections.ArrayCollection;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.deudores.DocumentoDeudor")]
public class DocumentoDeudor {
	
	public var fecha:String;
	public var deudor:Cliente;
	public var comprobante:CodigoNombre;
	public var numero:Number;
	public var vendedores:ArrayCollection;
	public var planPago:CodigoNombre;
	public var moneda:CodigoNombre;
	
	public var facturado:String;
	public var cancelado:String;
	public var adeudado:String;
	public var descuento:String;
	public var adeudadoNeto:String;
	public var docId:String;
	public var tieneCuotaVencida:Boolean;

	
	public function getFacturadoValue():BigDecimal {
		if (facturado == null || facturado.length < 1) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(facturado).setScale(2, MathContext.ROUND_HALF_UP);
	}
	
	public function getCanceladoValue():BigDecimal {
		if (cancelado == null || cancelado.length < 1) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(cancelado).setScale(2, MathContext.ROUND_HALF_DOWN);
	}

	public function getAdeudadoValue():BigDecimal {
		if (adeudado == null || adeudado.length < 1) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(adeudado).setScale(2, MathContext.ROUND_HALF_UP);
	}
	
	public function getDescuentoValue():BigDecimal {
		if (descuento == null || descuento.length < 1) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(descuento).setScale(0, MathContext.ROUND_HALF_DOWN);
	}

	public function getAdeudadoNetoValue():BigDecimal {
		if (adeudadoNeto == null || adeudadoNeto.length < 1) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(adeudadoNeto).setScale(2, MathContext.ROUND_HALF_UP);
	}


	public function DocumentoDeudor() {
	}
}
}
