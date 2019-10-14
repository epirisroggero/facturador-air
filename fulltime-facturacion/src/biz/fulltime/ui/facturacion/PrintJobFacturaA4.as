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
	import mx.utils.StringUtil;
	
	import org.alivepdf.fonts.FontFamily;
	
	import spark.components.TitleWindow;
	import spark.formatters.DateTimeFormatter;
	import spark.formatters.NumberFormatter;
	
	import util.CatalogoFactory;
	import util.ErrorPanel;
	import util.PNGDecoder;
	
	public class PrintJobFacturaA4 {
		
		public static const VIA_CLIENTE:String = "CLIENTE";
		
		public static const VIA_COBRANZA:String = "COBRANZA";
		
		public static const VIA_DGI:String = "DGI";
		
		private var _documento:Documento;
		
		private var pj:PrintJob;
		
		private var uiOpt:PrintJobOptions;
		
		private var sheet1:Sprite;
		
		private var _via:String = VIA_CLIENTE;
		
		private var _print_vias:Array = [VIA_CLIENTE, VIA_COBRANZA];
		
		private var url_factura:String = "assets/general/preimpresos/header-mail.jpg";
		
		private var url_recibo:String = "assets/general/preimpresos/Recibo.jpg";
		
		private var url_ordenCompra:String = "assets/general/preimpresos/OrdenDeCompra.jpg";
		
		private var url_cotizacion:String = "assets/general/preimpresos/Cotizacion.jpg";
		
		private var url_importacion:String = "assets/general/preimpresos/ImportacionDeCompra.png";
		
		private var url_cuponera:String = "assets/general/preimpresos/Cuponera.jpg";
		
		
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
		
		public function PrintJobFacturaA4(loadImage:Boolean = true) {
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
			matrix.scale(1.0, 1.0);
			
			frameQR.graphics.beginBitmapFill(bitmap, matrix, false);
			frameQR.graphics.lineStyle(1, 0xffffff);
			frameQR.graphics.drawRect(0, 0, 148, 148);
			frameQR.graphics.endFill();
			
			createSheetMM();
			
		}
		
		private function createSheetMM():void {
			if (_documento.comprobante.codigo == "84") {
				createSheetCuponera(sheet1);
			} else {
				createSheet(sheet1);
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
			matrix.scale(0.9, 0.9);
			
			frameQR.graphics.beginBitmapFill(bitmap, matrix, false);
			frameQR.graphics.lineStyle(1, 0xffffff);
			frameQR.graphics.drawRect(0, 0, 124, 124);
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
			
			var scale:Number = 698 / bitmap.width;
			
			var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
			var matrix:Matrix = new Matrix();			
			matrix.scale(scale, scale);
			
			frame.graphics.beginBitmapFill(bitmap, matrix, false, true)
				
			frame.graphics.lineStyle(1, 0xffffff);
			frame.graphics.drawRect(0, 0, 698, 987); //210mm, 297mm - 2480 x 3508
			frame.graphics.endFill();
			
			sheet.addChild(frame);

			sheet.addChild(createText("R.U.T. 21 500256 0012", 
				{x:400, y:45, width:250, height:25, fontSize:18, align:'rigth'}, false, true));

			// Agregar campos de la factura.				
			// LEFT TOP
			// ROW 1
			var YY:Number = 208; 
			frame.graphics.lineStyle(1, 0x666666);
			frame.graphics.drawRect(50, YY, 200, 50);
			frame.graphics.drawRect(50, YY, 350, 50);

			sheet.addChild(createText("Gral. LUNA 1386/1390", 
				{x:50, y:YY-90, width:250, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText("Tels.: 2204 47 72 - Cel.: 099 68 15 86", 
				{x:50, y:YY-70, width:250, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText("Email: ventas@fulltimeuy.com - www.fulltime.com.uy", 
				{x:50, y:YY-50, width:300, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText("MONTEVIDEO - Uruguay", 
				{x:50, y:YY-30, width:250, height:20, fontSize:11, align:'left'}));

			if (documento.esConsumoFinal()) {
				sheet.addChild(createText("CONSUMO FINAL", 
					{x:50, y:YY+5, width:200, height:25, fontSize:11, align:'center'}));
				sheet.addChild(createText(documento.rut ? "CI " + documento.rut : "", 
					{x:50, y:YY+25, width:200, height:25, fontSize:11, align:'center'}));
			} else {
				sheet.addChild(createText("RUC COMPRADOR", 
					{x:50, y:YY+5, width:200, height:25, fontSize:11, align:'center'}));
				if (documento.tipoDoc == "R") {
					sheet.addChild(createText(documento.rut ? documento.rut : "", 
						{x:50, y:YY+25, width:200, height:25, fontSize:11, align:'center'}));
				} else { 
					sheet.addChild(createText(documento.rut ? "CI " + documento.rut : "", 
						{x:50, y:YY+25, width:200, height:25, fontSize:11, align:'center'}));
				}
			}
						
			sheet.addChild(createText("Vend.", 
				{x:250, y:YY+5, width:150, height:25, fontSize:11, align:'center'}));
			sheet.addChild(createText(documento.vendedor ? documento.vendedor.nombre : "DIRECTO", 
				{x:250, y:YY+25, width:150, height:25, fontSize:10, align:'center'}));

			// ROW 2
			YY+=50;
			frame.graphics.drawRect(50, YY, 75, 25);
			frame.graphics.drawRect(125, YY, 50, 25);
			frame.graphics.drawRect(175, YY, 225, 25);
			
			if (documento.razonSocial && documento.razonSocial != "") {
				sheet.addChild(createText("CLIENTE", 
					{x:55, y:YY+5, width:75, height:20, fontSize:11, align:'left'}));
				if (documento.cliente) {				
					sheet.addChild(createText(documento.cliente.codigo, 
						{x:125, y:YY+5, width:50, height:20, fontSize:11, align:'center'}));
				} else {
					sheet.addChild(createText(documento.proveedor.codigo, 
						{x:125, y:YY+5, width:50, height:25, fontSize:10, align:'center'}));
				}
				sheet.addChild(createText(documento.razonSocial, 
					{x:175, y:YY+5, width:225, height:20, fontSize:10, align:'center'}));
			} else {
				if (documento.cliente) {				
					sheet.addChild(createText("CLIENTE", 
						{x:55, y:YY+5, width:75, height:20, fontSize:11, align:'left'}));
					sheet.addChild(createText(documento.cliente.codigo, 
						{x:125, y:YY+5, width:50, height:20, fontSize:11, align:'center'}));
					sheet.addChild(createText(documento.cliente.nombre, 
						{x:175, y:YY+5, width:225, height:20, fontSize:10, align:'center'}));
					
				} else if (documento.proveedor) {
					sheet.addChild(createText("PROVEEDOR", 
						{x:55, y:YY+5, width:75, height:25, fontSize:11, align:'left'}));
					sheet.addChild(createText(documento.proveedor.codigo, 
						{x:125, y:YY+5, width:50, height:25, fontSize:11, align:'center'}));
					sheet.addChild(createText(documento.cliente.nombre, 
						{x:175, y:YY+5, width:225, height:25, fontSize:10, align:'center'}));
				}
			}
			
			// ROW 3
			YY+=25;
			frame.graphics.drawRect(50, YY, 75, 45);
			frame.graphics.drawRect(50, YY, 350, 45);
			
			var localidadDepto:String = "";
			if (documento.getLocalidad()) {
				localidadDepto += documento.getLocalidad() + "  |  ";
			}
			if (documento.getDepartamento()) {
				localidadDepto += documento.getDepartamento();
			}			
			
			sheet.addChild(createText("DOMICILIO", 
				{x:55, y:YY+15, width:75, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText(documento.direccion ? documento.direccion : "No Tiene", 
				{x:125, y:YY+5, width:275, height:45, fontSize:10, align:'center'}));
			sheet.addChild(createText(localidadDepto.toUpperCase(), 
				{x:125, y:YY+25, width:275, height:45, fontSize:10, align:'center'}));

			// ROW 4			
			YY+=45; 
			frame.graphics.drawRect(50, YY, 75, 25);
			frame.graphics.drawRect(50, YY, 350, 25);

			sheet.addChild(createText("TELÉFONO", 
				{x:55, y:YY+5, width:75, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText(documento.telefono, 
				{x:125, y:YY+5, width:275, height:20, fontSize:11, align:'center'}));
						
			// RIGTH TOP			
			YY-=190; 
			frame.graphics.drawRect(420, YY, 230, 125);
			frame.graphics.drawRect(420, YY+50, 130, 75);

			YY+=5; 
			sheet.addChild(createText(documento.CAEnom ? documento.CAEnom : documento.comprobante.nombre, 
				{x:420, y:YY, width:230, height:25, fontSize:12, align:'center'}));
			sheet.addChild(createText("Serie " + (documento.serie ? documento.serie.toUpperCase() : "") + " " + (documento.numero ? documento.numero : ""), 
				{x:420, y:YY+20, width:230, height:25, fontSize:12, align:'center'}, false, true));

			YY+=45; 			
			frame.graphics.drawRect(420, YY, 230, 25);
			frame.graphics.drawRect(420, YY+25, 230, 25);
			frame.graphics.drawRect(420, YY+50, 230, 25);
			
			sheet.addChild(createText("COMPROBANTE TIPO", 
				{x:425, y:YY+5, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("MONEDA", 
				{x:425, y:YY+30, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("FECHA", 
				{x:425, y:YY+55, width:120, height:25, fontSize:11, align:'left'}, false, true));

			frame.graphics.drawRect(420, YY+90, 130, 75);
			frame.graphics.drawRect(420, YY+90, 230, 25);
			frame.graphics.drawRect(420, YY+115, 230, 25);
			frame.graphics.drawRect(420, YY+140, 230, 25);

			sheet.addChild(createText("AGENCIA", 
				{x:425, y:YY+95, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("ENC. DE CTA.", 
				{x:425, y:YY+120, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("TIPO ENTREGA", 
				{x:425, y:YY+145, width:120, height:25, fontSize:11, align:'left'}));

			
			if (documento.CAEnom) {
				if (documento.comprobante.isCredito()) {
					if (documento.comprobante.codigo == "7" || documento.comprobante.codigo == "8" || documento.comprobante.codigo == "9") {
						sheet.addChild(createText(documento.comprobante.nombre, 
							{x:550, y:YY+5, width:100, height:18, fontSize:11, align:'center'}));
					} else {
						sheet.addChild(createText("Crédito", 
							{x:550, y:YY+5, width:100, height:18, fontSize:11, align:'center'}));
					}
					
				} else {
					sheet.addChild(createText("Contado", 
						{x:550, y:YY+5, width:100, height:18, fontSize:11, align:'center'}));
				}
			}

			var dtf:DateTimeFormatter = new DateTimeFormatter();
			dtf.dateTimePattern = "dd/MM/yyyy";
			
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
			
			YY+=30;
			
			sheet.addChild(createText(documento.moneda.nombre,  
				{x:550, y:YY, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(dtf.format(documento.fechaDoc), 
				{x:550, y:YY+25, width:100, height:18, fontSize:11, align:'center'}, false, true));

			sheet.addChild(createText(documento.agencia, 
				{x:550, y:YY+65, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(_comisiones, 
				{x:550, y:YY+90, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(documento.entrega ? documento.entrega.codigo : "", 
				{x:550, y:YY+115, width:100, height:18, fontSize:11, align:'center'}));

			var simbolo:String = documento.moneda.simbolo;
			var mda:String = documento.moneda.mndAbrevia;
			
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
			
			var XX:int = 50;
			YY += 160;

			sheet.addChild(createText("Códigos",  
				{x:50, y:YY, width:100, height:18, fontSize:11, align:'left'}, true, true));
			sheet.addChild(createText("Detalle",  
				{x:150, y:YY, width:250, height:18, fontSize:11, align:'left'}, true, true));
			sheet.addChild(createText("Cant.",  
				{x:400, y:YY, width:50, height:18, fontSize:11, align:'rigth'}, true, true));
			sheet.addChild(createText("Precio",  
				{x:450, y:YY, width:60, height:18, fontSize:11, align:'rigth'}, true, true));
			sheet.addChild(createText("Desc.",  
				{x:510, y:YY, width:60, height:18, fontSize:11, align:'center'}, true, true));
			sheet.addChild(createText("Total",  
				{x:570, y:YY, width:80, height:18, fontSize:11, align:'rigth'}, true, true));

			
			YY += 25;
			
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
					XX=50;
					if (_via == "COBRANZA") {
						sheet.addChild(createText(disguise(l.getPorcentajeUtilidad()), {x:XX - 48, y:YY + 18 * row, width:48, height:16, fontSize:8, align:'left'})); // % de utilidad. Solo Vía Cobranza.
					}
					sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:XX, y:YY + 18 * row, width:100, height:16, fontSize:10, align:'left'}));
					
					XX+=100;
					sheet.addChild(createText(l.concepto, {x:XX, y:YY + 18 * row, width:250, height:16, fontSize:10, align:'left'}));
					
					XX+=250;
					if (l.getCantidad() != BigDecimal.ZERO) {
						sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:XX, y:YY + 18 * row, width:50, height:16, fontSize:10, align:'rigth'}));
					} 

					XX+=50;
					sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:XX, y:YY + 18 * row, width:60, height:16, fontSize:10, align:'rigth'}));
					
					XX+=60;
					descuento = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
					if (descuento > 0) {
						sheet.addChild(createText(descuento + "%", {x:XX, y:YY + 18 * row, width:60, height:16, fontSize:10, align:'center'}));
					} else {
						sheet.addChild(createText("", {x:XX, y:YY + 18 * row, width:60, height:16, fontSize:10, align:'center'}));
					}
					XX+=60;
					sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:XX, y:YY + 18 * row, width:80, height:16, fontSize:10, align:'rigth'}));
					
					row++;
					XX=50;
					if (l.notas && printNotasInterlineadas) {
						var notas:String = l.notas;
						if (notas) {
							notas = nl2br(l.notas);
						}
						sheet.addChild(createText(notas, {x:XX, y:YY + 18 * row, width:564, height:12, fontSize:10, align:'left'}));
						row++;
					}
				}
			}
			
			var byteArray:ByteArray = _documento.codigoQR;
			if (byteArray) {
				frameQR.x = 44;
				frameQR.y = 757;
				
				sheet.addChild(frameQR);
			}
			
			if (documento.CAEnro) {
				var XX_CAE:int = 187;
				var YY_CAE:int = 770;
				sheet.addChild(createText("Código seguridad: " + documento.codSeguridadCFE, 
					{x:XX_CAE, y:YY_CAE, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Res. 2939/2016 - IVA al día", 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Puede verificar comprobante en", 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				if (!documento.esConsumoFinal()) {
					sheet.addChild(createText("www.efactura.dgi.gub.uy", 
						{x:XX_CAE, y:YY_CAE = YY_CAE + 16, width:200, height:18, fontSize:10, align:'left'}));
				} else {
					sheet.addChild(createText("www.efactura.info", 
						{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:126, height:18, fontSize:10, align:'left'}));
				}
				sheet.addChild(createText("Nro CAE: " + documento.CAEnro, 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Rango: " + documento.CAEdesde + " - " + documento.CAEhasta + "  Serie: " + documento.CAEserie, 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
			}
			
			XX=420;
			YY=725;

			frame.graphics.drawRect(XX, YY, 230, 50);
			frame.graphics.drawRect(XX, YY+60, 230, 30);
			
			XX+=12;
			YY+=5;
			sheet.addChild(createText("SUBTOTAL:",  
				{x:XX, y:YY, width:80, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("IVA:",  
				{x:XX, y:YY+25, width:80, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("TOTAL:",  
				{x:XX, y:YY+60, width:80, height:25, fontSize:14, align:'left'}, false, true));

			sheet.addChild(createText(simbolo + " " + nf.format(documento.subTotal), 
				{x:XX+80, y:YY, width:130, height:25, fontSize:11, align:'rigth'}));
			sheet.addChild(createText(simbolo + " " + nf.format(documento.iva), 
				{x:XX+80, y:YY+25, width:130, height:25, fontSize:11, align:'rigth'}));
			sheet.addChild(createText(simbolo + " " + nf.format(documento.total), 
				{x:XX+80, y:YY+60, width:130, height:25, fontSize:14, align:'rigth'}, false, true));
			

			sheet.addChild(createText("VÍA " + _via.toUpperCase() , 
				{x:XX+85, y:YY+125, width:130, height:25, fontSize:11, align:'rigth'}, false, false));

			XX=50;
			YY=915;
			
			frame.graphics.drawRect(XX, YY, 600, 47);

			sheet.addChild(createText("ADENDA:", 
				{x:XX+5, y:YY+5, width:60, height:32, fontSize:11, align:'left'}));
			sheet.addChild(createText((documento.notas != null ? StringUtil.trim(documento.notas) : ""), 
				{x:XX+60, y:YY+5, width:510, height:40, fontSize:10, align:'left'}));
			
			if (_via == "COBRANZA") {
				sheet.addChild(createText(disguise(documento.getUtilidadEstimada()), 
					{x:10, y:700, width:40, height:14, fontSize:10, align:'left'}));
			}
			
			//PLAN de PAGO
			if (documento.comprobante.isCredito()) {
				sheet.addChild(createText("Plan de pago".toUpperCase(), 
					{x:XX, y:725, width:100, height:16, fontSize:10, align:'left'}, true, false));
				if (documento.planPagos) {
					sheet.addChild(createText(documento.planPagos.nombre, 
						{x:XX+100, y:725, width:175, height:16, fontSize:10, align:'left'}, true, false));
				} else if (documento.condicion) {
					sheet.addChild(createText(documento.condicion.nombre, 
						{x:XX+100, y:725, width:175, height:16, fontSize:10, align:'left'}, true, false));
				}

				if (documento.comprobante.codigo == "8" || documento.comprobante.codigo == "9") {
					XX = 47; 
					YY = 700;
					
					sheet.addChild(createText("BONIFICACIÓN POR CUMPLIMIENTO: Plazo acordado 36%, vencido 30 días 20%, vencido 60 días Neto",  
						{x:XX, y:YY, width:550, height:16, fontSize:9, align:'left'}, false, true));
				} 
				
			}

		}
		
		public function nl2br(str:String):String {
			return str.replace(new RegExp("[\n\r]", "g"), " | ");
		}
		
		private function createText(text:String, propValue:Object, showBorder:Boolean = false, bold:Boolean = false):TextField {
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
			txtFormat.bold = bold;

			// Set Format
			txt.setTextFormat(txtFormat);
			
			txt.border = showBorder;
			txt.wordWrap = true;
			
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
				pj.orientation = PrintJobOrientation.PORTRAIT;
				
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
				frameQR.x = 65;
				frameQR.y = 686;
				
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
					var descuentoPorc:String = v.descuentoPorc 
						? new BigDecimal(v.descuentoPorc).setScale(0, MathContext.ROUND_DOWN).toString()
						: BigDecimal.ZERO.toString();
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
					sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:770, y:YY + 18 * row, width:112, height:18, fontSize:12, align:'rigth'}));
					
					row++;
				}
			}
			
			if (!esImportacion) {
				if (documento.CAEnro) {
					var XX_CAE:int = 192;
					var YY_CAE:int = 692;
					sheet.addChild(createText("Código seguridad: " + documento.codSeguridadCFE, {x:XX_CAE, y:YY_CAE, width:190, height:22, fontSize:13, align:'left'}));
					sheet.addChild(createText("Res.2939/2016 - IVA al día", {x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
					sheet.addChild(createText("Puede verificar comprobante en", {x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
					if (!documento.esConsumoFinal()) {
						sheet.addChild(createText("www.efactura.dgi.gub.uy", {x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
					} else {
						sheet.addChild(createText("www.efactura.info", {x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
					}
					sheet.addChild(createText("Nro CAE: " + documento.CAEnro, {x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
					sheet.addChild(createText("Rango: " + documento.CAEdesde + " - " + documento.CAEhasta + "  Serie: " + documento.CAEserie, {x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:190, height:22, fontSize:13, align:'left'}));
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
