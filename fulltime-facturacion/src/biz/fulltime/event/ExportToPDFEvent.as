//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import biz.fulltime.dto.EFacturaResult;

import flash.events.Event;
import flash.utils.ByteArray;

import org.alivepdf.pdf.PDF;

public class ExportToPDFEvent extends Event {

	public static const EXPORT_TO_PDF:String = "_exportar_a_PDF_";

	public static const CREATE_EFACTURA:String = "_eFactura.info";

	private var _pdf:PDF;

	private var _fileName:String;
	
	private var _openPDF:Boolean;

	private var _eFactura:EFacturaResult;

	public function ExportToPDFEvent(type:String, pdf:PDF = null) {
		super(type, true, true);

		this._pdf = pdf;
	}


	public function get openPDF():Boolean {
		return _openPDF;
	}

	public function set openPDF(value:Boolean):void {
		_openPDF = value;
	}

	public function get eFactura():EFacturaResult {
		return _eFactura;
	}

	public function set eFactura(value:EFacturaResult):void {
		_eFactura = value;
	}

	public function get fileName():String {
		return _fileName;
	}

	public function set fileName(value:String):void {
		_fileName = value;
	}

	public function get pdf():PDF {
		return _pdf;
	}

	public function set pdf(value:PDF):void {
		_pdf = value;
	}
}
}
