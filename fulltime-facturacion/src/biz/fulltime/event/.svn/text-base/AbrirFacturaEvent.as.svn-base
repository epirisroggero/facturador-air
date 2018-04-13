//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import flash.events.Event;

public class AbrirFacturaEvent extends Event {

	public static const ABRIR_DOCUMENTO:String = "_abrirDocumento_";
	
	public static const ABRIR_DOCUMENTO_CLIENTE:String = "_abrirDocumentoCliente_";

	private var _docId:String;

	public function AbrirFacturaEvent(type:String, docId:String = null) {
		super(type, true, true);

		this._docId = docId;
	}

	public function get docId():String {
		return _docId;
	}

	public function set docId(value:String):void {
		_docId = value;
	}

}

}
