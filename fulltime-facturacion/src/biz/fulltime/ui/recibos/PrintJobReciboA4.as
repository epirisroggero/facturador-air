//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.ui.recibos {
	
	import biz.fulltime.conf.GeneralOptions;
	import biz.fulltime.conf.ServerConfig;
	import biz.fulltime.model.Contacto;
	import biz.fulltime.model.Documento;
	import biz.fulltime.model.LineaDocumento;
	import biz.fulltime.model.ParticipacionVendedor;
	import biz.fulltime.model.VinculoDocumentos;
	import biz.fulltime.ui.forms.FrmEMail;
	
	import com.adobe.images.JPGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
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
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.styles.StyleManager;
	import mx.utils.StringUtil;
	
	import org.alivepdf.display.Display;
	import org.alivepdf.fonts.FontFamily;
	import org.alivepdf.images.ColorSpace;
	import org.alivepdf.layout.Layout;
	import org.alivepdf.layout.Orientation;
	import org.alivepdf.layout.Size;
	import org.alivepdf.layout.Unit;
	import org.alivepdf.links.HTTPLink;
	import org.alivepdf.pages.Page;
	import org.alivepdf.pdf.PDF;
	import org.alivepdf.saving.Method;
	
	import spark.components.TitleWindow;
	import spark.formatters.DateTimeFormatter;
	import spark.formatters.NumberFormatter;
	
	import util.CatalogoFactory;
	import util.ErrorPanel;
	
	public class PrintJobReciboA4 {
		
		public static const VIA_CLIENTE:String = "CLIENTE";
		
		public static const VIA_COBRANZA:String = "COBRANZA";
		
		public static const VIA_DGI:String = "DGI";
		
		private var _documento:Documento;
		
		private var _notaCreditoFinanciera:Documento;
		
		private var pj:PrintJob;
		
		private var uiOpt:PrintJobOptions;
		
		private var sheet1:Sprite;
		
		private var sheet2:Sprite;
		
		private var _via:String = VIA_CLIENTE;
		
		private var _print_vias:Array = [VIA_CLIENTE, VIA_COBRANZA];
		
		private var url_factura:String = "assets/general/preimpresos/header-mail.jpg";
		
		private var catalogs:CatalogoFactory = CatalogoFactory.getInstance();
		
		private var loader:Loader = new Loader();
		
		private var loader2:Loader = new Loader();
		
		private var frame:Sprite = new Sprite();
		
		private var frameNCF:Sprite = new Sprite();		
		
		
		private var isEMail:Boolean = false;
		
		private var _automatic:Boolean = false;
		
		public var forzarRemitos:Boolean = false;
		
		public var esRecibo:Boolean = false;
		
		public var printNotasInterlineadas:Boolean = true;
		
		private var frameQR:Sprite = new Sprite();
		
		private var frameQR_NCF:Sprite = new Sprite();
		
		public var codigoQRLoader:Loader = new Loader();
		
		public function PrintJobReciboA4(loadImage:Boolean = true) {
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
		
		public  function createEmailImage(automatic:Boolean = false):void {
			isEMail = true;
			_automatic = automatic;
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandlerMail);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			var request:URLRequest = new URLRequest(url_factura);
			loader.load(request);
			
			loader2.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandlerMail2);
			loader2.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
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
		
		public function loadCodigoQR_NCF():void {
			codigoQRLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCodigoQRLoaderComplete_NCF);
			codigoQRLoader.loadBytes(_notaCreditoFinanciera.codigoQR);
		}
		
		private function onCodigoQRLoaderComplete_NCF(event:Event):void {
			var loaderQR:Loader = event.target.loader as Loader;
			
			var picture:Bitmap = Bitmap(loaderQR.content);
			var bitmap:BitmapData = picture.bitmapData;
			
			var matrix:Matrix = new Matrix();
			matrix.scale(1.0, 1.0);
			
			frameQR_NCF.graphics.beginBitmapFill(bitmap, matrix, false);
			frameQR_NCF.graphics.lineStyle(1, 0xffffff);
			frameQR_NCF.graphics.drawRect(0, 0, 148, 148);
			frameQR_NCF.graphics.endFill();
			
			createSheets();			
		}

			
		private function createSheetMM():void {
			createSheet(sheet1);
			if (_documento.notaCreditoFinanciera) {
				_notaCreditoFinanciera = _documento.notaCreditoFinanciera;
				
				var request:URLRequest = new URLRequest(url_factura);
				loader2.load(request);
				
			} else {
				createSheets();
			}
			
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

		private function completeHandlerMail2(event:Event):void {
			sheet2 = new Sprite();
			createSheetNCF(sheet2);
			if (_notaCreditoFinanciera.codigoQR) {
				loadCodigoQR_NCF();
			} else {
				createSheets();
			}	
		}
		
		private function createSheets():void {
			if (_automatic) {
				var imageBitmapData:BitmapData = ImageSnapshot.captureBitmapData(sheet1);
				
				var enc:JPGEncoder = new JPGEncoder();
				var byteArray:ByteArray = enc.encode(imageBitmapData);
				byteArray.position = 0;
				
				var byteArrayNCF:ByteArray =  null;
				if (sheet2) {
					var imageBitmapData2:BitmapData = ImageSnapshot.captureBitmapData(sheet2);
					var enc2:JPGEncoder = new JPGEncoder();
					byteArrayNCF = enc2.encode(imageBitmapData2);
					byteArrayNCF.position = 0;
				}
				
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
					var pdf:PDF = new PDF(Orientation.PORTRAIT, Unit.POINT, true, Size.A4);
					pdf.setDisplayMode(Display.FULL_PAGE, Layout.SINGLE_PAGE);
					var pageRbo:Page;
					var pageNCF:Page;
					
					pageRbo = new Page(Orientation.LANDSCAPE, Unit.POINT, Size.A4);
					pdf.addPage(pageRbo);
					
					pdf.addImageStream(byteArray, ColorSpace.DEVICE_RGB, null, 10, 300, 0, 0, 0, 1, "Normal", new HTTPLink("http://alivepdf.bytearray.org/"));
					pdf.addImageStream(byteArray, ColorSpace.DEVICE_RGB, null, 400, 10, 0, 0, 0, 1, "Normal", new HTTPLink("http://alivepdf.bytearray.org/"));
					
					if (byteArrayNCF) {
						pageNCF = new Page(Orientation.LANDSCAPE, Unit.POINT, Size.A4);
						pdf.addPage(pageNCF);

						pdf.addImageStream(byteArrayNCF, ColorSpace.DEVICE_RGB, null, 10, 300, 0, 0, 0, 1, "Normal", new HTTPLink("http://alivepdf.bytearray.org/"));
						pdf.addImageStream(byteArrayNCF, ColorSpace.DEVICE_RGB, null, 400, 10, 0, 0, 0, 1, "Normal", new HTTPLink("http://alivepdf.bytearray.org/"));
					}
					
					var ba:ByteArray = pdf.save(Method.LOCAL);
					
					var remObj:RemoteObject = new RemoteObject();
					remObj.destination = "CreatingRpc";
					remObj.channelSet = ServerConfig.getInstance().channelSet;
					
					remObj.addEventListener(ResultEvent.RESULT, resultSendEMail);
					remObj.addEventListener(FaultEvent.FAULT, handleFault);
					remObj.showBusyCursor = false;
					
					var comprobante:String = _documento.comprobante.nombre;
					
					remObj.sendEmail(addresses, "FULLTIME - " + comprobante.toUpperCase(), "", byteArray, ba, _documento);
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
				mailWindow.height = 640;
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
				
				if (sheet2) {
					emailPnl.takeSnapshot2(sheet2);
				}
				
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
			var request:URLRequest = new URLRequest(url_factura);
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
		
		private function createSheetNCF(sheet:Sprite):void {
			var picture:Bitmap = Bitmap(loader2.content);
			var bitmap:BitmapData = picture.bitmapData;
			
			var scale:Number = 698 / bitmap.width;
			
			var myBitmap:BitmapData = new BitmapData(loader2.width, loader2.height, false);
			var matrix:Matrix = new Matrix();			
			matrix.scale(scale, scale);
			
			frameNCF.graphics.beginBitmapFill(bitmap, matrix, false, true)
			
			frameNCF.graphics.lineStyle(1, 0xffffff);
			frameNCF.graphics.drawRect(0, 0, 698, 987); //210mm, 297mm - 2480 x 3508
			frameNCF.graphics.endFill();
			
			sheet.addChild(frameNCF);
			
			sheet.addChild(createText("R.U.T. 21 500256 0012", 
				{x:400, y:45, width:250, height:25, fontSize:18, align:'rigth'}, false, true));
			
			// Agregar campos de la factura.				
			// LEFT TOP
			// ROW 1
			var YY:Number = 208; 
			frameNCF.graphics.lineStyle(1, 0x666666);
			frameNCF.graphics.drawRect(50, YY, 200, 50);
			frameNCF.graphics.drawRect(50, YY, 350, 50);
			
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
				sheet.addChild(createText(_notaCreditoFinanciera.rut ? "CI " + _notaCreditoFinanciera.rut : "", 
					{x:50, y:YY+25, width:200, height:25, fontSize:11, align:'center'}));
			} else {
				sheet.addChild(createText("RUC COMPRADOR", 
					{x:50, y:YY+5, width:200, height:25, fontSize:11, align:'center'}));
				if (_notaCreditoFinanciera.tipoDoc == "R") {
					sheet.addChild(createText(_notaCreditoFinanciera.rut ? documento.rut : "", 
						{x:50, y:YY+25, width:200, height:25, fontSize:11, align:'center'}));
				} else { 
					sheet.addChild(createText(_notaCreditoFinanciera.rut ? "CI " + documento.rut : "", 
						{x:50, y:YY+25, width:200, height:25, fontSize:11, align:'center'}));
				}
			}
			
			sheet.addChild(createText("Vend.", 
				{x:250, y:YY+5, width:150, height:25, fontSize:11, align:'center'}));
			sheet.addChild(createText(_notaCreditoFinanciera.vendedor ? _notaCreditoFinanciera.vendedor.nombre : "DIRECTO", 
				{x:250, y:YY+25, width:150, height:25, fontSize:10, align:'center'}));
			
			// ROW 2
			YY+=50;
			frameNCF.graphics.drawRect(50, YY, 75, 25);
			frameNCF.graphics.drawRect(125, YY, 50, 25);
			frameNCF.graphics.drawRect(175, YY, 225, 25);
			
			if (_notaCreditoFinanciera.razonSocial && _notaCreditoFinanciera.razonSocial != "") {
				sheet.addChild(createText("CLIENTE", 
					{x:55, y:YY+5, width:75, height:20, fontSize:11, align:'left'}));
				if (_notaCreditoFinanciera.cliente) {				
					sheet.addChild(createText(_notaCreditoFinanciera.cliente.codigo, 
						{x:125, y:YY+5, width:50, height:20, fontSize:11, align:'center'}));
				} else {
					sheet.addChild(createText(_notaCreditoFinanciera.proveedor.codigo, 
						{x:125, y:YY+5, width:50, height:25, fontSize:10, align:'center'}));
				}
				sheet.addChild(createText(_notaCreditoFinanciera.razonSocial, 
					{x:175, y:YY+5, width:225, height:20, fontSize:10, align:'center'}));
			} else {
				if (_notaCreditoFinanciera.cliente) {				
					sheet.addChild(createText("CLIENTE", 
						{x:55, y:YY+5, width:75, height:20, fontSize:11, align:'left'}));
					sheet.addChild(createText(_notaCreditoFinanciera.cliente.codigo, 
						{x:125, y:YY+5, width:50, height:20, fontSize:11, align:'center'}));
					sheet.addChild(createText(_notaCreditoFinanciera.cliente.nombre, 
						{x:175, y:YY+5, width:225, height:20, fontSize:10, align:'center'}));
					
				} else if (_notaCreditoFinanciera.proveedor) {
					sheet.addChild(createText("PROVEEDOR", 
						{x:55, y:YY+5, width:75, height:25, fontSize:11, align:'left'}));
					sheet.addChild(createText(_notaCreditoFinanciera.proveedor.codigo, 
						{x:125, y:YY+5, width:50, height:25, fontSize:11, align:'center'}));
					sheet.addChild(createText(_notaCreditoFinanciera.proveedor.nombre, 
						{x:175, y:YY+5, width:225, height:25, fontSize:10, align:'center'}));
				}
			}
			
			// ROW 3
			YY+=25;
			frameNCF.graphics.drawRect(50, YY, 75, 45);
			frameNCF.graphics.drawRect(50, YY, 350, 45);
			
			var localidadDepto:String = "";
			if (_notaCreditoFinanciera.getLocalidad()) {
				localidadDepto += _notaCreditoFinanciera.getLocalidad() + "  |  ";
			}
			if (_notaCreditoFinanciera.getDepartamento()) {
				localidadDepto += _notaCreditoFinanciera.getDepartamento();
			}			
			
			sheet.addChild(createText("DOMICILIO", 
				{x:55, y:YY+15, width:75, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText(_notaCreditoFinanciera.direccion ? _notaCreditoFinanciera.direccion : "No Tiene", 
				{x:125, y:YY+5, width:275, height:45, fontSize:10, align:'center'}));
			sheet.addChild(createText(localidadDepto.toUpperCase(), 
				{x:125, y:YY+25, width:275, height:45, fontSize:10, align:'center'}));
			
			// ROW 4			
			YY+=45; 
			frameNCF.graphics.drawRect(50, YY, 75, 25);
			frameNCF.graphics.drawRect(50, YY, 350, 25);
			
			sheet.addChild(createText("TELÉFONO", 
				{x:55, y:YY+5, width:75, height:20, fontSize:11, align:'left'}));
			sheet.addChild(createText(_notaCreditoFinanciera.telefono, 
				{x:125, y:YY+5, width:275, height:20, fontSize:11, align:'center'}));
			
			// RIGTH TOP			
			YY-=190; 
			frameNCF.graphics.drawRect(420, YY, 230, 125);
			frameNCF.graphics.drawRect(420, YY+50, 130, 75);
			
			YY+=5; 
			sheet.addChild(createText(_notaCreditoFinanciera.CAEnom ? _notaCreditoFinanciera.CAEnom : _notaCreditoFinanciera.comprobante.nombre, 
				{x:420, y:YY, width:230, height:25, fontSize:12, align:'center'}));
			sheet.addChild(createText("Serie " + (_notaCreditoFinanciera.serie ? _notaCreditoFinanciera.serie.toUpperCase() : "") + " " + (_notaCreditoFinanciera.numero ? _notaCreditoFinanciera.numero : ""), 
				{x:420, y:YY+20, width:230, height:25, fontSize:12, align:'center'}, false, true));
			
			YY+=45; 			
			frameNCF.graphics.drawRect(420, YY, 230, 25);
			frameNCF.graphics.drawRect(420, YY+25, 230, 25);
			frameNCF.graphics.drawRect(420, YY+50, 230, 25);
			
			sheet.addChild(createText("COMPROBANTE TIPO", 
				{x:425, y:YY+5, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("MONEDA", 
				{x:425, y:YY+30, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("FECHA", 
				{x:425, y:YY+55, width:120, height:25, fontSize:11, align:'left'}, false, true));
			
			frameNCF.graphics.drawRect(420, YY+90, 130, 75);
			frameNCF.graphics.drawRect(420, YY+90, 230, 25);
			frameNCF.graphics.drawRect(420, YY+115, 230, 25);
			frameNCF.graphics.drawRect(420, YY+140, 230, 25);
			
			sheet.addChild(createText("AGENCIA", 
				{x:425, y:YY+95, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("ENC. DE CTA.", 
				{x:425, y:YY+120, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("TIPO ENTREGA", 
				{x:425, y:YY+145, width:120, height:25, fontSize:11, align:'left'}));
			
			
			if (_notaCreditoFinanciera.CAEnom) {
				if (_notaCreditoFinanciera.comprobante.isCredito()) {
					if (_notaCreditoFinanciera.comprobante.codigo == "7" || _notaCreditoFinanciera.comprobante.codigo == "8" || _notaCreditoFinanciera.comprobante.codigo == "9") {
						sheet.addChild(createText(_notaCreditoFinanciera.comprobante.nombre, 
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
			dtf.dateTimePattern = "dd-MM-yyyy";
			
			var _comisiones:String = "";
			var first:Boolean = true;
			for each (var participacion:ParticipacionVendedor in _notaCreditoFinanciera.comisiones.participaciones) {
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
			
			sheet.addChild(createText(_notaCreditoFinanciera.moneda.nombre,  
				{x:550, y:YY, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(dtf.format(_notaCreditoFinanciera.fechaDoc), 
				{x:550, y:YY+25, width:100, height:18, fontSize:11, align:'center'}, false, true));
			
			sheet.addChild(createText(_notaCreditoFinanciera.agencia, 
				{x:550, y:YY+65, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(_comisiones, 
				{x:550, y:YY+90, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(_notaCreditoFinanciera.entrega ? _notaCreditoFinanciera.entrega.codigo : "", 
				{x:550, y:YY+115, width:100, height:18, fontSize:11, align:'center'}));
			
			var simbolo:String = _notaCreditoFinanciera.moneda.simbolo;
			var mda:String = _notaCreditoFinanciera.moneda.mndAbrevia;
			
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
			
			for each (l in _notaCreditoFinanciera.lineas.lineas) {
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
					sheet.addChild(createText(notas, {x:XX, y:YY + 18 * row, width:564, height:16, fontSize:10, align:'left'}));
					row++;
				}
			}
			
			var byteArray:ByteArray = _notaCreditoFinanciera.codigoQR;
			if (byteArray) {
				frameQR_NCF.x = 44;
				frameQR_NCF.y = 757;
				
				sheet.addChild(frameQR_NCF);
			}
			
			if (_notaCreditoFinanciera.CAEnro) {
				var XX_CAE:int = 187;
				var YY_CAE:int = 770;
				sheet.addChild(createText("Código seguridad: " + _notaCreditoFinanciera.codSeguridadCFE, 
					{x:XX_CAE, y:YY_CAE, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Res. 2939/2016 - IVA al día", 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Puede verificar comprobante en", 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				if (!_notaCreditoFinanciera.esConsumoFinal()) {
					sheet.addChild(createText("www.efactura.dgi.gub.uy", 
						{x:XX_CAE, y:YY_CAE = YY_CAE + 16, width:200, height:18, fontSize:10, align:'left'}));
				} else {
					sheet.addChild(createText("www.efactura.info", 
						{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:126, height:18, fontSize:10, align:'left'}));
				}
				sheet.addChild(createText("Nro CAE: " + _notaCreditoFinanciera.CAEnro, 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Rango: " + _notaCreditoFinanciera.CAEdesde + " - " + _notaCreditoFinanciera.CAEhasta + "  Serie: " + _notaCreditoFinanciera.CAEserie, 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
			}
			
			XX=420;
			YY=725;
			
			frameNCF.graphics.drawRect(XX, YY, 230, 50);
			frameNCF.graphics.drawRect(XX, YY+60, 230, 30);
			
			XX+=12;
			YY+=5;
			sheet.addChild(createText("SUBTOTAL:",  
				{x:XX, y:YY, width:80, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("IVA:",  
				{x:XX, y:YY+25, width:80, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("TOTAL:",  
				{x:XX, y:YY+60, width:80, height:25, fontSize:14, align:'left'}, false, true));
			
			sheet.addChild(createText(simbolo + " " + nf.format(_notaCreditoFinanciera.subTotal), 
				{x:XX+80, y:YY, width:130, height:25, fontSize:11, align:'rigth'}));
			sheet.addChild(createText(simbolo + " " + nf.format(_notaCreditoFinanciera.iva), 
				{x:XX+80, y:YY+25, width:130, height:25, fontSize:11, align:'rigth'}));
			sheet.addChild(createText(simbolo + " " + nf.format(_notaCreditoFinanciera.total), 
				{x:XX+80, y:YY+60, width:130, height:25, fontSize:14, align:'rigth'}, false, true));
			
			
			if (_notaCreditoFinanciera.CAEvencimiento) {
				frameNCF.graphics.drawRect(420, YY + 145, 230, 30);
				sheet.addChild(createText("Fecha de Vencimiento " + dtf.format(_notaCreditoFinanciera.CAEvencimiento), 
					{x:425, y:YY+150, width:220, height:20, fontSize:12, align:'center'}, false, true));
			}
			sheet.addChild(createText("VÍA " + _via.toUpperCase() , 
				{x:XX+85, y:YY+115, width:130, height:25, fontSize:11, align:'rigth'}, false, false));
			
			XX=50;
			YY=915;
			
			frameNCF.graphics.drawRect(XX, YY, 600, 47);
			
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

			sheet.addChild(createText("RUT Emisor: 215002560012", 
				{x:400, y:145, width:250, height:25, fontSize:16, align:'rigth'}, false, true));

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
					sheet.addChild(createText(documento.proveedor.nombre, 
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
			YY=208; 
			frame.graphics.drawRect(420, YY, 230, 125);
			frame.graphics.drawRect(420, YY+50, 130, 75);

			YY+=5; 
			sheet.addChild(createText(documento.CAEnom ? documento.CAEnom : documento.comprobante.nombre, 
				{x:420, y:YY, width:230, height:25, fontSize:12, align:'center'}));
			sheet.addChild(createText("Serie/Nro: " + (documento.serie ? documento.serie.toUpperCase() + "/" : "") + (documento.numero ? documento.numero : ""), 
				{x:420, y:YY+20, width:230, height:25, fontSize:12, align:'center'}, false, true));

			YY+=45; 			
			frame.graphics.drawRect(420, YY, 230, 25);
			frame.graphics.drawRect(420, YY+25, 230, 25);
			frame.graphics.drawRect(420, YY+50, 230, 25);
			
			sheet.addChild(createText("TIPO COMP.", 
				{x:425, y:YY+5, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("MONEDA", 
				{x:425, y:YY+30, width:120, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("FECHA", 
				{x:425, y:YY+55, width:120, height:25, fontSize:11, align:'left'}, false, true));
			
			sheet.addChild(createText("Recibo", 
				{x:550, y:YY+5, width:100, height:18, fontSize:11, align:'center'}));

			var dtf:DateTimeFormatter = new DateTimeFormatter();
			dtf.dateTimePattern = "dd-MM-yyyy";
						
			YY+=30;
			
			sheet.addChild(createText(documento.moneda.nombre,  
				{x:550, y:YY, width:100, height:18, fontSize:11, align:'center'}));
			sheet.addChild(createText(dtf.format(documento.fechaDoc), 
				{x:550, y:YY+25, width:100, height:18, fontSize:11, align:'center'}, false, true));

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

			var nf3:NumberFormatter = new NumberFormatter();
			nf3.setStyle("locale", "es_ES");
			nf3.trailingZeros = true;
			nf3.fractionalDigits = 3;

			var row:Number = 0;
			var descuento:int = 0;
			
			var l:LineaDocumento = null;
			
			var XX:int = 50;
			YY += 90;
			
			var DEFAULT_W:int = 85; 
			
			var tieneVinculos:Boolean = false;
			
			for each (var v1:VinculoDocumentos in documento.facturasVinculadas) {
				if (!v1.factura || !v1.factura.comprobante) {
					continue;
				} else {
					tieneVinculos = true;
					break;
				}
			}
			
			if (tieneVinculos) {
				sheet.addChild(createText("Fecha",  
					{x:50, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'left'}, true, true));
				sheet.addChild(createText("Comprobante",  
					{x:50+DEFAULT_W*1, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'left'}, true, true));
				sheet.addChild(createText("Total",  
					{x:50+DEFAULT_W*2, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'rigth'}, true, true));
				sheet.addChild(createText("Cancelado",  
					{x:50+DEFAULT_W*3, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'rigth'}, true, true));
				sheet.addChild(createText("Saldo",  
					{x:50+DEFAULT_W*4, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'rigth'}, true, true));
				sheet.addChild(createText("Dtos.",  
					{x:50+DEFAULT_W*5, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'rigth'}, true, true));
				sheet.addChild(createText("Vinculado",  
					{x:50+DEFAULT_W*6, y:YY, width:DEFAULT_W, height:18, fontSize:11, align:'rigth'}, true, true));
			}
			
			YY += 25;
			
			var totalVinculado:BigDecimal = BigDecimal.ZERO;
			var totalCancelado:BigDecimal = BigDecimal.ZERO;
			var totalSaldo:BigDecimal = BigDecimal.ZERO;

			for each (var v:VinculoDocumentos in documento.facturasVinculadas) {
				if (!v.factura || !v.factura.comprobante) {
					continue;
				}
				var factura:String = v.factura.serie + "/" + v.factura.numero + "  " + v.factura.comprobante.nombre.toUpperCase();
				
				var fecha:String = dtf.format(v.factura.fechaDoc);
				var total:String = v.factura.total;
				var saldo:String = v.factura.saldo;				
				var descuentoPorc:String = v.descuentoPorc 
					? new BigDecimal(v.descuentoPorc).setScale(0, MathContext.ROUND_DOWN).toString()
					: BigDecimal.ZERO.toString();
				var vinculado:String = v.neto;
				var cancelado:String = v.monto;
				
				totalVinculado = totalVinculado.add(new BigDecimal(vinculado));
				totalCancelado = totalCancelado.add(new BigDecimal(cancelado));
				
				sheet.addChild(createText(fecha, {x:50, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'left'})); 
				sheet.addChild(createText(factura, {x:50+DEFAULT_W*1, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'left'})); 
				sheet.addChild(createText(nf.format(total), {x:50+DEFAULT_W*2, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(nf.format(cancelado), {x:50+DEFAULT_W*3, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(nf.format(saldo), {x:50+DEFAULT_W*4, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(descuentoPorc + "%", {x:50+DEFAULT_W*5, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(nf.format(vinculado), {x:50+DEFAULT_W*6, y:YY + 18 * row, width:DEFAULT_W, height:16, fontSize:12, align:'rigth'})); 
				
				row++;
			}
				
			if (tieneVinculos) {
				totalSaldo =  new BigDecimal(documento.total).subtract(totalVinculado);
				
				frame.graphics.drawRect(332, YY + 11 * 22 ,318, 60);
				
				sheet.addChild(createText("Total Cancelado", {x:342, y:YY + 11 * 22 + 10, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText("Total Vinculado", {x:442, y:YY + 11 * 22 + 10, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText("Saldo Recibo", {x:542, y:YY + 11 * 22 + 10, width:100, height:16, fontSize:12, align:'rigth'})); 
				
				sheet.addChild(createText(simbolo + " " + nf.format(totalCancelado), {x:342, y:YY + 12 * 22 + 10, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(simbolo + " " + nf.format(totalVinculado), {x:442, y:YY + 12 * 22 + 10, width:100, height:16, fontSize:12, align:'rigth'})); 
				sheet.addChild(createText(simbolo + " " + nf.format(totalSaldo), {x:542, y:YY + 12 * 22 + 10, width:100, height:16, fontSize:12, align:'rigth'})); 
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
				sheet.addChild(createText("RES. DGI NRO. 2939/2016 - IVA al día", 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				sheet.addChild(createText("Puede verificar comprobante en: ", 
					{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:200, height:18, fontSize:10, align:'left'}));
				if (!documento.esConsumoFinal()) {
					sheet.addChild(createText("www.efactura.dgi.gub.uy", 
						{x:XX_CAE, y:YY_CAE = YY_CAE + 16, width:200, height:18, fontSize:10, align:'left'}));
				} else {
					sheet.addChild(createText("www.efactura.info", 
						{x:XX_CAE, y:YY_CAE = YY_CAE + 20, width:126, height:18, fontSize:10, align:'left'}));
				}
				sheet.addChild(createText("CAE ID: " + documento.CAEnro, 
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
			sheet.addChild(createText("MONEDA:",  
				{x:XX, y:YY, width:80, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("TIPO CAMBIO:",  
				{x:XX, y:YY+25, width:80, height:25, fontSize:11, align:'left'}));
			sheet.addChild(createText("TOTAL:",  
				{x:XX, y:YY+60, width:80, height:25, fontSize:14, align:'left'}, false, true));

			sheet.addChild(createText(documento.moneda.nombre, 
				{x:XX+80, y:YY, width:130, height:25, fontSize:11, align:'rigth'}));
			sheet.addChild(createText(nf3.format(documento.docTCC), 
				{x:XX+80, y:YY+25, width:130, height:25, fontSize:11, align:'rigth'}));
			sheet.addChild(createText(simbolo + " " + nf.format(documento.total), 
				{x:XX+80, y:YY+60, width:130, height:25, fontSize:14, align:'rigth'}, false, true));
			
			if (documento.CAEvencimiento) {
				frame.graphics.drawRect(420, YY + 145, 230, 30);
				sheet.addChild(createText("Fecha de Vencimiento " + dtf.format(documento.CAEvencimiento), 
					{x:425, y:YY+150, width:220, height:20, fontSize:12, align:'center'}, false, true));
			}

			
			XX=50;
			YY=883;

			frame.graphics.drawRect(XX, YY, 600, 80);
			
			sheet.addChild(createText("ADENDA", 
				{x:XX+5, y:YY+5, width:60, height:64, fontSize:11, align:'left'}));
			sheet.addChild(createText((documento.notas != null ? StringUtil.trim(documento.notas) : ""), 
				{x:XX+60, y:YY+5, width:510, height:40, fontSize:10, align:'left'}));

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
					
					createSheet(sheet1);

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
		
}
