//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009 Ideasoft Uruguay S.R.L.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.model {
import biz.fulltime.conf.GeneralOptions;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.PermisosDocumentoUsuario")]
public class PermisosDocumentoUsuario {
	
	public var edicion:Boolean = true; //El usuario puede editar el documento
	public var rentaReal:Boolean; //El usuario puede ver la renta y costo 'real'
	public var rentaDistribuidor:Boolean; //El usuario puede ver la renta como (precio - precio distribuidor)

	public function PermisosDocumentoUsuario() {
	}	

}
}