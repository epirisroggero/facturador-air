package biz.fulltime.event
{

import biz.fulltime.model.CodigoNombreEntity;

import flash.events.Event;

public class UsuarioEvent extends Event {
	
	public static const BORRAR_USUARIO:String = "borrarUsuario";
	
	public static const MODIFICAR_USUARIO:String = "modificarUsuario";
	
	public static const USUARIO_NUEVO:String = "usuarioNuevo";
	
	public static const USUARIO_SELECCIONAD0:String = "usuarioSeleccionado";
	
	private var _usuario:CodigoNombreEntity;
	
	public function UsuarioEvent(type:String, usuario:CodigoNombreEntity= null) {
		super(type, true, false);
		
		this.usuario = usuario;
	}
	
	public function get usuario():CodigoNombreEntity {
		return _usuario;
	}
	
	public function set usuario(value:CodigoNombreEntity):void {
		_usuario = value;
	}
	
}
}
