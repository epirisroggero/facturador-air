//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {
import biz.fulltime.conf.Permisos;

import mx.collections.ArrayCollection;


[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Usuario")]
public class Usuario extends CodigoNombreEntity {

	public static const USUARIO_TITO:String = "5";
	public static const USUARIO_VENDEDOR_JUNIOR:String = "V";
	public static const USUARIO_VENDEDOR_DISTRIBUIDOR:String = "V2";
	public static const USUARIO_VENDEDOR_SENIOR:String = "V3";
	public static const USUARIO_SUPERVISOR:String = "S";
	public static const USUARIO_ADMINISTRADOR:String = "A";
	public static const USUARIO_FACTURACION:String = "F";
	public static const USUARIO_ALIADOS_COMERCIALES:String = "AC";
	

	public var usuNotas:String;
	
	public var usuTipo:String;
	
	public var permisoId:String;
	
	public var usuarioModoMostrador:Boolean;
	
	public var usuarioModoDistribuidor:Boolean;
	
	public var permisos:ArrayCollection;
	
	public var permisosDocumentoUsuario:PermisosDocumentoUsuario;
	
	public var usuActivo:String;
	
	public var claveSup:String;
	
	public var usuEmail:String;
	
	public var venId:String;
	
	public function Usuario(codigo:String = "", nombre:String = "") {
		super(codigo, nombre);
	}

	public function esVendedorJunior():Boolean {
		return permisoId == USUARIO_VENDEDOR_JUNIOR;	
	}
	
	public function esUsuarioTito():Boolean {
		return permisoId == USUARIO_TITO;	
	}
	
	public function esSupervisor():Boolean {
		return usuTipo == "S";
	}

}
}
