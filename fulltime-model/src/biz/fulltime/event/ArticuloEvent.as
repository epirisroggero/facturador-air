//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {
	
	import biz.fulltime.dto.ArticuloDTO;
	import biz.fulltime.model.Articulo;
	
	import flash.events.Event;
	
	public class ArticuloEvent extends Event {
		
		public static const BORRAR_ARTICULO:String = "borrarAriculo";
		
		public static const MODIFICAR_ARTICULO:String = "modificarArticulo";
		
		public static const ARTICULO_NUEVO:String = "articuloNuevo";
		
		public static const ARTICULO_SELECCIONADO:String = "articuloSeleccionado";
		
		public static const REFRESCAR_ARTICULO_SELECCIONADO:String = "refrescarArticuloSeleccionado";
		
		public static const FINALIZAR_EDICION_ART:String = "_FinalizarModoEdition_ok";
		
		public static const CANCELAR_EDICION_ART:String = "_FinalizarModoEdition_cancel";
		
		private var _articulo:Articulo;
		
		private var _articuloDTO:ArticuloDTO;
		
		public function ArticuloEvent(type:String, articulo:Articulo = null, articuloDTO:ArticuloDTO = null) {
			super(type, true, true);
			
			this.articulo = articulo;
			this.articuloDTO = articuloDTO;
		}
		
		public function get articulo():Articulo {
			return _articulo;
		}
		
		public function set articulo(value:Articulo):void {
			_articulo = value;
		}
		
		public function get articuloDTO():ArticuloDTO {
			return _articuloDTO;
		}
		
		public function set articuloDTO(value:ArticuloDTO):void {
			_articuloDTO = value;
		}
		
		
	}
}
