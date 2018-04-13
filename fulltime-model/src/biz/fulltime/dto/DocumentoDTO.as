//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.dto.DocumentoDTO")]
public class DocumentoDTO {
	public var docId:String;

	public var serie:String;

	public var numero:String;

	public var fecha:String;

	public var cliente:CodigoNombre;

	public var moneda:CodigoNombre;

	public var comprobante:CodigoNombre;

	public var subtotal:String;

	public var total:String;
	
	public var saldo:String;

	public var costo:String;

	public var iva:String;

	public var emitido:Boolean;

	public var pendiente:Boolean;

	public var tipoComprobante:String;
	
	public var tipoCFE:String;

	public var razonSocial:String;

	private var _serieNumero:String;

	public var selected:Boolean;
	
	public var registroHora:String;
	
	public var registroFecha:String;
	
	public var usuarioId:String;
	
	public var autorizadoPor:String;
	
	public var emitidoPor:String;
	
	public var caeNombre:String;


	public function DocumentoDTO() {
	}

	public function get serieNumero():String {
		return (serie != null ? serie : "") + (numero != null ? numero : "");
	}

	public function set serieNumero(value:String):void {
		_serieNumero = value;
	}

}
}
