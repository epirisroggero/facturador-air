//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import biz.fulltime.dto.ClienteDTO;
import biz.fulltime.model.Cliente;

import flash.events.Event;

public class ClienteEvent extends Event {

	public static const BORRAR_CLIENTE:String = "borrarCliente";

	public static const MODIFICAR_CLIENTE:String = "modificarCliente";
	
	public static const CREAR_COTIZACION_CLIENTE:String = "crearCotizacionCliente";
	
	public static const CREAR_ORDEN_VENTA_CLIENTE:String = "crearOrdenVentaCliente";

	public static const CLIENTE_NUEVO:String = "clienteNuevo";

	public static const CLIENTE_SELECCIONADO:String = "clienteSeleccionado";
	
	public static const FINALIZAR_EDICION:String = "_FinalizarModoEdicion_ok";
	
	public static const CANCELAR_EDICION:String = "_FinalizarModoEdicion_cancel";

	private var _cliente:Cliente;

	private var _clienteDTO:ClienteDTO;

	public function ClienteEvent(type:String, cliente:Cliente = null, clienteDTO:ClienteDTO = null) {
		super(type, true, true);

		this.cliente = cliente;
		this.clienteDTO = clienteDTO;
	}

	public function get cliente():Cliente {
		return _cliente;
	}

	public function set cliente(value:Cliente):void {
		_cliente = value;
	}

	public function get clienteDTO():ClienteDTO {
		return _clienteDTO;
	}

	public function set clienteDTO(value:ClienteDTO):void {
		_clienteDTO = value;
	}


}
}
