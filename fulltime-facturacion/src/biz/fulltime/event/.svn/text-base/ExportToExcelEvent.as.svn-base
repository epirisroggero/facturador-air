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

public class ExportToExcelEvent extends Event {

	public static const EXPORT_TO_EXCEL:String = "_exportar_a_EXCEL_";

	private var _xls:ByteArray;

	private var _fileName:String;

	public function ExportToExcelEvent(type:String, xls:ByteArray, fileName:String) {
		super(type, true, true);

		this._xls = xls;

		this._fileName = fileName;
	}

	public function get xls():ByteArray {
		return _xls;
	}

	public function set xls(value:ByteArray):void {
		_xls = value;
	}

	public function get fileName():String {
		return _fileName;
	}

	public function set fileName(value:String):void {
		_fileName = value;
	}

}
}
