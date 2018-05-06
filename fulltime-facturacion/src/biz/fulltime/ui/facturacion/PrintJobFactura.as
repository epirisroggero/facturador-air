//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.ui.facturacion {

import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.conf.ServerConfig;
import biz.fulltime.model.Comprobante;
import biz.fulltime.model.Contacto;
import biz.fulltime.model.Documento;
import biz.fulltime.model.LineaDocumento;
import biz.fulltime.model.ParticipacionVendedor;
import biz.fulltime.model.Usuario;
import biz.fulltime.ui.forms.FrmEMail;

import com.adobe.images.JPGEncoder;
import com.adobe.images.PNGEncoder;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
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
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import flashx.textLayout.container.ISandboxSupport;

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.graphics.ImageSnapshot;
import mx.graphics.codec.PNGEncoder;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;
import mx.utils.LoaderUtil;

import org.alivepdf.fonts.FontFamily;

import spark.components.TitleWindow;
import spark.formatters.DateTimeFormatter;
import spark.formatters.NumberFormatter;

import util.CatalogoFactory;
import util.ErrorPanel;
import util.PNGDecoder;

public class PrintJobFactura {

	public static const VIA_CLIENTE:String = "CLIENTE";

	public static const VIA_COBRANZA:String = "COBRANZA";

	public static const VIA_DGI:String = "DGI";

	private var _documento:Documento;

	private var pj:PrintJob;

	private var uiOpt:PrintJobOptions;

	private var sheet1:Sprite;

	private var _via:String = VIA_CLIENTE;

	private var _print_vias:Array = [VIA_CLIENTE, VIA_COBRANZA];

	private var url_factura:String = "http://localhost:8180/facturador/assets/general/Factura.jpg";

	private var url_ordenCompra:String = "http://localhost:8180/facturador/assets/general/OrdenDeCompra.jpg";

	private var url_cotizacion:String = "http://localhost:8180/facturador/assets/general/Cotizacion.jpg";

	private var url_importacion:String = "http://localhost:8180/facturador/assets/general/ImportacionDeCompra.png";

	private var loader:Loader = new Loader();

	private var frame:Sprite = new Sprite();

	private var isEMail:Boolean = false;

	private var _automatic:Boolean = false;

	public var forzarRemitos:Boolean = false;
	
	public var printNotasInterlineadas:Boolean = true;

	private var frameQR:Sprite = new Sprite();

	public var codigoQRLoader:Loader = new Loader();

	public function PrintJobFactura(loadImage:Boolean = true) {
		if (loadImage) {
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
	}

	public function get print_vias():Array {
		return _print_vias;
	}

	public function set print_vias(value:Array):void {
		_print_vias = value;
	}

	public function createSMSImage(automatic:Boolean = false):void {
		isEMail = true;
		_automatic = automatic;

		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandlerMail);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

		var request:URLRequest = null;
		if (_documento.esCotizacionDeVenta || _documento.esOrdenDeVenta || _documento.comprobante.codigo == "1" || _documento.comprobante.codigo == "10") {
			request = new URLRequest(url_cotizacion);
		} else if (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111") {
			request = new URLRequest(url_ordenCompra);
		} else if (_documento.comprobante.esImportacion()) {
			request = new URLRequest(url_importacion);
		} else {
			request = new URLRequest(url_factura);
		}

		loader.load(request);

	}

	private function completeHandlerMail(event:Event):void {
		_via = VIA_CLIENTE;

		sheet1 = new Sprite();
		if (_documento.codigoQR) {
			loadCodigoQR();
		} else {
			createSheetMM();
		}

	}

