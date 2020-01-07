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
import biz.fulltime.model.Comprobante;
import biz.fulltime.model.Documento;
import biz.fulltime.model.Moneda;

import mx.collections.ArrayCollection;

import util.CatalogoFactory;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.deudores.DocumentoDeudor")]
public class DocumentoDeudor {
	
	public var date:Date;
	public var fecha:String;
	public var deudor:Cliente;
	public var comprobante:Comprobante;
	public var numero:Number;
	public var serie:String;
	public var vendedores:ArrayCollection;
	public var planPago:CodigoNombre;
	public var moneda:CodigoNombre;
	public var documento:Documento;
	
	public var facturado:String;
	public var cancelado:String;
	public var adeudado:String;
	public var descuento:String;
	public var adeudadoNeto:String;
	public var docId:String;
	public var tieneCuotaVencida:Boolean;
	public var diasRetraso:Number;
	public var fechaVencimiento:Date;
	
	private var _codCliente:String;
	
	public function getFacturadoValue():BigDecimal {
		if (facturado == null || facturado.length < 1) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(facturado).setScale(2, MathContext.ROUND_HALF_UP);
	}
	
	public function setFacturadoValue(value:BigDecimal) {
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

	public function get codCliente():String {
		if (!_codCliente) {
			_codCliente = deudor ? deudor.codigo : "";	
		}
		return _codCliente;
	}
	
	public function set codCliente(value:String):void {
	}

	public function get nombreCliente():String {
		if (deudor) {
			return deudor.nombre ? deudor.nombre.toUpperCase() : "";	
		}
		return "";
	}
	
	public function set nombreCliente(value:String):void {
	}

	public function getMonedaSimbolo():String {
		var mda:String = moneda.codigo;
		var simbolo:String = "";
		for each (var m:Moneda in CatalogoFactory.getInstance().monedas) {
			if (m.codigo == mda) {
				simbolo = m.simbolo;
			}
		}							
		return simbolo;

	}
	
	public function DocumentoDeudor() {
	}
	
}
}
