//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {
	
	import biz.fulltime.dto.ContactoDTO;
	import biz.fulltime.model.Contacto;
	
	import flash.events.Event;
	
	public class ContactoEvent extends Event {
		
		public static const BORRAR_CONTACTO:String = "borrarContacto";
		
		public static const MODIFICAR_CONTACTO:String = "modificarContacto";
		
		public static const CONTACTO_NUEVO:String = "contactoNuevo";
		
		public static const CONTACTO_SELECCIONADO:String = "contactoSeleccionado";
		
		public static const FINALIZAR_EDICION:String = "_FinalizarModoEdicion_ok";
		
		public static const CANCELAR_EDICION:String = "_FinalizarModoEdicion_cancel";
		
		private var _contacto:Contacto;
		
		private var _contactoDTO:ContactoDTO;
		
		public function ContactoEvent(type:String, contacto:Contacto = null, contactoDTO:ContactoDTO = null) {
			super(type, true, true);
			
			this.contacto = contacto;
			this.contactoDTO = contactoDTO;
		}
		
		public function get contacto():Contacto {
			return _contacto;
		}
		
		public function set contacto(value:Contacto):void {
			_contacto = value;
		}
		
		public function get contactoDTO():ContactoDTO {
			return _contactoDTO;
		}
		
		public function set contactoDTO(value:ContactoDTO):void {
			_contactoDTO = value;
		}
		
		
	}
}
