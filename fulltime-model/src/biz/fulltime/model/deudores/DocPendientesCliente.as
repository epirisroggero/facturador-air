//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model.deudores {

import biz.fulltime.dto.DocumentoDTO;
import biz.fulltime.model.Cliente;
import biz.fulltime.model.Comprobante;
import biz.fulltime.model.CotizacionesModel;
import biz.fulltime.model.Moneda;
import biz.fulltime.model.Zona;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.formatters.DateFormatter;

import util.CatalogoFactory;

public class DocPendientesCliente extends EventDispatcher {

	private var _codCliente:String;

	private var _cliente:Cliente;

	public var nombreCliente:String;
	
	public var zonaCliente:String;

	[Bindable]
	public var print:Boolean;
	
	private var _moneda:Moneda;


	private var _totalFacturado:BigDecimal = BigDecimal.ZERO;

	private var _totalCancelado:BigDecimal = BigDecimal.ZERO;

	private var _totalAdeudado:BigDecimal = BigDecimal.ZERO;

	private var _totalAdeudadoNeto:BigDecimal = BigDecimal.ZERO;

	private var _documentos:ArrayCollection = new ArrayCollection();


	public function DocPendientesCliente() {
	}
	
	public function get deudorNombre():String {
		return _cliente.nombre;
	}
	
	public function set deudorNombre(value:String):void {
		this._cliente.nombre = value;
	}
	
	public function get zona():String {
		if (_cliente.contacto.zonaIdCto == null) {
			return "";
		}
		return zonaCliente;
	}
	
	/*public function set zona(value:String):void {
		this._cliente.zona = value;
	}*/

	public function get categoria():String {
		if (_cliente.categCliId == null) {
			return "";
		}			
		return _cliente.categCliId;
	}
	
	public function set categoria(value:String):void {
		this._cliente.categCliId = value;
	}

	public function get grupo():String {
		if (_cliente.grupo == null) {
			return null;
		}			
		return _cliente.grupo.nombre;
	}
	
	public function get encargadoPagos():String {
		if (_cliente.encargadoPagos == null) {
			return "";
		}			
		return _cliente.encargadoPagos;
	}
	
	public function set encargadoPagos(value:String):void {
		this._cliente.encargadoPagos = value;
	}
	
	public function get direccionCobranza():String {
		if (_cliente.direccionCobranza == null) {
			return _cliente.contacto.ctoDireccion;
		}			
		return _cliente.direccionCobranza;
	}
	
	public function set direccionCobranza(value:String):void {
		this._cliente.direccionCobranza = value;
	}

	
	public function get diaHoraPagos():String {
		if (_cliente.diaHoraPagos == null) {
			return "";
		}			
		return _cliente.diaHoraPagos;
	}
	
	public function set diaHoraPagos(value:String):void {
		this._cliente.diaHoraPagos = value;
	}

	public function get vendedorCodigo():String {
		if (_cliente.vendedor) {
			return _cliente.vendedor.codigo;	
		} else {
			return null;
		}		
	}
	
	public function set vendedorCodigo(value:String):void {
		this._cliente.vendedor.codigo = value;
	}


	[Bindable]
	public function get totalAdeudadoNeto():BigDecimal {
		return _totalAdeudadoNeto;
	}
	
	public function set totalAdeudadoNeto(value:BigDecimal):void {
		_totalAdeudadoNeto = value;
	}

	[Bindable]
	public function get totalAdeudado():BigDecimal {
		return _totalAdeudado;
	}

	public function set totalAdeudado(value:BigDecimal):void {
		_totalAdeudado = value;
	}

	[Bindable]
	public function get totalCancelado():BigDecimal {
		return _totalCancelado;
	}

	public function set totalCancelado(value:BigDecimal):void {
		_totalCancelado = value;
	}

	[Bindable]
	public function get totalFacturado():BigDecimal {
		return _totalFacturado;
	}

	public function set totalFacturado(value:BigDecimal):void {
		_totalFacturado = value;
	}

	public function get cliente():Cliente {
		return _cliente;
	}

	public function set cliente(value:Cliente):void {
		_cliente = value;

		nombreCliente = _cliente.nombre;
	
		zonaCliente = "";
		for each (var z:Zona in CatalogoFactory.getInstance().zonas) {
			if (_cliente && z.codigo == _cliente.contacto.zonaIdCto) {
				zonaCliente = z.nombre;
				break;
			}
		}

	}

	public function get documentos():ArrayCollection {
		return _documentos;
	}

	public function set documentos(value:ArrayCollection):void {
		_documentos = value;

		dispatchEvent(new Event("_changeDocumentos"));
	}


	public function get codCliente():String {
		return _codCliente;
	}

