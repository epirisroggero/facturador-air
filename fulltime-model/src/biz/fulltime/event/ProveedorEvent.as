//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import biz.fulltime.dto.ProveedorDTO;
import biz.fulltime.model.Proveedor;

import flash.events.Event;

public class ProveedorEvent extends Event {

	public static const BORRAR_PROVEEDOR:String = "borrarProveedor";

	public static const MODIFICAR_PROVEEDOR:String = "modificarProveedor";

	public static const PROVEEDOR_NUEVO:String = "proveedorNuevo";

	public static const PROVEEDOR_SELECCIONADO:String = "proveedorSeleccionado";

	public static const FINALIZAR_EDICION:String = "_FinalizarModoEdicion_ok";

	public static const CANCELAR_EDICION:String = "_FinalizarModoEdicion_cancel";

	private var _proveedor:Proveedor;

	private var _proveedorDTO:ProveedorDTO;

	public function ProveedorEvent(type:String, proveedor:Proveedor = null, proveedorDTO:ProveedorDTO = null) {
		super(type, true, true);

		this.proveedor = proveedor;
		this.proveedorDTO = proveedorDTO;
	}

	public function get proveedor():Proveedor {
		return _proveedor;
	}

	public function set proveedor(value:Proveedor):void {
		_proveedor = value;
	}

	public function get proveedorDTO():ProveedorDTO {
		return _proveedorDTO;
	}

	public function set proveedorDTO(value:ProveedorDTO):void {
		_proveedorDTO = value;
	}


}
}
