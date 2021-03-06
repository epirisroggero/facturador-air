//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.ui.expediciones {

import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.dto.AgendaTareaDTO;
import biz.fulltime.model.AgendaTarea;

import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.printing.PrintJob;
import flash.printing.PrintJobOptions;
import flash.printing.PrintJobOrientation;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.collections.ArrayCollection;
import mx.formatters.DateFormatter;

import spark.formatters.DateTimeFormatter;

public class PrintJobTareasAvanzado {

	private var _tareas:ArrayCollection;

	private var uiOpt:PrintJobOptions;

	private var sheet:Sprite;

	public function PrintJobTareasAvanzado() {
	}

	public function get tareas():ArrayCollection {
		return _tareas;
	}

	public function set tareas(value:ArrayCollection):void {
		_tareas = value;
	}

	public function imprimirTareas():void {
		printOnePerPage();
	}

	private function createSheet(sheet:Sprite, page:int):void {
		// Create page size
		sheet.graphics.lineStyle(1, 0xffffff);
		sheet.graphics.drawRect(0, 0, 1096, 858);

		var dtf:DateTimeFormatter = new DateTimeFormatter();
		dtf.dateTimePattern = "dd/MM/yyyy";

		var X:int = 10;
		var Y:int = 16;

		if (page == 1) {
			sheet.addChild(createText("Expediciones", {x:X, y:Y, width:460, height:28, fontSize:16, align:'left'}));
		}
		sheet.addChild(createText("Página " + page, {x:500, y:790, width:96, height:28, fontSize:12, align:'left'}));
		Y += 64;

		var rowHeight:int = 12;
		var row:Number = 0;

		if (tareas && tareas.length > 0) {
			X = 10;

			sheet.addChild(createText(" Prioridad", {x:X + 2, y:Y, width:43, height:rowHeight + 2, fontSize:8, align:'center', border:true}));
			sheet.addChild(createText(" Fecha", {x:X += 45, y:Y, width:45, height:rowHeight + 2, fontSize:8, align:'center', border:true}));
			sheet.addChild(createText(" Contacto", {x:X += 45, y:Y, width:200, height:rowHeight + 2, fontSize:8, align:'left', border:true}));
			sheet.addChild(createText(" Dirección", {x:X += 200, y:Y, width:320, height:rowHeight + 2, fontSize:8, align:'left', border:true}));
			sheet.addChild(createText(" Teléfono", {x:X += 320, y:Y, width:180, height:rowHeight + 2, fontSize:8, align:'left', border:true}));
			sheet.addChild(createText(" Tarea", {x:X += 180, y:Y, width:150, height:rowHeight + 2, fontSize:8, align:'left', border:true}));
			sheet.addChild(createText(" Solicitante", {x:X += 150, y:Y, width:90, height:rowHeight + 2, fontSize:8, align:'left', border:true}));

			Y += rowHeight + 2;

			var dF:DateFormatter = new DateFormatter();
			dF.formatString = "DD-MM-YYYY";

			row = 0;
			for (var j:int = ((page-1) * 25); ((j < (page * 25)) && (j < tareas.length)); j++) {
				var tarea:AgendaTareaDTO = tareas.getItemAt(j) as AgendaTareaDTO;
				X = 10;

				sheet.addChild(createText(tarea.prioridad, {x:X, y:Y, width:45, height:rowHeight, fontSize:8, align:'center'}));
				sheet.addChild(createText(tarea.fechaHora ? dF.format(tarea.fechaHora) : "", {x:X += 45, y:Y, width:45, height:rowHeight, fontSize:8, align:'center'}));
				sheet.addChild(createText(tarea.ctoNombre ? tarea.ctoNombre.toUpperCase() : "", {x:X += 45, y:Y, width:200, height:rowHeight, fontSize:8, align:'left'}));
				sheet.addChild(createText(tarea.ctoDireccion ? tarea.ctoDireccion.toUpperCase() : "", {x:X += 200, y:Y, width:320, height:rowHeight, fontSize:8, align:'left'}));
				sheet.addChild(createText(tarea.ctoTelefono, {x:X += 320, y:Y, width:180, height:rowHeight, fontSize:8, align:'left'}));
				sheet.addChild(createText(tarea.tarea ? tarea.tarea.toUpperCase() : "", {x:X += 180, y:Y, width:150, height:rowHeight, fontSize:8, align:'left'}));
				sheet.addChild(createText(tarea.usuSolicitante ? tarea.usuSolicitante.toUpperCase() : "", {x:X += 150, y:Y, width:90, height:rowHeight,
						fontSize:8, align:'left'}));

				row++;
				Y += rowHeight;

				var descripcion:String = tarea.descripcion;
				if (descripcion) {
					descripcion = nl2br(tarea.descripcion);
				}

				row++;
				sheet.addChild(createText(descripcion, {x:15, y:Y, width:1020, height:rowHeight, fontSize:8, align:'left'}));
				sheet.graphics.lineStyle(.5, 0xA0A0A0);
				sheet.graphics.drawRect(12, Y - rowHeight, 1028, (rowHeight * 2));

				Y += rowHeight;
			}

			X = 10;
			sheet.graphics.lineStyle(1, 0xFFFFFF);
			sheet.graphics.drawRect(X, Y - (row * rowHeight), 1042, (rowHeight * row) + 5);
		}

	}

	public function nl2br(str:String):String {
		return str.replace(new RegExp("[\n\r]", "g"), " | ");
	}

	private function createText(text:String, propValue:Object):TextField {
		var txt:TextField = new TextField();
		txt.text = text != null ? text : "";

		// Propiedades del TextField
		txt.width = propValue.width;
		txt.height = propValue.height;
		txt.x = propValue.x;
		txt.y = propValue.y;

		var txtFormat:TextFormat = new TextFormat();
		switch (propValue.align) {
			case "left":
				txtFormat.align = TextFormatAlign.LEFT;
				break;
			case "center":
				txtFormat.align = TextFormatAlign.CENTER;
				break;
			case "rigth":
				txtFormat.align = TextFormatAlign.RIGHT;
				break;
		}

		txtFormat.size = propValue.fontSize;
		txtFormat.font = "Arial";

		// Set Format
		txt.setTextFormat(txtFormat);

		txt.border = propValue.border;
		txt.wordWrap = false;

		return txt;
	}

	private function printOnePerPage():void {
		if (GeneralOptions.getInstance().opciones.impresoras.otros == null && GeneralOptions.getInstance().opciones.impresoras.otros == "") {
			throw new Error("No hay impresora por defecto definida. Ir a Configuración > Preferencias > Impresoras");
		}

		var pj:PrintJob = new PrintJob();
		pj.printer = GeneralOptions.getInstance().opciones.impresoras.otros;
		pj.orientation = PrintJobOrientation.LANDSCAPE;
		var pagesToPrint:uint = 0;
		if (pj.start2(null, false)) {
			if (pj.orientation == PrintJobOrientation.PORTRAIT) {
				throw new Error("La Orientación de página en la Impresora debe estar en Horizontal.");
			}
			
			var count:Number = tareas.length;
			var pages:int = count / 25;
			var resto:int = count % 25; 
			if (resto > 0) {
				pages++;
			}
			for (var page:int = 1; page <= pages; page++) {
				sheet = new Sprite();
				createSheet(sheet, page);
	
				sheet.width = pj.pageWidth;
				sheet.height = pj.pageHeight;
	
				try {
					pj.addPage(sheet, new Rectangle(0, 0, 1096, 858));
				} catch (e:Error) {
					// do nothing
				}
			}
		
			pj.send();
		}
	}


}
}
