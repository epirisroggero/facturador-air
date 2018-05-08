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
	 * Importe en una moneda que puede ser diferente a la del documento, {@link #moneda}
	 */
	public var importe:String;

	/**
	 * Moneda en que esta expresado el importe
	 */
	public var moneda:Moneda;

	private var _total:String;
	
	public var selected:Boolean;
	
	
	public function DocumentoFormaPago(documento:Documento = null) {
		if (documento) {
			this.documento = documento;
			
			this.docId = documento.docId;
			this.numero = 1;
			
			this.moneda = documento.docRecMda;
			this.formaPago = FormaPago.EFECTIVO;
			this.importe = documento.docRecNeto;
			this.total = documento.total;
		}
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
	
	public function updateImporte():void {
		if (documento.moneda.codigo == moneda.codigo) {
			importe = _total;	
		} else {
			importe = "0.00";
		}

	}

}
}