	public function set codCliente(value:String):void {
		_codCliente = value;
	}

	public function agregarDocumento():String {
		return _codCliente;
	}
	
	
	public function getDocumentosPendientes():String {
		var dateFormatter:DateFormatter = new DateFormatter();
		dateFormatter.formatString = "DD/MM/YY";
		
		var docPendientes:String = "\nDocumentos Pendientes:\n";
		docPendientes += "Fecha \t| ";
		docPendientes += "Comprobante | ";
		docPendientes += "Moneda | ";
		docPendientes += "Facturado | ";
		docPendientes += "Adeudado | ";
		docPendientes += "Cancelado | ";
		docPendientes += "Descuento | ";
		docPendientes += "A. Neto |\n";
		var  i:int = 0;
		for each (var doc:DocumentoDeudor in _documentos) {
			var comprobante:Comprobante = CatalogoFactory.getInstance().getComprobante(doc.comprobante.codigo);
			if (!doc.tieneCuotaVencida && comprobante.tipo != Comprobante.NOTA_CREDITO) {
				docPendientes += dateFormatter.format(doc.fecha) + " | ";
				docPendientes += doc.comprobante.nombre + " | ";
				docPendientes += doc.moneda.nombre + " | ";
				docPendientes += doc.facturado + " | ";
				docPendientes += doc.adeudado + " | ";
				docPendientes += doc.cancelado + " | ";
				docPendientes += doc.descuento + " | ";
				docPendientes += doc.adeudadoNeto + " |\n";
				i++;
			}
				
		}		
		return i > 0 ? docPendientes : "";
	}
	
	public function getDocumentosVencidos():String {
		var dateFormatter:DateFormatter = new DateFormatter();
		dateFormatter.formatString = "DD/MM/YY";

		var docVencidos:String = "\nDocumentos Vencidos:\n";
		docVencidos += "Fecha \t| ";
		docVencidos += "Comprobante | ";
		docVencidos += "Moneda| ";
		docVencidos += "Facturado | ";
		docVencidos += "Adeudado | ";
		docVencidos += "Cancelado | ";
		docVencidos += "Descuento | ";
		docVencidos += "A. Neto |\n";
		var  i:int = 0;
		for each (var doc:DocumentoDeudor in _documentos) {
			var comprobante:Comprobante = CatalogoFactory.getInstance().getComprobante(doc.comprobante.codigo);

			if (doc.tieneCuotaVencida && comprobante.tipo != Comprobante.NOTA_CREDITO) {
				docVencidos += dateFormatter.format(doc.fecha) + " | ";
				docVencidos += doc.comprobante.nombre + " | ";
				docVencidos += doc.moneda.nombre + " | ";
				docVencidos += doc.facturado + " | ";
				docVencidos += doc.adeudado + " | ";
				docVencidos += doc.cancelado + " | ";
				docVencidos += doc.descuento + " | ";
				docVencidos += doc.adeudadoNeto + " |\n";
				i++;
			}
			
		}
		return i > 0 ? docVencidos : "";
	}

	public function getTotalFacturado(moneda:String):String {
		_totalFacturado = BigDecimal.ZERO;
		for each (var doc:DocumentoDeudor in _documentos) {
			var codigoMoneda:String = doc.moneda.codigo;
			var comprobante:Comprobante = CatalogoFactory.getInstance().getComprobante(doc.comprobante.codigo);
			
			if (!comprobante ) {
				trace("Comprobante: " + doc.comprobante.codigo + " no Existe :: " + doc.getFacturadoValue());
			} else {
				if (moneda != codigoMoneda) {
					_totalFacturado = _totalFacturado.add(convertir(aplicarSigno(comprobante, doc.getFacturadoValue()), codigoMoneda, moneda));
				} else {
					_totalFacturado = _totalFacturado.add(aplicarSigno(comprobante, doc.getFacturadoValue()));
				}				
			}

		}
		return _totalFacturado.setScale(2).toString();
	}

	public function getTotalCancelado(moneda:String):String {
		_totalCancelado = BigDecimal.ZERO;
		for each (var doc:DocumentoDeudor in _documentos) {
			var codigoMoneda:String = doc.moneda.codigo;
			if (moneda != codigoMoneda) {
				_totalCancelado = _totalCancelado.add(convertir(doc.getCanceladoValue(), codigoMoneda, moneda));
			} else {
				_totalCancelado = _totalCancelado.add(doc.getCanceladoValue());
			}
		}
		return _totalCancelado.setScale(2).toString();
	}

