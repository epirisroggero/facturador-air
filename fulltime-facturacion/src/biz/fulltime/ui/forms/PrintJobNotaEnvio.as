//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------
package biz.fulltime.ui.forms {

import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.model.Documento;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.printing.PrintJob;
import flash.printing.PrintJobOptions;
import flash.printing.PrintJobOrientation;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

import mx.controls.Alert;

import org.alivepdf.fonts.FontFamily;

public class PrintJobNotaEnvio extends Sprite {

	private var _factura:Documento;

	private var pj:PrintJob;

	private var uiOpt:PrintJobOptions;

	private var _current:int = 1;

	private var url:String = "/assets/general/NotaEnvio.png";

	private var loader:Loader = new Loader();

	private var sheet1:Sprite;
	
	


	public function PrintJobNotaEnvio() {
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	}

	public function print():void {
		var request:URLRequest = new URLRequest(url);
		loader.load(request);
	}


	private function completeHandler(event:Event):void {
		printFourPerPage();
	}

	private function ioErrorHandler(event:IOErrorEvent):void {
		Alert.show("Unable to load the image: " + url);
	}

	public function get factura():Documento {
		return _factura;
	}

	public function set factura(value:Documento):void {
		_factura = value;
	}

	private var IMAGE_W:int = 420;

	private var IMAGE_H:int = 280;

	private function createSheet(sheet:Sprite, imageOnly:Boolean = false):void {
		var picture:Bitmap = Bitmap(loader.content);
		var bitmap:BitmapData = picture.bitmapData;

		var scaleX:Number = IMAGE_W / bitmap.width;
		var scaleY:Number = IMAGE_H / bitmap.height;
		
		var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
		var matrix:Matrix = new Matrix();
		matrix.scale(scaleX, scaleY);

		var frame:Sprite = new Sprite();
		frame.graphics.lineStyle(1, 0xFFFFFF);
		frame.graphics.beginBitmapFill(bitmap, matrix, true);
		frame.graphics.drawRect(0, 0, IMAGE_W, IMAGE_H);
		frame.graphics.endFill();

		sheet.addChild(frame);

		var localidad:String = "";
		if (factura.localidad) {
			localidad = factura.localidad;
		} else if (factura.cliente) {
			localidad = factura.cliente.contacto.ctoLocalidad;
		}

		var departamento:String = "";
		if (factura.departamento) {
			departamento = factura.departamento;
		}

		var agencia:String = "";
		var dirEntrega:String = "";
		if (factura.dirEntrega && factura.dirEntrega.length > 0) {
			dirEntrega = factura.dirEntrega;
		} else if (factura.cliente) {
			if (factura.cliente.lugarEntrega && factura.cliente.lugarEntrega.length > 0) {
				dirEntrega = factura.cliente.lugarEntrega;
			} else {
				dirEntrega = factura.cliente.contacto.ctoDireccion;
			}
		}

		if (factura.agencia && factura.agencia.length > 0) {
			agencia = factura.agencia;
		} else if (factura.cliente) {
			if (factura.cliente.agencia && factura.cliente.agencia.length > 0) {
				agencia = factura.cliente.agencia;
			} else {
				agencia = factura.agencia;
			}
		}

		if (!imageOnly) {
			var strCliente:String = factura.cliente ? factura.cliente.nombre.toUpperCase() : "";
			var strLocalidad:String = localidad ? localidad.toUpperCase() : "";
			var strDireccion:String = dirEntrega ? dirEntrega.toUpperCase() : "";
			var strDepartamento:String = departamento ? departamento.toUpperCase() : "";
			var strAgencia:String = agencia ? agencia.toUpperCase() : "";
			var strChofer:String = factura.chofer ? factura.chofer.toUpperCase() : "";
			var strBultos:String = String(_current) + " / " + String(factura.cantidadBultos);
			var strTelefono:String = factura.telefono ? factura.telefono : "";
			var strOrdenCompra:String = factura.ordenCompra ? factura.ordenCompra : "";
			var strNumeroFactura:String = factura.serie + factura.numero;
			var strEntrega:String = factura.entrega ? factura.entrega.nombre.toUpperCase() : "";

			// Agregar campos de la nota de envio.
			sheet.addChild(createText(strCliente, {x:72, y:96, width:190, height:18, fontSize:10, align:'left'}));
			sheet.addChild(createText(strDireccion, {x:85, y:122, width:180, height:24, fontSize:10, align:'left'}));
			sheet.addChild(createText(strLocalidad, {x:72, y:150, width:190, height:18, fontSize:10, align:'left'}));
			sheet.addChild(createText(strAgencia, {x:72, y:178, width:190, height:18, fontSize:10, align:'left'}));
			sheet.addChild(createText(strChofer, {x:72, y:205, width:190, height:18, fontSize:10, align:'left'}));

			sheet.addChild(createText(strEntrega, {x:340, y:96, width:70, height:18, fontSize:10, align:'left'}));
			sheet.addChild(createText(strTelefono, {x:334, y:122, width:75, height:28, fontSize:10, align:'left'}));
			sheet.addChild(createText(strDepartamento, {x:318, y:150, width:92, height:18, fontSize:10, align:'left'}));
			sheet.addChild(createText(strBultos, {x:325, y:178, width:85, height:18, fontSize:10, align:'left'}));
			sheet.addChild(createText(strNumeroFactura, {x:340, y:205, width:70, height:18, fontSize:10, align:'left'}));
		
		}

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
		txtFormat.font = FontFamily.COURIER
		// Set Format
		txt.setTextFormat(txtFormat);


		txt.border = false;
		txt.wordWrap = true;

		return txt;
	}

	private function printFourPerPage():void {
		if (GeneralOptions.getInstance().opciones.impresoras.notasEnvio == null && GeneralOptions.getInstance().opciones.impresoras.notasEnvio == "") {
			throw new Error("No hay impresora por defecto definida. Ir a Configuración > Preferencias > Impresoras");
		}
		var pj:PrintJob = new PrintJob();
		pj.printer = GeneralOptions.getInstance().opciones.impresoras.notasEnvio;
		pj.orientation = PrintJobOrientation.LANDSCAPE;
	
		var pagesToPrint:uint = 0;
		if (pj.start2(null, false)) {
			var i:int = 1;
			for (; i <= factura.cantidadBultos; i++) {
				_current = i;

				var sheet:Sprite = new Sprite();
				createSheet(sheet);

				try {
					pj.addPage(sheet, new Rectangle(0, 0, pj.pageWidth - 10, pj.pageHeight));
					pagesToPrint++;
				} catch (e:Error) {
					trace(e.message.toString());
					// do nothing
				}

			}
		}

		if (pagesToPrint > 0) {
			pj.send();
		}
	}


}
}
