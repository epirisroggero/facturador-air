//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

import mx.collections.ArrayCollection;

[RemoteClass(alias = "uy.com.tmwc.facturator.dto.TableReportResult")]
public class TableReportResult {

	public var rowsWithData:Object;

	private var _columns:Array;

	public function TableReportResult():void {
	}

	public function get columns():Array {
		return _columns;
	}

	public function set columns(columns:Array):void {
		_columns = columns;
	}
}
}
