//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

[RemoteClass(alias = "uy.com.tmwc.facturator.dto.DocumentoQuery")]
public class DocumentoQuery {
	public var start:int;
	public var limit:int;

	public var serie:String;
	public var numero:String;
	public var tipoComprobante:Number;
	public var cliente:String;
	public var proveedor:String;
	public var articulo:String;
	public var fechaDesde:Date;
	public var fechaHasta:Date;
	public var lineaConcepto:String;
	public var moneda:String;
	
	public var emitido:Boolean = false;
	public var pendiente:Boolean = true;
	public var tieneSaldo:Boolean = false;
	
	public var esSolicitud:Boolean = false;
	public var esRecibo:Boolean = false;
	public var esCheque:Boolean = false;
	
	public var comprobantes:String;
	public var compsExcluidos:String;
	
	public var orden:String = "DESC";
	
	public function DocumentoQuery() {
	}
}
}
