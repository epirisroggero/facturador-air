//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import mx.collections.ArrayCollection;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.ComisionesDocumento")]
public class ComisionesDocumento {
	public var documento:Documento;
	public var participaciones:ArrayCollection = new ArrayCollection();

	public function ComisionesDocumento() {
	}
}

}
