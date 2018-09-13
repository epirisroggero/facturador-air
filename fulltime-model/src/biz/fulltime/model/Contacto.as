//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import flash.utils.ByteArray;

import mx.collections.ArrayCollection;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Contacto")]
public class Contacto extends CodigoNombreEntity {
	public function Contacto() {
	}

	public var ctoCliente:String;
	
	public var ctoProveedor:String = "N";
	
	public var deptoIdCto:String = "MO";

	public var paisIdCto:String = "UY";

	public var ctoEmail1:String;

	public var ctoEmail2:String;

	public var ctoTelefono:String;

	public var ctoCelular:String;

	public var ctoDireccion:String;

	public var ctoBlob:ByteArray;

	public var ctoBlobExt:String;

	public var ctoFax:String;

	public var girIdCto:String;

	public var ctoNom:String;

	public var ctoNombreCompleto:String;

	public var ctoRSocial:String;

	public var ctoRUT:String;

	public var ctoAlta:Date = new Date();

	public var ctoActivo:String = "S";

	public var ctoLocalidad:String = "";


	public var ctoDocumentoTipo:String = "";

	public var zonaIdCto:String = "";

	public var adicionales:ArrayCollection = new ArrayCollection();

	public var ctoNotas:String;

	////////////////////////////////////////

	public var ctoWeb:String;

	public var oriCtoIdCto:String; 

	public var gruCtoId:String; 

	public var ctoPostal:String;

	public var locIdCto:Number;

	public var ctoDocumento:String;

	public var usuIdCto:Number;
	
	public var esNuevo:Boolean;
	
	public var ctoNotasEfactura:String;
	
	public var ctoDocumentoSigla:String;
	
	


}
}
