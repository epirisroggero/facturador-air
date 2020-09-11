//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

import biz.fulltime.model.Articulo;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.dto.AntecedentesArticulo")]
public class AntecedentesArticulo {

	public var comprobante:CodigoNombre;

	public var documentoSerie:String;

	public var documentoNumero:Number;
	
	public var docId:String;

	public var fecha:Date;

	public var cantidad:int;

	public var moneda:CodigoNombre;

	public var precioUnitario:String;

	public var neto:String;

	public var costo:String;

	public var renta:String;

	public var tipoCambio:String;
	
	public var cliente:CodigoNombre;
	
	public var concepto:String;

	public var articulo:Articulo;

}
}
