//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import flash.events.Event;
import flash.utils.ByteArray;

import org.alivepdf.pdf.PDF;

public class ExportToCSVEvent extends Event {

	public static const EXPORT_TO_CSV:String = "_exportar_a_CSV_";

	private var _byteArray:ByteArray;

	private var _fileName:String;
	
	public function ExportToCSVEvent(type:String, byteArray:ByteArray, fileName:String) {
		super(type, true, true);
		
		this._byteArray = byteArray;
		this._fileName = fileName;
	}


	public function get fileName():String {
		return _fileName;
	}

	public function set fileName(value:String):void {
		_fileName = value;
	}

	public function get byteArray():ByteArray {
		return _byteArray;
	}

	public function set byteArray(value:ByteArray):void {
		_byteArray = value;
	}


}
}
