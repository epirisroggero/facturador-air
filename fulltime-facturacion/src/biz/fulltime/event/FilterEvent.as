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

public class FilterEvent extends Event {

	public static const FILTRAR_DOCUMENTOS:String = "_filtrar_documentos_";
	
	public static const BORRAR_FILTROS:String = "_borrar_filtros_";
	
	private var _docQuery:DocumentoQuery;

	public function FilterEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, value:DocumentoQuery = null) {
		super(type, bubbles, cancelable);
		
		_docQuery = value;
	}

	public function get docQuery():DocumentoQuery {
		return _docQuery;
	}

	public function set docQuery(value:DocumentoQuery):void {
		_docQuery = value;
	}

}
}
