//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
public class Cotizaciones {

	// Cotizacion del dolar por peso uruguayo.
	public var dolar:Cotizacion;

	// Cotización del euro por peso uruguayo.
	public var euro:Cotizacion;

	// Cotizacion del dolar por euro.
	public var dolarXeuro:Cotizacion;

	public function Cotizaciones() {
	}
}
}
