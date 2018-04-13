//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009 Ernesto Piris.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.conf {

import biz.fulltime.model.Usuario;

public class Permisos {

	// Facturador
	public static const DEUDORES:String = "Deudores"; //Ver deudores (incluye chequeo durante la facturacion?)
	public static const COSTOS_Y_UTILIDAD:String = "CostosYUtilidad"; //Ver costos y utilidad en base a costos
	public static const INFORMES:String = "Informes"; 
	public static const RUTINA_CARGA_COSTOS:String = "RutinaCargaCostos";
	public static const TABLAS_BASICAS:String = "TablasBasicas";
	public static const CONFIGURACIONES:String = "Configuraciones";
	
	public static const EXPEDICIONES:String = "Expediciones";

}
}
