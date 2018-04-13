//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2011 Fultime S.R.L.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF IdeaSoft Co. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.dto {
	
[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.dto.ContactoDTO")]
public class ContactoDTO {

	public function ContactoDTO() {
	}

	public var codigo:String;

	public var nombre:String;
	
	public var razonSocial:String;
	
	public var activo:Boolean;
	
	public var esNuevo:Boolean;
}
}