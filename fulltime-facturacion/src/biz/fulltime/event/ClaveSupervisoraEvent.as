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

public class ClaveSupervisoraEvent extends Event {

	private var _usuarioId:String;

	public function ClaveSupervisoraEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, usuarioId:String = "") {
		super(type, bubbles, cancelable);

		this._usuarioId = usuarioId;
	}


	public function get usuarioId():String {
		return _usuarioId;
	}

	public function set usuarioId(value:String):void {
		_usuarioId = value;
	}

}
}
