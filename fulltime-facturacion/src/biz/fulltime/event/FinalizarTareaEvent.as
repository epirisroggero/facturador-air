//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import biz.fulltime.dto.DocumentoQuery;

import flash.events.Event;

public class FinalizarTareaEvent extends Event {

	public static const FINALIZAR_TAREA:String = "_finalizarTarea";

	public static const CANCELAR_FIN_TAREA:String = "_cancelarFinTarea";

	private var _nota:String;

	public function FinalizarTareaEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, note:String = "") {
		super(type, bubbles, cancelable);
		
		this.nota = note;
	}

	public function get nota():String {
		return _nota;
	}

	public function set nota(value:String):void {
		_nota = value;
	}

}
}
