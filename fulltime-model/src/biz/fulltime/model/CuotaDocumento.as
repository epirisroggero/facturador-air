//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {
	

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.CuotaDocumento")]
public class CuotaDocumento {

	public var documento:Documento;
	public var numero:int;
	public var fecha:Date;
	public var importe:String;
	
	/* Number of milliseconds in a day. (1000 milliseconds per second * 60 seconds per minute * 60 minutes per hour * 24 hours per day) */
	private const MS_PER_DAY:uint = 1000 * 60 * 60 * 24;

	public function CuotaDocumento() {
	}
	
	public function getRetrasoDias(to:Date):int {		
		var date1_ms:Number = fecha.getTime();
		var date2_ms:Number = to.getTime();
		
		var difference_ms:Number = date2_ms - date1_ms;
		return Math.max(0, Math.floor(difference_ms/MS_PER_DAY));	
	}

}
}
