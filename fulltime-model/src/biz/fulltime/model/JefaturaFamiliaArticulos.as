//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.JefaturaFamiliaArticulos")]
public class JefaturaFamiliaArticulos extends Jefatura {

	public var familia:FamiliaArticulos;

	public function JefaturaFamiliaArticulos() {
		super();
	}
}


}