	public function getTotalAdeudado(moneda:String, docId:String = null):String {
		_totalAdeudado = BigDecimal.ZERO;
		for each (var doc:DocumentoDeudor in _documentos) {
			if (docId == null || docId != doc.docId) {
				var codigoMoneda:String = doc.moneda.codigo;
				if (moneda != codigoMoneda) {
					_totalAdeudado = _totalAdeudado.add(convertir(doc.getAdeudadoValue(), codigoMoneda, moneda));
				} else {
					_totalAdeudado = _totalAdeudado.add(doc.getAdeudadoValue());
				}				
			}
		}
		return _totalAdeudado.setScale(2).toString();
	}

	public function getTotalAdeudadoNeto(moneda:String):String {
		_totalAdeudadoNeto = BigDecimal.ZERO;
		for each (var doc:DocumentoDeudor in _documentos) {
			var codigoMoneda:String = doc.moneda.codigo;
			if (moneda != codigoMoneda) {
				_totalAdeudadoNeto = _totalAdeudadoNeto.add(convertir(doc.getAdeudadoNetoValue(), codigoMoneda, moneda));
			} else {
				_totalAdeudadoNeto = _totalAdeudadoNeto.add(doc.getAdeudadoNetoValue());
			}
		}
		return _totalAdeudadoNeto.setScale(2).toString();
	}


	public static function convertir(valor:BigDecimal, monedaDesde:String, monedaHasta:String):BigDecimal {
		var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();

		// Convertir Pesos a Dolares & Dolares a Pesos
		var dolarValue:String = cotizaciones.cotizaciones.dolarVenta.@value[0];
		var dolar:BigDecimal = new BigDecimal(dolarValue);
		
		if ((monedaDesde == Moneda.PESOS || monedaDesde == Moneda.PESOS_ASTER) && (monedaHasta == Moneda.DOLARES || monedaHasta == Moneda.DOLARES_ASTER)) { // Peso a Dolar
			if (dolar.numberValue() > 0) {
				valor = valor.divide(dolar);
			} else {
				valor = BigDecimal.ZERO;
			}
		} else if ((monedaDesde == Moneda.DOLARES || monedaDesde == Moneda.DOLARES_ASTER) && (monedaHasta == Moneda.PESOS || monedaHasta == Moneda.PESOS_ASTER)) { // Dolar a Pesos
			valor = valor.multiply(dolar);
		}

		// Convertir Pesos a Euros & Euros a Pesos
		var euroValue:String = cotizaciones.cotizaciones.euroVenta.@value[0];
		var euro:BigDecimal = new BigDecimal(euroValue);
		if ((monedaDesde == Moneda.PESOS || monedaDesde == Moneda.PESOS_ASTER) && (monedaHasta == Moneda.EUROS || monedaHasta == Moneda.EUROS_ASTER)) { // Peso a Euro
			if (euro.numberValue() > 0) {
				valor = valor.divide(euro);
			} else {
				valor = BigDecimal.ZERO;
			}
		} else if ((monedaDesde == Moneda.EUROS || monedaDesde == Moneda.EUROS_ASTER) && (monedaHasta == Moneda.PESOS || monedaHasta == Moneda.PESOS_ASTER)) { // Euro a Pesos
			valor = valor.multiply(euro);
		}

		// Convertir Dolares a Euros & Euros a Dolares
		var dolarXeuroValue:String = cotizaciones.cotizaciones.euroVentaXDolar.@value[0];
		var cotizacionEuro:BigDecimal = new BigDecimal(dolarXeuroValue);
		if ((monedaDesde == Moneda.DOLARES || monedaDesde == Moneda.DOLARES_ASTER) && (monedaHasta == Moneda.EUROS || monedaHasta == Moneda.EUROS_ASTER)) { // Dolar a Euro
			if (cotizacionEuro.numberValue() > 0) {
				valor = valor.divide(cotizacionEuro);
			} else {
				valor = BigDecimal.ZERO;
			}			
		} else if ((monedaDesde == Moneda.EUROS || monedaDesde == Moneda.EUROS_ASTER) && (monedaHasta == Moneda.DOLARES || monedaHasta == Moneda.DOLARES_ASTER)) { // Euro a Dolar
			valor = valor.multiply(cotizacionEuro);
		}
		return valor.setScale(2, MathContext.ROUND_HALF_UP);
	}

	private function aplicarSigno(comprobante:Comprobante, abs:BigDecimal):BigDecimal {
		
		if (comprobante.tipo == Comprobante.NOTA_CREDITO) {
			return abs.negate();
		} else {
			return abs;
		}
	}

	[Bindable]
	public function get moneda():Moneda {
		return _moneda;
	}

	public function set moneda(value:Moneda):void {
		_moneda = value;
		
		dispatchEvent(new Event("_changeMoneda"));
	}


}
}
