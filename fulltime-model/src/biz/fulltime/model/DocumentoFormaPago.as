//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.DocumentoFormaPago")]
public class DocumentoFormaPago {

	public var docId:String;
	
	public var numero:Number;

	public var documento:Documento;

	public var formaPago:FormaPago;

	/**
	 * Moneda en que esta expresado el importe
	 */
	public var moneda:Moneda;

	private var _total:String;
	
	private var _importe:String;
	
	public var selected:Boolean;
	
	
	public function DocumentoFormaPago(documento:Documento = null, initValues:Boolean = true) {
		if (documento) {
			this.documento = documento;
			
			this.docId = documento.docId;
			
			this.moneda = documento.docRecMda;
			this.formaPago = FormaPago.EFECTIVO;
			this.numero = 1;

			if (initValues) {
				this.importe = documento.docRecNeto;
				this.total = documento.total;
			} else {
				this.importe = "0.00";
				this.total = "0.00";
			}
		}
	}
	
	public function get importe():String {
		return _importe;
	}

	public function set importe(value:String):void {
		_importe = value;
	}

	/**
	 * Importe en la moneda del documento
	 */
	public function get total():String {
		return _total;
	}

	/**
	 * @private
	 */
	public function set total(value:String):void {
		_total = value;
	}
	
	public function updateTotal():void {
		var monedaOrigenCode:String = moneda.codigo;
		var monedaDestinoCode:String = documento.moneda.codigo;
		
		if (monedaOrigenCode == monedaDestinoCode) {
			total = _importe;	
		} else {
			total = documento.convertirMonedaStr(monedaOrigenCode, monedaDestinoCode, new BigDecimal(_importe ? _importe : "0"), false).setScale(2, MathContext.ROUND_HALF_EVEN).toString();
		}

	}

}
}
