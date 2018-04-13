//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.ResumenEntrega")]
public class ResumenEntrega {
	public var entrega:Entrega;
	public var cantidad:Number;

	public function ResumenEntrega(entrega:Entrega = null, cantidad:Number = 0) {
		this.entrega = entrega;
		this.cantidad = cantidad;
	}
}

}