	public function loadCodigoQR():void {
		codigoQRLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCodigoQRLoaderComplete);
		codigoQRLoader.loadBytes(_documento.codigoQR);
	}

	private function onCodigoQRLoaderComplete(event:Event):void {
		var loaderQR:Loader = event.target.loader as Loader;

		var picture:Bitmap = Bitmap(loaderQR.content);
		var bitmap:BitmapData = picture.bitmapData;

		var matrix:Matrix = new Matrix();
		matrix.scale(0.9, 0.9);

		frameQR.graphics.beginBitmapFill(bitmap, matrix, false);
		frameQR.graphics.lineStyle(1, 0xffffff);
		frameQR.graphics.drawRect(0, 0, 132, 132);
		frameQR.graphics.endFill();

		createSheetMM();

	}

	private function createSheetMM():void {
		createSheetSMS(sheet1);

		if (_automatic) {
			var imageBitmapData:BitmapData = ImageSnapshot.captureBitmapData(sheet1);

			var enc:JPGEncoder = new JPGEncoder();
			var byteArray:ByteArray = enc.encode(imageBitmapData);
			byteArray.position = 0;

			var _selectedContact:Contacto = _documento.cliente.contacto;

			var email1:String = _selectedContact.ctoEmail1;
			var email2:String = _selectedContact.ctoEmail2;

			var hasEmail:Boolean = false;
			var addresses:Array = new Array();
			if (email1 && email1.length > 3) {
				addresses[addresses.length] = email1;
				hasEmail = true;
			} else if (email2 && email2.length > 3) {
				addresses[addresses.length] = email2;
				hasEmail = true;
			}

			if (hasEmail) {
				var remObj:RemoteObject = new RemoteObject();
				remObj.destination = "CreatingRpc";
				remObj.channelSet = ServerConfig.getInstance().channelSet;

				remObj.addEventListener(ResultEvent.RESULT, resultSendEMail);
				remObj.addEventListener(FaultEvent.FAULT, handleFault);
				remObj.showBusyCursor = false;
				
				var comprobante:String = _documento.comprobante.nombre;

				remObj.sendEmail(addresses, "FULLTIME - " + comprobante.toUpperCase(), "", byteArray);
			}

		} else {
			var parent:Sprite;

			var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
			// no types so no dependencies
			var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
			if (mp && mp.useSWFBridge()) {
				parent = Sprite(sm.getSandboxRoot());
			} else {
				parent = Sprite(FlexGlobals.topLevelApplication);
			}

			var mailWindow:TitleWindow = new TitleWindow();
			mailWindow.width = 1024;
			mailWindow.height = 600;
			mailWindow.title = "Envío de correo";
			mailWindow.visible = true;

			var emailPnl:FrmEMail = new FrmEMail();
			if (documento.cliente) {
				emailPnl.cliente = documento.cliente;
			}
			if (documento.proveedor) {
				emailPnl.proveedor = documento.proveedor;
			}
			
			var comprobante:String = documento.comprobante.nombre;
			
			emailPnl.asunto = "FULLTIME - " + comprobante.toUpperCase();
			emailPnl.takeSnapshot(sheet1);
			emailPnl.addEventListener(CloseEvent.CLOSE, function():void {
					PopUpManager.removePopUp(mailWindow);
					mailWindow = null;
				});

			PopUpManager.addPopUp(mailWindow, parent, true);
			PopUpManager.centerPopUp(mailWindow);

			mailWindow.addElement(emailPnl);
			mailWindow.addEventListener(CloseEvent.CLOSE, closeHandlerEmail);
		}

	}

	private function resultSendEMail(event:ResultEvent):void {
		var result:String = event.result as String;
		var resultXML:XML = new XML(result);

		var parent:Sprite;

		var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		// no types so no dependencies
		var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		if (mp && mp.useSWFBridge()) {
			parent = Sprite(sm.getSandboxRoot());
		} else {
			parent = Sprite(FlexGlobals.topLevelApplication);
		}

		var error:ErrorPanel = new ErrorPanel();
		error.backgroundAlpha = .75;

		if (resultXML.state == "true") {
			error.showButtons = false;
			error.type = 2;
			error.errorText = "El correo se ha enviado correctamente.";

			PopUpManager.addPopUp(error, parent, true);
			PopUpManager.centerPopUp(error);

			setTimeout(function():void {
					PopUpManager.removePopUp(error)
				}, 500);
		} else {
			error.showButtons = true;
			error.type = 0;
			error.errorText = "Error al enviar correo.";
			error.detailsText = resultXML.message[0].toString();

			PopUpManager.addPopUp(error, parent, true);
			PopUpManager.centerPopUp(error);
		}

	}

	public function handleFault(event:FaultEvent):void {
		trace(event.message.toString());
	}

	private function closeHandlerEmail(event:Event):void {
		var helpWindow:TitleWindow = event.target as TitleWindow;
		helpWindow.removeEventListener(CloseEvent.CLOSE, closeHandlerEmail);
		PopUpManager.removePopUp(helpWindow);
		helpWindow = null;
	}

	private function completeHandler(event:Event):void {
		printOnePerPage();
	}

	public function print():void {
		if (_documento.codigoQR) {
			codigoQRLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCodigoQRLoaderCompleteForPrint);
			codigoQRLoader.loadBytes(_documento.codigoQR);
		} else {
			init();
		}
	}

	private function onCodigoQRLoaderCompleteForPrint(event:Event):void {
		var loaderQR:Loader = event.target.loader as Loader;

		var picture:Bitmap = Bitmap(loaderQR.content);
		var bitmap:BitmapData = picture.bitmapData;

		var matrix:Matrix = new Matrix();
		matrix.scale(0.6, 0.6);

		frameQR.graphics.beginBitmapFill(bitmap, matrix, false);
		frameQR.graphics.lineStyle(1, 0xffffff);
		frameQR.graphics.drawRect(0, 0, 84, 84);
		frameQR.graphics.endFill();

		init();
	}


	private function init():void {
		var request:URLRequest = null;
		if (_documento.esCotizacionDeVenta) {
			request = new URLRequest(url_cotizacion)
		} else if (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111") {
			request = new URLRequest(url_ordenCompra);
		} else if (_documento.comprobante.esImportacion()) {
			request = new URLRequest(url_importacion);
		} else {
			request = new URLRequest(url_factura);
		}

		loader.load(request);
	}

	private function ioErrorHandler(event:IOErrorEvent):void {
		Alert.show("No se pudo cargar la imagen de la factura");

	}

	public function get via():String {
		return _via;
	}

	public function set via(value:String):void {
		_via = value;
	}

	public function get documento():Documento {
		return _documento;
	}

	public function set documento(value:Documento):void {
		_documento = value;
	}

	public function disguise(value:BigDecimal):String {
		if (value) {
			var str:String = String(value.setScale(0, MathContext.ROUND_HALF_DOWN));
			var b:String = new String();
			for (var i:int = 0; i < str.length; i++) {
				b += str.charAt(str.length - i - 1);
			}
			return b;
		}
		return "";
	}

	private function createSheet(sheet:Sprite):void {
		var picture:Bitmap = Bitmap(loader.content);
		var bitmap:BitmapData = picture.bitmapData;

		var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
		var matrix:Matrix = new Matrix();
		matrix.scale((626 / bitmap.width), (557 / bitmap.height));

		frame.graphics.lineStyle(1, 0xff0000);
		if (isEMail || print_vias.length == 1 || (_documento.esRemito() && !_documento.esCotizacionDeVenta && !_documento.esOrdenDeVenta)) {
			frame.graphics.beginBitmapFill(bitmap, matrix, true);
		}
		frame.graphics.drawRect(0, 0, 626, 557);
		frame.graphics.endFill();
		
		sheet.addChild(frame);

		// Agregar campos de la factura.				
		sheet.addChild(createText(documento.CAEnom ? documento.CAEnom : documento.comprobante.nombre, {x:356, y:32, width:124, height:18, fontSize:10, align:'center'}));
		sheet.addChild(createText((documento.serie ? documento.serie : "") + " " + (documento.numero ? documento.numero : ""), {x:492, y:20, width:96, height:20, fontSize:11, align:'center'}));

		if (documento.CAEnom) {
			if (documento.comprobante.isCredito()) {
				if (documento.comprobante.codigo == "7" || documento.comprobante.codigo == "8" || documento.comprobante.codigo == "9") {
					sheet.addChild(createText(documento.comprobante.nombre, {x:356, y:44, width:124, height:18, fontSize:9, align:'center'}));
				} else {
					sheet.addChild(createText("CRÉDITO", {x:356, y:44, width:124, height:18, fontSize:9, align:'center'}));
				}					
				
			} else {
				sheet.addChild(createText("CONTADO", {x:356, y:44, width:124, height:18, fontSize:9, align:'center'}));
			}
		}
		
		var dtf:DateTimeFormatter = new DateTimeFormatter();
		dtf.dateTimePattern = "dd/MM/yy";

		sheet.addChild(createText(dtf.format(documento.fechaDoc), {x:496, y:60, width:96, height:14, fontSize:8, align:'center'}));

		if (documento.razonSocial && documento.razonSocial != "") {
			sheet.addChild(createText(documento.razonSocial, {x:32, y:65, width:236, height:14, fontSize:8, align:'left'}));
		} else {
			if (documento.cliente) {
				sheet.addChild(createText(documento.cliente.nombre, {x:32, y:65, width:242, height:14, fontSize:8, align:'left'}));
			} else if (documento.proveedor) {
				sheet.addChild(createText(documento.proveedor.nombre, {x:32, y:65, width:242, height:14, fontSize:8, align:'left'}));
			}
		}
		if (documento.cliente) {
			sheet.addChild(createText(documento.cliente.codigo, {x:338, y:65, width:42, height:14, fontSize:8, align:'left'}));
		} else if (documento.proveedor) {
			sheet.addChild(createText(documento.proveedor.codigo, {x:338, y:65, width:42, height:14, fontSize:8, align:'left'}));
		}

		sheet.addChild(createText(documento.getAgencia(), {x:413, y:65, width:67, height:14, fontSize:8, align:'left'}));
		sheet.addChild(createText((documento.direccion ? documento.direccion : "No Tiene") + (documento.getLocalidad() ? " | " + documento.getLocalidad().toUpperCase() : "") + ((documento.departamento && !(documento.getLocalidad() && documento.departamento.toUpperCase() == documento.getLocalidad().toUpperCase())) ? " | " + documento.departamento : ""), 
			{x:32, y:82, width:286, height:14, fontSize:8,
				align:'left'}));
		sheet.addChild(createText(documento.telefono, {x:338, y:82, width:142, height:14, fontSize:8, align:'left'}));

		var _comisiones:String = "";
		var first:Boolean = true;
		for each (var participacion:ParticipacionVendedor in documento.comisiones.participaciones) {
			if (participacion.vendedor) {
				var code:String = "";
				if (participacion.vendedor.codigo.length == 1) {
					code = "0" + participacion.vendedor.codigo;
				} else if (participacion.vendedor.codigo.length == 2) {
					code = participacion.vendedor.codigo;
				} else {
					code = participacion.vendedor.codigo.substring(participacion.vendedor.codigo.length - 2, participacion.vendedor.codigo.length);
				}
				_comisiones += (first ? "" : "-") + code + (participacion.porcentaje < 10 ? "0" + participacion.porcentaje : participacion.porcentaje);
				first = false;
			}
		}
		sheet.addChild(createText(_comisiones, {x:492, y:94, width:96, height:14, fontSize:8, align:'center'}));

		if (documento.esConsumoFinal()) {
			sheet.addChild(createText(documento.rut != null ? "CI " + documento.rut : "CONSUMO FINAL", {x:32, y:115, width:220, height:22, fontSize:11, align:'center'}));
		} else {
			if (documento.tipoDoc == "R") {
				sheet.addChild(createText(documento.rut != null ? documento.rut : "", {x:32, y:115, width:220, height:18, fontSize:11, align:'center'}));
			} else {
				sheet.addChild(createText(documento.rut != null ? "CI " + documento.rut : "", {x:32, y:115, width:220, height:18, fontSize:11, align:'center'}));
			}
		}

		sheet.addChild(createText(documento.ordenCompra, {x:322, y:122, width:82, height:14, fontSize:8, align:'center'}));
		sheet.addChild(createText(documento.cantidadBultos ? documento.cantidadBultos.toString() : "", {x:408, y:122, width:36, height:14, fontSize:8, align:'center'}));
		sheet.addChild(createText(GeneralOptions.getInstance().loggedUser.codigo, {x:452, y:122, width:36, height:14, fontSize:8, align:'center'}));

		sheet.addChild(createText(documento.entrega ? documento.entrega.codigo : "", {x:492, y:122, width:96, height:14, fontSize:8, align:'center'}));

		var XX:int = 46;
		var YY:int = 162;

		var simbolo:String = documento.moneda.simbolo;

		var nf:NumberFormatter = new NumberFormatter();
		nf.setStyle("locale", "es_ES");
		nf.trailingZeros = true;
		nf.fractionalDigits = 2;

		var nf2:NumberFormatter = new NumberFormatter();
		nf2.setStyle("locale", "es_ES");
		nf2.trailingZeros = false;
		nf2.fractionalDigits = 2;

		var row:Number = 0;
		for each (var l:LineaDocumento in documento.lineas.lineas) {
			if (_via == "COBRANZA") {
				sheet.addChild(createText(disguise(l.getPorcentajeUtilidad()), {x:XX - 32, y:YY + 12 * row, width:32, height:12, fontSize:8, align:'left'})); // % de utilidad. Solo Vía Cobranza.
			}
			sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:32, y:YY + 12 * row, width:102, height:12, fontSize:8, align:'left'}));
			if (l.getCantidad() != BigDecimal.ZERO) {
				sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:136, y:YY + 12 * row, width:36, height:12, fontSize:8, align:'center'}));
			} else {
				sheet.addChild(createText("", {x:136, y:YY + 12 * row, width:36, height:12, fontSize:8, align:'center'}));
			}
			sheet.addChild(createText(l.concepto, {x:178, y:YY + 12 * row, width:220, height:12, fontSize:8, align:'left'}));

			sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:416, y:YY + 12 * row, width:52, height:12, fontSize:8, align:'rigth'}));

			var descuento:int = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
			if (descuento > 0) {
				sheet.addChild(createText(descuento + "%", {x:472, y:YY + 12 * row, width:32, height:12, fontSize:8, align:'rigth'}));
			} else {
				sheet.addChild(createText("", {x:472, y:YY + 12 * row, width:32, height:12, fontSize:8, align:'rigth'}));
			}
			sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:510, y:YY + 12 * row, width:78, height:12, fontSize:8, align:'rigth'}));

			row++;

			if (l.notas && printNotasInterlineadas) {
				var notas:String = l.notas;
				if (notas) {
					notas = nl2br(l.notas);
				}
				sheet.addChild(createText(notas, {x:XX, y:YY + 12 * row, width:564, height:12, fontSize:8, align:'left'}));
				row++;
			}
		}

		var byteArray:ByteArray = _documento.codigoQR;
		if (byteArray) {
			frameQR.x = 28;
			frameQR.y = 458;

			sheet.addChild(frameQR);
		}

		if (documento.CAEnro) {
			var YY_CAE = 460;
			sheet.addChild(createText("Código seguridad: " + documento.codSeguridadCFE, {x:115, y:YY_CAE, width:126, height:18, fontSize:9, align:'left'}));
			sheet.addChild(createText("Res. 2939/2016 - IVA al día", {x:115, y:YY_CAE = YY_CAE + 14, width:130, height:18, fontSize:9, align:'left'}));
			sheet.addChild(createText("Puede verificar comprobante en", {x:115, y:YY_CAE = YY_CAE + 14, width:126, height:18, fontSize:8, align:'left'}));
			if (!documento.esConsumoFinal()) {
				sheet.addChild(createText("www.efactura.dgi.gub.uy", {x:115, y:YY_CAE = YY_CAE + 12, width:126, height:18, fontSize:9, align:'left'}));
			} else {
				sheet.addChild(createText("www.efactura.info", {x:115, y:YY_CAE = YY_CAE + 12, width:126, height:18, fontSize:9, align:'left'}));
			}
			sheet.addChild(createText("Nro CAE: " + documento.CAEnro, {x:115, y:YY_CAE = YY_CAE + 14, width:126, height:18, fontSize:9, align:'left'}));
			sheet.addChild(createText("Rango: " + documento.CAEdesde + " - " + documento.CAEhasta + "  Serie: " + documento.CAEserie, {x:115, y:YY_CAE = YY_CAE + 14, width:126, height:18, fontSize:9, align:'left'}));
		}

		sheet.addChild(createText((documento.planPagos != null ? documento.planPagos.nombre : (documento.condicion ? documento.condicion.nombre : "")), {x:38, y:432, width:202, height:20, fontSize:10, align:'center'}));

		var YY_TOTALES:int = 5;
		
		sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:338, y:YY_TOTALES + 428, width:76, height:14, fontSize:8, align:'center'}));
		sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:425, y:YY_TOTALES + 428, width:76, height:14, fontSize:8, align:'center'})); // Sub total Neto
		sheet.addChild(createText(simbolo + " " + nf.format(documento.iva), {x:512, y:YY_TOTALES + 428, width:76, height:14, fontSize:8, align:'center'}));

		sheet.addChild(createText(simbolo + " " + nf.format(documento.total), {x:508, y:YY_TOTALES + 472, width:76, height:16, fontSize:10, align:'center'}));

		sheet.addChild(createText((documento.notas != null ? documento.notas : ""), {x:258, y:YY_TOTALES + 468, width:240, height:32, fontSize:8, align:'left'}));

		if (_via == "COBRANZA") {
			sheet.addChild(createText(disguise(documento.getUtilidadEstimada()), {x:12, y:YY_TOTALES + 420, width:40, height:14, fontSize:8, align:'left'}));
		}
		sheet.addChild(createText(documento.moneda.nombre.toUpperCase(), {x:500, y:YY_TOTALES + 508, width:82, height:14, fontSize:8, align:'center'}));

		sheet.addChild(createText(_via, {x:498, y:YY_TOTALES + 524, width:112, height:14, fontSize:8, align:'center'}));

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
		txtFormat.font = isEMail ? FontFamily.HELVETICA : FontFamily.COURIER;

		// Set Format
		txt.setTextFormat(txtFormat);

		txt.border = false;
		txt.wordWrap = false;

		return txt;
	}

	private function printOnePerPage():void {
//		var _printer:String;
//		if (!forzarRemitos && (!_documento.esRemito() || _documento.esCotizacionDeVenta || _documento.esOrdenDeVenta)) {
//			_printer = GeneralOptions.getInstance().opciones.impresoras.facturacion;
//		} else {
//			_printer = GeneralOptions.getInstance().opciones.impresoras.remitos;
//		}
//
//		if (_printer == null || _printer == "") {
//			throw new Error("No hay impresora definida. Ir a Configuración > Preferencias");
//		}
		
		sheet1 = new Sprite();
		if (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111" || _documento.comprobante.esImportacion()) {
			createSheetSMS(sheet1);
		} else {
			createSheet(sheet1);
		}
		
		var pj:PrintJob = new PrintJob();
		pj.start();
			
		var pagesToPrint:uint = 0;
		for each (var via:String in print_vias) {
			_via = via;

			sheet1.width = pj.pageWidth;
			sheet1.height = pj.pageHeight;

			try {
				pj.addPage(sheet1);
				pagesToPrint++;
			} catch (e:Error) {
				Alert.show(e.message.toString());
			}
		}
		if (pagesToPrint > 0) {
			pj.send();
		}
		

	}

	private function createSheetSMS(sheet:Sprite):void {
		var picture:Bitmap = Bitmap(loader.content);
		var bitmap:BitmapData = picture.bitmapData;

		var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
		var matrix:Matrix = new Matrix();
		if (!documento.comprobante.esImportacion()) {
			matrix.scale((939 / bitmap.width), (847 / bitmap.height));
		} else {
			matrix.scale((939 / bitmap.width), (1492 / bitmap.height));
		}

		frame.graphics.lineStyle(1, 0xffffff);
		if (isEMail || print_vias.length == 1 || (_documento.esRemito() && !_documento.esCotizacionDeVenta && !_documento.esOrdenDeVenta)) {
			frame.graphics.beginBitmapFill(bitmap, matrix, false);
		}
		if (!documento.comprobante.esImportacion()) {
			frame.graphics.drawRect(0, 0, 939, 847);
		} else {
			frame.graphics.drawRect(0, 0, 939, 1492);
		}
		frame.graphics.endFill();

		sheet.addChild(frame);

		var byteArray:ByteArray = _documento.codigoQR;
		if (byteArray) {
			frameQR.x = 62;
			frameQR.y = 690;

			sheet.addChild(frameQR);
		}

		var esOrdenCompra:Boolean = (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111");
		var esImportacion:Boolean = documento.comprobante.esImportacion();

		// Agregar campos de la factura.				
		if (!esOrdenCompra) {
			sheet.addChild(createText(documento.CAEnom ? documento.CAEnom : documento.comprobante.nombre, {x:544, y:52, width:171, height:18, fontSize:12, align:'center'}));
			
			if (documento.CAEnom) {
				if (documento.comprobante.isCredito()) {
					if (documento.comprobante.codigo == "7" || documento.comprobante.codigo == "8" || documento.comprobante.codigo == "9") {
						sheet.addChild(createText(documento.comprobante.nombre, {x:544, y:66, width:171, height:18, fontSize:10, align:'center'}));
					} else {
						sheet.addChild(createText("CRÉDITO", {x:544, y:66, width:171, height:18, fontSize:10, align:'center'}));
					}					
				} else {
					sheet.addChild(createText("CONTADO", {x:544, y:66, width:171, height:18, fontSize:10, align:'center'}));
				}
			}
		}
		sheet.addChild(createText((documento.serie != null ? documento.serie : "") + " " + (documento.numero != null ? documento.numero : ""), {x:750, y:36, width:129, height:18, fontSize:12, align:'center'}));

		var dtf:DateTimeFormatter = new DateTimeFormatter();
		dtf.dateTimePattern = "dd/MM/yy";

		sheet.addChild(createText(dtf.format(documento.fechaDoc), {x:750, y:90, width:129, height:18, fontSize:12, align:'center'}));

		if (documento.razonSocial && documento.razonSocial != "") {
			sheet.addChild(createText(documento.razonSocial, {x:esOrdenCompra || esImportacion ? 134 : 84, y:esOrdenCompra || esImportacion ? 108 : 105, width:363, height:18, fontSize:12, align:'left'}));
		} else {
			if (documento.cliente && documento.cliente.codigo != "") {
				sheet.addChild(createText(documento.cliente.nombre, {x:esOrdenCompra ? 134 : 84, y:esOrdenCompra ? 108 : 105, width:363, height:18, fontSize:12, align:'left'}));
			} else if (documento.proveedor) {
				sheet.addChild(createText(documento.proveedor.nombre, {x:esOrdenCompra || esImportacion ? 134 : 84, y:esOrdenCompra || esImportacion ? 108 : 105, width:363, height:18, fontSize:12, align:'left'}));
			}
		}
		if (documento.cliente) {
			sheet.addChild(createText(documento.cliente.codigo, {x:507, y:104, width:48, height:18, fontSize:12, align:'left'}));
		} else if (documento.proveedor) {
			sheet.addChild(createText(documento.proveedor.codigo, {x:507, y:esOrdenCompra || esImportacion ? 108 : 104, width:90, height:18, fontSize:12, align:'left'}));
		}

		sheet.addChild(createText(documento.getAgencia(), {x:622, y:105, width:108, height:18, fontSize:12, align:'left'}));
		sheet.addChild(createText((documento.direccion ? documento.direccion : "No Tiene") + (documento.getLocalidad() ? " | " + documento.getLocalidad().toUpperCase() : "") + ((documento.departamento && !(documento.getLocalidad() && documento.departamento.toUpperCase() == documento.getLocalidad().toUpperCase())) ? " | " + documento.departamento : ""), {x:esOrdenCompra || esImportacion ? 124 : 84,
				y:esOrdenCompra || esImportacion ? 133 : 134, width:383, height:18, fontSize:12, align:'left'}));
		sheet.addChild(createText(documento.telefono, {x:esOrdenCompra || esImportacion ? 624 : 507, y:esOrdenCompra || esImportacion ? 108 : 132, width:200, height:18, fontSize:12, align:'left'}));

		if (esOrdenCompra) {
			sheet.addChild(createText(documento.proveedor.contacto.ctoEmail1, {x:458, y:133, width:214, height:20, fontSize:12, align:'left'}));

			var codigo:String = documento.usuIdAut;
			for each (var user:Usuario in CatalogoFactory.getInstance().usuarios) {
				if (user.codigo == codigo) {
					sheet.addChild(createText(user.nombre, {x:185, y:172, width:214, height:20, fontSize:12, align:'left'}));
					break;
				}
			}

			var ordenDe:String;
			if (_documento.comprobante.codigo == "101") {
				ordenDe = "COMPRA MER. PLAZA";
			} else if (_documento.comprobante.codigo == "111") {
				ordenDe = "GASTO";
			} else {
				ordenDe = "IMPORTACIÓN";
			}
			sheet.addChild(createText(ordenDe, {x:750, y:142, width:129, height:20, fontSize:12, align:'center'}));

		}


		var _comisiones:String = "";
		var first:Boolean = true;
		for each (var participacion:ParticipacionVendedor in documento.comisiones.participaciones) {
			if (participacion.vendedor) {
				var code:String = "";
				if (participacion.vendedor.codigo.length == 1) {
					code = "0" + participacion.vendedor.codigo;
				} else if (participacion.vendedor.codigo.length == 2) {
					code = participacion.vendedor.codigo;
				} else {
					code = participacion.vendedor.codigo.substring(participacion.vendedor.codigo.length - 2, participacion.vendedor.codigo.length);
				}
				_comisiones += (first ? "" : "-") + code + (participacion.porcentaje < 10 ? "0" + participacion.porcentaje : participacion.porcentaje);
				first = false;
			}
		}
		sheet.addChild(createText(_comisiones, {x:750, y:141, width:130, height:18, fontSize:12, align:'center'}));

		if (!esOrdenCompra) {
			sheet.addChild(createText(documento.rut != null ? documento.rut : "", {x:78, y:183, width:326, height:18, fontSize:12, align:'center'}));
		}

		sheet.addChild(createText(documento.ordenCompra, {x:496, y:189, width:108, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(GeneralOptions.getInstance().loggedUser.codigo, {x:672, y:194, width:54, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(documento.entrega ? documento.entrega.codigo : "", {x:750, y:189, width:130, height:18, fontSize:12, align:'center'}));

		var XX:int = esOrdenCompra || esImportacion ? 74 : 84;
		var YY:int = 247;

		var simbolo:String = documento.moneda ? documento.moneda.simbolo : "";

		var nf:NumberFormatter = new NumberFormatter();
		nf.setStyle("locale", "es_ES");
		nf.trailingZeros = true;
		nf.fractionalDigits = 2;

		var nf2:NumberFormatter = new NumberFormatter();
		nf2.setStyle("locale", "es_ES");
		nf2.trailingZeros = false;
		nf2.fractionalDigits = 2;

		var row:Number = 0;
		for each (var l:LineaDocumento in documento.lineas.lineas) {
			sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:esOrdenCompra || esImportacion ? 50 : 68, y:YY + 18 * row, width:145, height:18, fontSize:12, align:'left'}));
			if (l.getCantidad() != BigDecimal.ZERO) {
				sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:esOrdenCompra || esImportacion ? 213 : 223, y:YY + 18 * row, width:54, height:18, fontSize:12, align:'center'}));
			} else {
				sheet.addChild(createText("", {x:esOrdenCompra || esImportacion ? 213 : 223, y:YY + 18 * row, width:36, height:18, fontSize:12, align:'center'}));

			}
			sheet.addChild(createText(l.concepto, {x:esOrdenCompra || esImportacion ? 272 : 288, y:YY + 18 * row, width:324, height:18, fontSize:12, align:'left'}));

			sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:esOrdenCompra || esImportacion ? 600 : 628, y:YY + 18 * row, width:78, height:18, fontSize:12, align:'rigth'}));

			var descuento:int = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
			if (descuento > 0) {
				sheet.addChild(createText(descuento + "%", {x:esOrdenCompra ? 692 : 702, y:YY + 18 * row, width:48, height:18, fontSize:12, align:'rigth'}));
			}
			sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:770, y:YY + 18 * row, width:117, height:18, fontSize:12, align:'rigth'}));

			row++;
		}
		if (!esImportacion) {
			sheet.addChild(createText((documento.planPagos != null ? documento.planPagos.nombre : (documento.condicion ? documento.condicion.nombre : "")), {x:67, y:656, width:305, height:18, fontSize:12, align:'center'}));
			
			if (documento.CAEnro) {
				var YY_CAE:int = 698;
				sheet.addChild(createText("Código seguridad: " + documento.codSeguridadCFE, {x:188, y:YY_CAE, width:190, height:22, fontSize:13, align:'left'}));
				sheet.addChild(createText("Res.2939/2016 - IVA al día", {x:188, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
				sheet.addChild(createText("Puede verificar comprobante en", {x:188, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
				if (!documento.esConsumoFinal()) {
					sheet.addChild(createText("www.efactura.dgi.gub.uy", {x:188, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
				} else {
					sheet.addChild(createText("www.efactura.info", {x:188, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
				}
				sheet.addChild(createText("Nro CAE: " + documento.CAEnro, {x:188, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
				sheet.addChild(createText("Rango: " + documento.CAEdesde + " - " + documento.CAEhasta + "  Serie: " + documento.CAEserie, {x:188, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
			}

			sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:507, y:656, width:124, height:18, fontSize:12, align:'center'}));
			sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:636, y:656, width:124, height:18, fontSize:12, align:'center'})); // Sub total Neto
			sheet.addChild(createText(simbolo + " " + nf.format(documento.iva), {x:763, y:656, width:124, height:18, fontSize:12, align:'center'}));

			sheet.addChild(createText((documento.notas != null ? documento.notas : ""), {x:396, y:724, width:339, height:46, fontSize:12, align:'left'}));

			sheet.addChild(createText(simbolo + " " + nf.format(documento.total), {x:763, y:726, width:124, height:18, fontSize:14, align:'center'}));

			sheet.addChild(createText(documento.moneda.nombre.toUpperCase(), {x:763, y:773, width:123, height:18, fontSize:12, align:'center'}));

			sheet.addChild(createText(_via, {x:747, y:808, width:168, height:18, fontSize:12, align:'center'}));
		} else {
			sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:636, y:1264, width:124, height:18, fontSize:12, align:'center'})); // Sub total Neto
			sheet.addChild(createText(simbolo + " " + nf.format(documento.iva), {x:763, y:1264, width:124, height:18, fontSize:12, align:'center'}));

			sheet.addChild(createText((documento.planPagos != null ? documento.planPagos.nombre : (documento.condicion ? documento.condicion.nombre : "")), {x:396, y:1328, width:339, height:18, fontSize:12, align:'left'}));
			sheet.addChild(createText((documento.notas != null ? documento.notas : ""), {x:396, y:1348, width:339, height:18, fontSize:12, align:'left'}));

			sheet.addChild(createText(simbolo + " " + nf.format(documento.total), {x:763, y:1342, width:124, height:18, fontSize:14, align:'center'}));


			sheet.addChild(createText(documento.moneda.nombre.toUpperCase(), {x:763, y:1392, width:123, height:18, fontSize:12, align:'center'}));

		}

	}


}
}
