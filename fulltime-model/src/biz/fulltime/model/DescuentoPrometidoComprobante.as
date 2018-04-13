//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.DescuentoPrometidoComprobante")]
public class DescuentoPrometidoComprobante {
	public var categCliente:CategoriasClientes;
	
	public var comprobante:Comprobante;

	public var dpcId:Number;

	public var retraso:int;

	public var descuento:String;
	
	public var categoriaCliente:String;
	
	public var cmpid:int;


	public function DescuentoPrometidoComprobante() {
	}
}

}
