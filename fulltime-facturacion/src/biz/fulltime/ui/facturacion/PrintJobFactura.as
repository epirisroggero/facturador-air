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
import biz.fulltime.model.Cuponera;
import biz.fulltime.model.Documento;
import biz.fulltime.model.LineaCuponera;
import biz.fulltime.model.LineaDocumento;
import biz.fulltime.model.ParticipacionVendedor;
import biz.fulltime.model.Usuario;
import biz.fulltime.model.VinculoDocumentos;
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
import mx.styles.StyleManager;
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

	private var url_factura:String = "assets/general/Factura.jpg";
	
	private var url_recibo:String = "assets/general/Recibo.jpg";

	private var url_ordenCompra:String = "assets/general/OrdenDeCompra.jpg";

	private var url_cotizacion:String = "assets/general/Cotizacion.jpg";

	private var url_importacion:String = "assets/general/ImportacionDeCompra.png";
	
	private var url_cuponera:String = "assets/general/Cuponera.jpg";

	
	private var catalogs:CatalogoFactory = CatalogoFactory.getInstance();


	private var loader:Loader = new Loader();

	private var frame:Sprite = new Sprite();
	
	private var frame2:Sprite = new Sprite();
	
	

	private var isEMail:Boolean = false;

	private var _automatic:Boolean = false;

	public var forzarRemitos:Boolean = false;

	public var esRecibo:Boolean = false;
		
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
		} else if (_documento.esRecibo()) {
			request = new URLRequest(url_recibo);
		} else if (_documento.comprobante.codigo == "84") {
			request = new URLRequest(url_cuponera);
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
		if (_documento.comprobante.codigo == "84") {
			createSheetCuponera(sheet1);
		} else {
			createSheetSMS(sheet1);
		}

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

				remObj.sendEmail(addresses, "FULLTIME - " + comprobante.toUpperCase(), "", byteArray, _documento);
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
			emailPnl.documento = documento;
			
			if (documento.cliente) {
				emailPnl.cliente = documento.cliente;
			}
			if (documento.proveedor) {
				emailPnl.proveedor = documento.proveedor;
			}

			var comprobante2:String = documento.comprobante.nombre;

			emailPnl.asunto = "FULLTIME - " + comprobante2.toUpperCase();
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
		var message:String = event.fault && event.fault.rootCause && event.fault.rootCause.localizedMessage ? event.fault.rootCause.localizedMessage : null;
		if (!message) {
			message = event.message.toString();
		}				
		Alert.show(message, "Error", 4, null, null, StyleManager.getStyleManager(null).getStyleDeclaration('.icons32').getStyle('ErrorIcon'));
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
			request = new URLRequest(url_cotizacion);
		} else if (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111") {
			request = new URLRequest(url_ordenCompra);
		} else if (_documento.comprobante.esImportacion()) {
			request = new URLRequest(url_importacion);
		} else if (_documento.comprobante.codigo == "84") {
			request = new URLRequest(url_cuponera);
		} else {	
			request = new URLRequest(url_factura);
		}

		loader.load(request);
	}

	private function ioErrorHandler(event:IOErrorEvent):void {
		Alert.buttonHeight = 32;
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

		frame.graphics.lineStyle(1, 0xffffff);
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
			sheet.addChild(createText(documento.cliente.codigo, {x:338, y:65, width:60, height:14, fontSize:8, align:'left'}));
		} else if (documento.proveedor) {
			sheet.addChild(createText(documento.proveedor.codigo, {x:338, y:65, width:60, height:14, fontSize:8, align:'left'}));
		}

		sheet.addChild(createText(documento.getAgencia(), {x:413, y:65, width:67, height:14, fontSize:8, align:'left'}));
		sheet.addChild(createText((documento.direccion ? documento.direccion : "No Tiene") + (documento.getLocalidad() ? " | " + documento.getLocalidad().toUpperCase() : "") + ((documento.departamento && !(documento.getLocalidad() && documento.departamento.toUpperCase() == documento.getLocalidad().toUpperCase())) ? " | " + documento.departamento : ""), {x:32, y:82, width:286, height:14, fontSize:8,
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
		var descuento:int = 0;
		
		var l:LineaDocumento = null;
		
		if (documento.esRecibo()) {
			for each (var v:VinculoDocumentos in documento.facturasVinculadas) {
				var factura:String = v.factura.serie + "/" + v.factura.numero;
				sheet.addChild(createText(factura, {x:XX - 32, y:YY + 12 * row, width:32, height:12, fontSize:8, align:'left'})); 
			
				row++;
			}
			
		} else if (documento.esAfilado()) {		
			var cantLineas:int = documento.lineas.lineas.length;
			var j:int = 1;
			for each (l in documento.lineas.lineas) {
				sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:68, y:YY + 18 * row, width:145, height:18, fontSize:12, align:'left'}));
				if (l.getCantidad() != BigDecimal.ZERO) {
					sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:223, y:YY + 18 * row, width:54, height:18, fontSize:12, align:'center'}));
				} else {
					sheet.addChild(createText("", {x:223, y:YY + 18 * row, width:36, height:18, fontSize:12, align:'center'}));
					
				}
				sheet.addChild(createText(l.concepto, {x:288, y:YY + 18 * row, width:324, height:18, fontSize:12, align:'left'}));
				
				sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:628, y:YY + 18 * row, width:78, height:18, fontSize:12, align:'rigth'}));
				
				descuento = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
				if (descuento > 0) {
					sheet.addChild(createText(descuento + "%", {x:702, y:YY + 18 * row, width:48, height:18, fontSize:12, align:'rigth'}));
				}
				sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:770, y:YY + 18 * row, width:117, height:18, fontSize:12, align:'rigth'}));
				
				row++;
			}
			
		} else {
			for each (l in documento.lineas.lineas) {
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
				
				descuento = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
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
		}

		var byteArray:ByteArray = _documento.codigoQR;
		if (byteArray) {
			frameQR.x = 28;
			frameQR.y = 458;

			sheet.addChild(frameQR);
		}

		if (documento.CAEnro) {
			var YY_CAE:int = 460;
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

	private function createText(text:String, propValue:Object, showBorder:Boolean = false):TextField {
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

		txt.border = showBorder;
		txt.wordWrap = false;

		return txt;
	}

	private function printOnePerPage():void {

		var pj:PrintJob = new PrintJob();
		var pagesToPrint:uint = 0;
		
		if (catalogs._interface == CatalogoFactory.INTERFACE_WEB_EVENT) {
			sheet1 = new Sprite();
			if (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111" || _documento.comprobante.esImportacion() || _documento.esRecibo()) {
				createSheetSMS(sheet1);
			} else if (_documento.comprobante.codigo == "84") {
				createSheetCuponera(sheet1);
			} else {
				createSheet(sheet1);
			}
			pj.start();

			
			for each (var v:String in print_vias) {
				_via = v;

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
		} else {
			//*********** AIR **********************
			var _printer:String;
			if (!forzarRemitos && (!_documento.esRemito() || _documento.esCotizacionDeVenta || _documento.esOrdenDeVenta)) {
				_printer = GeneralOptions.getInstance().opciones.impresoras.facturacion;
			} else {
				_printer = GeneralOptions.getInstance().opciones.impresoras.remitos;
			}

			if (_printer == null || _printer == "") {
				throw new Error("No hay impresora definida. Ir a Configuración > Preferencias");
			}
			
			var sheet2:Sprite = null;
			
			pj.printer = _printer;
			pj.orientation = _documento.comprobante.codigo == "84" ? PrintJobOrientation.PORTRAIT : PrintJobOrientation.LANDSCAPE;

			if (pj.start2(null, false)) {
				for each (var via:String in print_vias) {
					_via = via;

					sheet1 = new Sprite();
					
					if (_documento.comprobante.codigo == "101" || _documento.comprobante.codigo == "111" || _documento.comprobante.esImportacion() || _documento.esRecibo()) {
						createSheetSMS(sheet1);
					} else if (_documento.comprobante.codigo == "84") {
						createSheetCuponera(sheet1);
					} else {
						createSheet(sheet1);
					}
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
		}

	}
	
	private function createMovimientosCuponera(sheet:Sprite, positionY:int):void {
		var matrix:Matrix = new Matrix();
		
		var dtf:DateTimeFormatter = new DateTimeFormatter();
		dtf.dateTimePattern = "dd/MM/yy";

		var nf:NumberFormatter = new NumberFormatter();
		nf.setStyle("locale", "es_ES");
		nf.trailingZeros = true;
		nf.fractionalDigits = 2;
		nf.groupingSeparator = ".";
		nf.decimalSeparator = ",";
		
		var nf2:NumberFormatter = new NumberFormatter();
		nf2.setStyle("locale", "es_ES");
		nf2.trailingZeros = false;
		nf2.fractionalDigits = 0;
		nf2.groupingSeparator = ".";
		nf2.decimalSeparator = ",";

		var XX:int = 40;
		var YY:int = positionY;
		var row:int = 0;
		
		var l:LineaDocumento = documento.lineas.lineas.getItemAt(0) as LineaDocumento;
			
		for each (var cuponera:Cuponera in documento.cuponerasList) {
			if (cuponera.articulo.codigo == l.articulo.codigo) {
				sheet.addChild(createText("DATOS CUPONERA", {x:XX, y:YY, width:750, height:24, fontSize:20, align:'left'}, false)); 
								
				row++;
				row++;
				sheet.addChild(createText("Código: " + cuponera.articulo.codigo + " " + cuponera.articulo.nombre.toUpperCase(), {x:XX, y:YY+24*row, width:500, 
					height:24, fontSize:14, align:'left'}, false)); 
				row++;
				sheet.addChild(createText("Fecha de factura: " + dtf.format(cuponera.fecha), {x:XX, y:YY + 24 * row, width:175, height:24, fontSize:13, align:'left'}, false)); 
				sheet.addChild(createText("Tipo comprobante: " + (cuponera.tipoComprobante ? cuponera.tipoComprobante.toUpperCase() : ""), {x:XX+=175, y:YY + 24 * row, width:400, height:24, fontSize:13, align:'left'}, false)); 
				sheet.addChild(createText("Número: " + cuponera.numero, {x:XX+=400, y:YY + 24 * row, width:150, height:24, fontSize:13, align:'left'}, false)); 

				row++;

				XX = 40;
				
				sheet.addChild(createText("Precio neto: $" + nf.format(cuponera.precioUnitario), {x:XX, y:YY + 24 * row, width:175, height:24, fontSize:13, align:'left'}, false)); 
				sheet.addChild(createText("Cantidad: " + nf2.format(cuponera.cantidadTotal), {x:XX+=175, y:YY + 24 * row, width:200, height:24, fontSize:13, align:'left'}, false)); 
				sheet.addChild(createText("Importe: $" + nf.format(cuponera.precioTotal), {x:XX+=200, y:YY + 24 * row, width:200, height:24, fontSize:13, align:'left'}, false)); 
				row++;
				row++;
				
				XX = 40;

				sheet.addChild(createText("MOVIMIENTOS", {x:XX, y:YY + 24 * row, width:300, height:24, fontSize:16, align:'left'}, false)); 

				row++;

				sheet.addChild(createText("Fecha", {x:XX, y:YY + 24 * row, width:90, height:24, fontSize:14, align:'left'}, false)); 
				sheet.addChild(createText("Comprobante", {x:XX+=90, y:YY + 24 * row, width:300, height:24, fontSize:14, align:'left'}, false)); 
				sheet.addChild(createText("Número", {x:XX+=300, y:YY + 24 * row, width:150, height:24, fontSize:14, align:'rigth'}, false)); 
				sheet.addChild(createText("Cantidad", {x:XX+=150, y:YY + 24 * row, width:150, height:24, fontSize:14, align:'rigth'}, false)); 
				sheet.addChild(createText("Saldo", {x:XX+=150 , y:YY + 24 * row, width:175, height:24, fontSize:14, align:'rigth'}, false)); 
				
				row++;
				row++;
				
				for each (var lineaCuponera:LineaCuponera in cuponera.lineasCuponera) {
					var fecha:String = dtf.format(lineaCuponera.fecha);
					var comprobante:String = lineaCuponera.comprobante;
					
					XX = 40;
					
					sheet.addChild(createText(fecha, {x:XX, y:YY + 22 * row, width:150, height:20, fontSize:14, align:'left'})); 
					sheet.addChild(createText(comprobante, {x:XX+=90, y:YY + 22 * row, width:300, height:20, fontSize:14, align:'left'})); 
					sheet.addChild(createText(lineaCuponera.numero.toString(), {x:XX+=300, y:YY + 22 * row, width:150, height:20, fontSize:14, align:'rigth'})); 
					sheet.addChild(createText(lineaCuponera.cantidad.toString(), {x:XX+=150, y:YY + 22 * row, width:150, height:20, fontSize:14, align:'rigth'})); 
					sheet.addChild(createText(nf.format(lineaCuponera.saldo), {x:XX+=150, y:YY + 22 * row, width:175, height:20, fontSize:14, align:'rigth'})); 
					
					row++;
					
					if (row > 18) {
						break;
					}
				}
				break;
			}
		}

	}
	
	private function createSheetCuponera(sheet:Sprite):void {
		var nf:NumberFormatter = new NumberFormatter();
		nf.setStyle("locale", "es_ES");
		nf.trailingZeros = true;
		nf.fractionalDigits = 2;
		nf.groupingSeparator = ".";
		nf.decimalSeparator = ",";
		
		var nf2:NumberFormatter = new NumberFormatter();
		nf2.setStyle("locale", "es_ES");
		nf2.trailingZeros = false;
		nf2.fractionalDigits = 2;
		nf2.groupingSeparator = ".";
		nf2.decimalSeparator = ",";
		
		
		var picture:Bitmap = Bitmap(loader.content);
		var bitmap:BitmapData = picture.bitmapData;
		
		var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
		var matrix:Matrix = new Matrix();
		
		matrix.scale((945 / bitmap.width), (1336 / bitmap.height));
		
		frame.graphics.beginBitmapFill(bitmap, matrix, false);
		frame.graphics.moveTo(40, 876);
		frame.graphics.lineTo(904, 876);
		frame.graphics.lineStyle(1, 0x666);
		frame.graphics.moveTo(40, 1016);
		frame.graphics.lineTo(904, 1016);
		frame.graphics.moveTo(40, 1038);
		frame.graphics.lineTo(904, 1038);
		frame.graphics.moveTo(40, 1266);
		frame.graphics.lineTo(904, 1266);
		frame.graphics.moveTo(0, 0);
		frame.graphics.drawRect(0, 0, 945, 1336);
		frame.graphics.endFill();		
		sheet.addChild(frame);
		
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
		
		sheet.addChild(createText((documento.serie != null ? documento.serie : "") + " " + (documento.numero != null ? documento.numero : ""), {x:750, y:36, width:129, height:18, fontSize:12, align:'center'}));
		
		var dtf:DateTimeFormatter = new DateTimeFormatter();
		dtf.dateTimePattern = "dd/MM/yy";
		
		sheet.addChild(createText(dtf.format(documento.fechaDoc), {x:750, y:90, width:129, height:18, fontSize:12, align:'center'}));
		
		if (documento.razonSocial && documento.razonSocial != "") {
			sheet.addChild(createText(documento.razonSocial, {x:70, y:108, width:363, height:18, fontSize:12, align:'left'}));
		} else {
			if (documento.cliente && documento.cliente.codigo != "") {
				sheet.addChild(createText(documento.cliente.nombre, {x:84, y:105, width:363, height:18, fontSize:12, align:'left'}));
			} else if (documento.proveedor) {
				sheet.addChild(createText(documento.proveedor.nombre, {x:84, y:105, width:363, height:18, fontSize:12, align:'left'}));
			}
		}
		
		sheet.addChild(createText(documento.cliente.codigo, {x:507, y:100, width:60, height:18, fontSize:12, align:'left'}));
		
		sheet.addChild(createText(documento.getAgencia(), {x:622, y:105, width:108, height:18, fontSize:12, align:'left'}));
		sheet.addChild(createText((documento.direccion ? documento.direccion : "No Tiene") + (documento.getLocalidad() ? " | " + documento.getLocalidad().toUpperCase() : "") + ((documento.departamento && 
			!(documento.getLocalidad() && documento.departamento.toUpperCase() == documento.getLocalidad().toUpperCase())) ? " | " + documento.departamento : ""), 
			{x:70, y:134, width:383, height:18, fontSize:12, align:'left'}));
		sheet.addChild(createText(documento.telefono, {x:507, y:132, width:200, height:18, fontSize:12, align:'left'}));
		
		sheet.addChild(createText(documento.rut != null ? documento.rut : "", {x:78, y:183, width:326, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(documento.ordenCompra, {x:496, y:189, width:108, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(GeneralOptions.getInstance().loggedUser.codigo, {x:672, y:184, width:54, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(documento.entrega ? documento.entrega.codigo : "", {x:750, y:184, width:130, height:18, fontSize:12, align:'center'}));
		
		var XX:int = 74;
		var YY:int = 247;
		
		var simbolo:String = documento.moneda ? documento.moneda.simbolo : "";
		
		var row:Number = 0;
		
		var cantLineas:int = documento.lineas.lineas.length;
		var j:int = 1;
		for each (var l:LineaDocumento in documento.lineas.lineas) {
			sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:65, y:YY + 18 * row, width:145, height:18, fontSize:12, align:'left'}));
			if (l.getCantidad() != BigDecimal.ZERO) {
				sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:213, y:YY + 18 * row, width:54, height:18, fontSize:12, align:'center'}));
			} else {
				sheet.addChild(createText("", {x:213, y:YY + 18 * row, width:36, height:18, fontSize:12, align:'center'}));
			}
			sheet.addChild(createText(l.concepto.toUpperCase(), {x:282, y:YY + 18 * row, width:314, height:18, fontSize:12, align:'left'}));
			sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:600, y:YY + 18 * row, width:78, height:18, fontSize:12, align:'rigth'}));
			
			var descuento:int = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
			if (descuento > 0) {
				sheet.addChild(createText(descuento + "%", {x:692, y:YY + 18 * row, width:48, height:18, fontSize:12, align:'rigth'}));
			}
			sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:760, y:YY + 18 * row, width:117, height:18, fontSize:12, align:'rigth'}));
			
			row++;
		}
		
		sheet.addChild(createText((documento.planPagos != null ? documento.planPagos.nombre : (documento.condicion ? documento.condicion.nombre : "")), {x:67, y:656, width:305, height:18, fontSize:12, align:'center'}));
		
		sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:507, y:656, width:124, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:636, y:656, width:124, height:18, fontSize:12, align:'center'})); // Sub total Neto
		sheet.addChild(createText(simbolo + " " + nf.format(documento.iva), {x:763, y:656, width:124, height:18, fontSize:12, align:'center'}));

		sheet.addChild(createText((documento.notas != null ? documento.notas : ""), {x:396, y:724, width:339, height:46, fontSize:12, align:'left'}));
		sheet.addChild(createText(simbolo + " " + nf.format(documento.total), {x:763, y:726, width:124, height:18, fontSize:14, align:'center'}));
		sheet.addChild(createText(documento.moneda.nombre.toUpperCase(), {x:763, y:773, width:123, height:18, fontSize:12, align:'center'}));
		sheet.addChild(createText(_via, {x:747, y:808, width:168, height:18, fontSize:12, align:'center'}));
		
		createMovimientosCuponera(sheet, 850);
	
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
			sheet.addChild(createText(documento.cliente.codigo, {x:507, y:104, width:60, height:18, fontSize:12, align:'left'}));
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
		nf.groupingSeparator = ".";
		nf.decimalSeparator = ",";

		var nf2:NumberFormatter = new NumberFormatter();
		nf2.setStyle("locale", "es_ES");
		nf2.trailingZeros = false;
		nf2.fractionalDigits = 2;
		nf2.groupingSeparator = ".";
		nf2.decimalSeparator = ",";
		
		var row:Number = 0;
		if (documento.esRecibo()) {
			YY = 230;

			sheet.addChild(createText("FECHA", {x:70, y:YY + 18 * row, width:100, height:24, fontSize:12, align:'left'})); 
			sheet.addChild(createText("COMPROBANTE", {x:170, y:YY + 18 * row, width:200, height:24, fontSize:12, align:'left'})); 
			sheet.addChild(createText("TOTAL", {x:370, y:YY + 18 * row, width:100, height:24, fontSize:12, align:'rigth'})); 
			sheet.addChild(createText("CANCELADO", {x:470, y:YY + 18 * row, width:100, height:24, fontSize:12, align:'rigth'})); 
			sheet.addChild(createText("SALDO", {x:570, y:YY + 18 * row, width:100, height:24, fontSize:12, align:'rigth'})); 
			sheet.addChild(createText("DTOS.", {x:670, y:YY + 18 * row, width:100, height:24, fontSize:12, align:'rigth'})); 
			sheet.addChild(createText("VINCULADO", {x:770, y:YY + 18 * row, width:110, height:24, fontSize:12, align:'rigth'})); 
			
			row++;
			row++;

			for each (var v:VinculoDocumentos in documento.facturasVinculadas) {
				var factura:String = v.factura.serie + "/" + v.factura.numero + "  " + v.factura.comprobante.nombre.toUpperCase();

				var fecha:String = dtf.format(v.factura.fechaDoc);
				var total:String = v.factura.total;
				var saldo:String = v.factura.saldo;				
				var descuentoPorc:String = new BigDecimal(v.descuentoPorc).setScale(0, MathContext.ROUND_DOWN).toString();
				var vinculado:String = v.neto;
				var cancelado:String = v.monto;
				
				sheet.addChild(createText(fecha, {x:70, y:YY + 18 * row, width:100, height:16, fontSize:12, align:'left'})); 
				sheet.addChild(createText(factura, {x:170, y:YY + 18 * row, width:200, height:16, fontSize:12, align:'left'})); 
				sheet.addChild(createText(nf.format(total), {x:370, y:YY + 18 * row, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(nf.format(cancelado), {x:470, y:YY + 18 * row, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(nf.format(saldo), {x:570, y:YY + 18 * row, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(descuentoPorc + "%", {x:670, y:YY + 18 * row, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(nf.format(vinculado), {x:770, y:YY + 18 * row, width:110, height:16, fontSize:12, align:'rigth'})); 
				
				row++;
			}

		} else if (documento.esAfilado()) {		
			var cantLineas:int = documento.lineas.lineas.length;
			var j:int = 1;
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
			
		} else {
			for each (var l:LineaDocumento in documento.lineas.lineas) {
				sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:esOrdenCompra || esImportacion ? 50 : 68, y:YY + 18 * row, width:145, height:18, fontSize:12, align:'left'}));
				if (l.getCantidad() != BigDecimal.ZERO) {
					sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:esOrdenCompra || esImportacion ? 213 : 223, y:YY + 18 * row, width:54, height:18, fontSize:12, align:'center'}));
				} else {
					sheet.addChild(createText("", {x:esOrdenCompra || esImportacion ? 213 : 223, y:YY + 18 * row, width:36, height:18, fontSize:12, align:'center'}));
					
				}
				sheet.addChild(createText(l.concepto, {x:esOrdenCompra || esImportacion ? 272 : 288, y:YY + 18 * row, width:324, height:18, fontSize:12, align:'left'}));
				sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:esOrdenCompra || esImportacion ? 600 : 628, y:YY + 18 * row, width:78, height:18, fontSize:12, align:'rigth'}));
				
				var desc:int = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
				if (desc > 0) {
					sheet.addChild(createText(desc + "%", {x:esOrdenCompra ? 692 : 702, y:YY + 18 * row, width:48, height:18, fontSize:12, align:'rigth'}));
				}
				sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:770, y:YY + 18 * row, width:117, height:18, fontSize:12, align:'rigth'}));
				
				row++;
			}
		}

		if (!esImportacion) {
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
			if (!documento.esRecibo()) {
				sheet.addChild(createText((documento.planPagos != null ? documento.planPagos.nombre : (documento.condicion ? documento.condicion.nombre : "")), {x:67, y:656, width:305, height:18, fontSize:12, align:'center'}));
				
				sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:507, y:656, width:124, height:18, fontSize:12, align:'center'}));
				sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), {x:636, y:656, width:124, height:18, fontSize:12, align:'center'})); // Sub total Neto
				sheet.addChild(createText(simbolo + " " + nf.format(documento.iva), {x:763, y:656, width:124, height:18, fontSize:12, align:'center'}));
			}
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
