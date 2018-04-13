//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.dto {

import mx.collections.ArrayCollection;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.dto.ReportParameters")]
public class ReportParameters {

	public var parameters:Object;

	public var codigo:String;

	public function ReportParameters() {
	}
}
}
