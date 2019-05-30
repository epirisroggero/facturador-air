//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.ui.deudores {
	
	import biz.fulltime.conf.GeneralOptions;
	import biz.fulltime.conf.ServerConfig;
	import biz.fulltime.model.Cliente;
	import biz.fulltime.model.Moneda;
	import biz.fulltime.model.Vendedor;
	import biz.fulltime.model.Zona;
	import biz.fulltime.model.deudores.DocPendientesCliente;
	import biz.fulltime.model.deudores.DocumentoDeudor;
	import biz.fulltime.ui.forms.FrmEMail;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
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
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import flashx.textLayout.formats.VerticalAlign;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Spacer;
	import mx.controls.VRule;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.TitleWindow;
	import spark.components.ToggleButton;
	import spark.formatters.DateTimeFormatter;
	import spark.formatters.NumberFormatter;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalLayout;
	
	import util.CatalogoFactory;
	
	public class PrintJobDeudores extends Sprite {

		private var pj:PrintJob;
		private var uiOpt:PrintJobOptions;
		
		// Notas de envio
		private var sheet:Sprite;
		
		private var _current:int = 1;
		
		private var moneda:Moneda;
		
		private var url:String = "assets/general/banner_mail.jpg";

		private var loader:Loader = new Loader();
		
		private var _documetosPendientes:ArrayCollection = new ArrayCollection();
		
		private var isEMail:Boolean = false;
		
		private var catalogs:CatalogoFactory = CatalogoFactory.getInstance();
		
		
		public function PrintJobDeudores(loadImage:Boolean = true) {
			if (loadImage) {
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			}
		}
		
		public function get documetosPendientes():ArrayCollection {
			return _documetosPendientes;
		}

		public function set documetosPendientes(value:ArrayCollection):void	{
			_documetosPendientes = value;
		}

		public function setMoneda(moneda:Moneda):void	{
			this.moneda = moneda;
		}
		
		public function createSMSImage():void {
			isEMail = true;

			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandlerMail);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			var request:URLRequest = new URLRequest(url);
			loader.load(request);
		}

		private function completeHandlerMail(event:Event):void {
			sheet = new Sprite();										
			createSheet(sheet, 0, _documetosPendientes.length);		
			sheet.width = 737;

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
			mailWindow.width = 800;
			mailWindow.height = 600;
			mailWindow.title = "Envío de eMail";
			mailWindow.visible = true;

			var emailPnl:FrmEMail = new FrmEMail();
			emailPnl.asunto = "Fulltime - Listado de deudores.";
			emailPnl.takeSnapshot(sheet);
			emailPnl.addEventListener(CloseEvent.CLOSE, function():void {
				PopUpManager.removePopUp(mailWindow);
				mailWindow = null;
			});
			
			PopUpManager.addPopUp(mailWindow, parent, true);
			PopUpManager.centerPopUp(mailWindow);
			
			mailWindow.addElement(emailPnl);
			
			mailWindow.addEventListener(CloseEvent.CLOSE, closeHandlerEmail);
			
		}

		private function closeHandlerEmail(event:Event):void {
			var helpWindow:TitleWindow = event.target as TitleWindow;
			helpWindow.removeEventListener(CloseEvent.CLOSE, closeHandlerEmail);
			PopUpManager.removePopUp(helpWindow);
			helpWindow = null;
		}


		public function print():void {
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			var request:URLRequest = new URLRequest(url);
			loader.load(request);

		}
				
		private function completeHandler(event:Event):void {
			isEMail = false;

			if (catalogs._interface ==  CatalogoFactory.INTERFACE_WEB_EVENT) {
				var pj:PrintJob = new PrintJob();
				
				var pagesToPrint:uint = 0;
				if (pj.start()) {
							
					var fromItem:int = 0;
					var toItem:int = 0;
					
					
					var rows:int = 0;
					for each (var data:DocPendientesCliente in _documetosPendientes) {
						rows += 3; 
						rows += data.documentos.length;
						rows += 7;
						
						if (rows > 64) {
							rows = 0;  
							try {	
								sheet = new Sprite();										
								createSheet(sheet, fromItem, toItem);				
								sheet.width = pj.paperWidth;
								sheet.height = pj.paperHeight;
								
								fromItem = toItem;
								
								pj.addPage(sheet);
								pagesToPrint++;
							} catch (e:Error) {
								Alert.show(e.toString(), "Error al imprimir la Listado de Deudores.\n");
							}
						}
						toItem++
					}	
					if (fromItem != toItem) {
						try {	
							sheet = new Sprite();										
									
							
							createSheet(sheet, fromItem, toItem);
							sheet.width = pj.paperWidth;
							sheet.height = pj.paperHeight;
							
							pj.addPage(sheet);
							pagesToPrint++;
						} catch (e:Error) {
							Alert.show(e.toString(), "Error al imprimir la Listado de Deudores.\n");
						}	
					}
					
					if (pagesToPrint > 0) {
						pj.send();
					}
				}
			}
			else {
				//**********   AIR ***************************
				
				
				var pj:PrintJob = new PrintJob();
				pj.printer = GeneralOptions.getInstance().opciones.impresoras.otros;
				pj.orientation = PrintJobOrientation.PORTRAIT;
				
				var pagesToPrint:uint = 0;
				if (pj.start2(null, false)) {
					if (pj.orientation == PrintJobOrientation.LANDSCAPE) {
						throw new Error("La Orientación de página en la Impresora debe estar en Vertical.");
					}			
					var fromItem:int = 0;
					var toItem:int = 0;
					
					
					var rows:int = 0;
					for each (var data:DocPendientesCliente in _documetosPendientes) {
						rows += 3; 
						rows += data.documentos.length;
						rows += 7;
						
						if (rows > 64) {
							rows = 0;  
							try {	
								sheet = new Sprite();										
								createSheet(sheet, fromItem, toItem);				
								sheet.width = pj.paperWidth;
								sheet.height = pj.paperHeight;
								
								fromItem = toItem;
								
								pj.addPage(sheet);
								pagesToPrint++;
							} catch (e:Error) {
								Alert.show(e.toString(), "Error al imprimir la Listado de Deudores.\n");
							}
						}
						toItem++
					}	
					if (fromItem != toItem) {
						try {	
							sheet = new Sprite();										
							//createSheet(sheet, fromItem, toItem);				
							
							createSheet(sheet, fromItem, toItem);
							sheet.width = pj.paperWidth;
							sheet.height = pj.paperHeight;
							
							pj.addPage(sheet);
							pagesToPrint++;
						} catch (e:Error) {
							Alert.show(e.toString(), "Error al imprimir la Listado de Deudores.\n");
						}	
					}
					
					if (pagesToPrint > 0) {
						pj.send();
					}
				}
			}
			
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("Unable to load the image: " + url);
		}
		
		private function createSheet(sheet:Sprite, from:int, to:int):void {
			// Create page size
			if (!isEMail) {
				sheet.graphics.lineStyle(1, 0xffffff);
				sheet.graphics.drawRect(0, 0, 737, 1380);
			} else {
				sheet.graphics.lineStyle(1, 0xffffff);
				sheet.graphics.beginFill(0xffffff, 1.0);
			}
			
			var picture:Bitmap = Bitmap(loader.content);
			var bitmap:BitmapData = picture.bitmapData;
			
			var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
						
			var frame:Sprite = new Sprite();
			
			frame.graphics.lineStyle(1, isEMail ? 0x666666 : 0xffffff);
			if (isEMail) {
				frame.graphics.beginBitmapFill(bitmap);
			}
			frame.graphics.drawRect(0, 0, 737, 138);
			frame.graphics.endFill();
			
			sheet.addChild(frame);
			
			var rowHeight:int = 20;
			var cellWidth:int = 64;

			var nf:NumberFormatter = new NumberFormatter();
			nf.setStyle("locale", "es_ES");
			nf.fractionalDigits = 2;

			var dtf:DateTimeFormatter = new DateTimeFormatter();
			dtf.dateTimePattern = "dd/MM/yyyy - hh:mm";			
			
			var df:DateTimeFormatter = new DateTimeFormatter();
			df.dateTimePattern = "dd/MM/yy";			
			
			var X:int = 10;
			
			var Y:int = isEMail ? 146 : 46;

			sheet.graphics.lineStyle(1, isEMail ? 0x666666 : 0xffffff);
			sheet.graphics.drawRect(X - 5, Y, XX+(cellWidth*11) + 10, 30);

			sheet.addChild(createText("Listado de Deudores", {x:X+ 10, y:Y + 5, width:284, height:28, fontSize:16, align:'left', bold:true}));
			sheet.addChild(createText("Fecha: " + dtf.format(new Date()), {x:X+510, y:Y + 6, width:195, height:24, fontSize:12, align:'left', bold:true}));
			
			var XX:int = 10;
			var YY:int = isEMail ? 184 : 84;
			
			var row:Number = 0;
			for (var j:int = from; j < to; j++) {
				var doc:DocPendientesCliente = _documetosPendientes.getItemAt(j) as DocPendientesCliente;
				
				var cliente:Cliente = doc.cliente;
				
				var txtCliente:String = "Cliente:  " + cliente.codigo + " - " + cliente.nombre + " (" + cliente.contacto.ctoRSocial + ")";
				var txtVendedor:String = "";
				if (cliente.vendedor) {
					var vendedor:Vendedor = cliente.vendedor;								
					txtVendedor = "  Vendedor: " + vendedor.codigo + " - " + vendedor.nombre;	
				}							
				var txtClienteData1:String = "  RUT:" + (cliente.contacto.ctoRUT ? cliente.contacto.ctoRUT : "") + 
					",  Teléfono: " + (cliente.contacto.ctoTelefono ? cliente.contacto.ctoTelefono : ",") + 
					",  Celular: " + (cliente.contacto.ctoCelular ? cliente.contacto.ctoCelular : "");
				
				var txtClienteData2:String = 
					"  Encargado de Pagos:" + doc.encargadoPagos + 
					",  Dirección de Cobranza: " + doc.direccionCobranza  + "." + 
					",  Día/Hora: " + doc.diaHoraPagos + ".";
				
				var zona:String = "Zona: No Tiene";
				for each (var z:Zona in CatalogoFactory.getInstance().zonas) {
					if (cliente && z.codigo == cliente.contacto.zonaIdCto) {
						zona = "Zona: " + z.nombre;
						break;
					}
				}				
				var grupo:String = "Grupo: No Tiene";
				if (cliente.grupo) {
					grupo = "Grupo: " + cliente.grupo.codigo + " - " + cliente.grupo.nombre;
				} else {
					grupo = "Grupo: No Tiene";
				}
				
				var categoria:String = "Categoría:" + ((cliente.categCliId == null || cliente.categCliId.length == 0) ? "No Tiene" : cliente.categCliId);
				
				sheet.graphics.beginFill(0xffffff, 1.0);
				sheet.graphics.lineStyle(1, 0x333333);
				sheet.graphics.drawRect(XX, YY+(row*rowHeight), cellWidth * 11, rowHeight * 5);

				sheet.addChild(createText(txtCliente, {x:XX, y:YY+(row*rowHeight), width:512, height:rowHeight, fontSize:12, align:'left', bold:true}));
				sheet.addChild(createText(zona, {x:XX + 512, y:YY+(row*rowHeight), width:160, height:rowHeight, fontSize:12, align:'left'}));
				row++;
				sheet.addChild(createText(txtVendedor, {x:XX, y:YY+(row*rowHeight), width:500, height:rowHeight, fontSize:12, align:'left', bold:true}));
				sheet.addChild(createText(categoria, {x:XX + 512, y:YY+(row*rowHeight), width:160, height:rowHeight, fontSize:12, align:'left'}));
				row++;
				sheet.addChild(createText(txtClienteData1, {x:XX, y:YY+(row*rowHeight), width:512, height:rowHeight, fontSize:11, align:'left'}));
				sheet.addChild(createText(grupo, {x:XX + 512, y:YY+(row*rowHeight), width:160, height:rowHeight, fontSize:12, align:'left'}));
				row++;
				sheet.addChild(createText(txtClienteData2, {x:XX, y:YY+(row*rowHeight), width:512, height:rowHeight, fontSize:11, align:'left'}));
				row++;
								
				sheet.graphics.lineStyle(1, 0x333333);
				sheet.graphics.beginFill(0xffffff, 1.0);
				sheet.graphics.drawRect(XX, YY+(row*rowHeight), cellWidth * 11, rowHeight);	
				for (var k:int = 3; k < 11; k++) {
					sheet.graphics.beginFill(0xffffff, 1.0);
					sheet.graphics.drawRect(XX+(cellWidth*k), YY+(row*rowHeight), cellWidth, rowHeight);	
				}
				sheet.graphics.beginFill(0xffffff, 1.0);
				sheet.graphics.drawRect(XX, YY+(row*rowHeight), cellWidth, rowHeight);
				
											
				sheet.addChild(createText("Fecha", {x:XX, y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'left'}));
				sheet.addChild(createText("Comp.", {x:XX+cellWidth, y:YY+(row*rowHeight), width:192, height:rowHeight, fontSize:12, align:'left'}));
				sheet.addChild(createText("Nro.", {x:XX+(cellWidth*3), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth'}));
				sheet.addChild(createText("F. Pago", {x:XX+(cellWidth*4), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'left'}));
				sheet.addChild(createText("Moneda", {x:XX+(cellWidth*5), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'left'}));
				sheet.addChild(createText("Facturado", {x:XX+(cellWidth*6), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth'}));
				sheet.addChild(createText("Cancelado", {x:XX+(cellWidth*7), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth'}));
				sheet.addChild(createText("Adeudado", {x:XX+(cellWidth*8), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth'}));
				sheet.addChild(createText("Dto.", {x:XX+(cellWidth*9), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth'}));
				sheet.addChild(createText("Adado(N)", {x:XX+(cellWidth*10), y:YY+(row*rowHeight), width:cellWidth - 8, height:rowHeight, fontSize:10, align:'rigth'}));
				
				row++;
			
				sheet.graphics.lineStyle(1, 0x333333);
				sheet.graphics.drawRect(XX, YY+(row*rowHeight), cellWidth * 11, rowHeight*doc.documentos.length);	
				
				for each (var docDeudor:DocumentoDeudor in doc.documentos) {
					sheet.addChild(createText(docDeudor.fecha, {x:XX, y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'left',bold:docDeudor.tieneCuotaVencida}));
					sheet.addChild(createText(docDeudor.comprobante.nombre, {x:XX+cellWidth, y:YY+(row*rowHeight), width:cellWidth*2, height:rowHeight, fontSize:11, align:'left',bold:docDeudor.tieneCuotaVencida}));
					sheet.addChild(createText(docDeudor.numero.toString(), {x:XX+(cellWidth*3), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'rigth',bold:docDeudor.tieneCuotaVencida}));
					
					sheet.addChild(createText(docDeudor.planPago ? docDeudor.planPago.nombre : "", {x:XX+(cellWidth*4), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'left', bold:docDeudor.tieneCuotaVencida}));
					
					sheet.addChild(createText(docDeudor.moneda.nombre, {x:XX+(cellWidth*5), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'left',bold:docDeudor.tieneCuotaVencida}));
					
					sheet.addChild(createText(nf.format(docDeudor.getFacturadoValue()), {x:XX+(cellWidth*6), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'rigth',bold:docDeudor.tieneCuotaVencida}));
					sheet.addChild(createText(nf.format(docDeudor.getCanceladoValue()), {x:XX+(cellWidth*7), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'rigth',bold:docDeudor.tieneCuotaVencida}));
					sheet.addChild(createText(nf.format(docDeudor.getAdeudadoValue()), {x:XX+(cellWidth*8), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'rigth',bold:docDeudor.tieneCuotaVencida}));
					sheet.addChild(createText(nf.format(docDeudor.getDescuentoValue()), {x:XX+(cellWidth*9), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:11, align:'rigth',bold:docDeudor.tieneCuotaVencida}));
					sheet.addChild(createText(nf.format(docDeudor.getAdeudadoNetoValue()), {x:XX+(cellWidth*10), y:YY+(row*rowHeight), width:cellWidth - 8, height:rowHeight, fontSize:11, align:'rigth',bold:docDeudor.tieneCuotaVencida}));
					
					row++;
				}				
				
				sheet.graphics.lineStyle(1, 0x333333);
				sheet.graphics.drawRect(XX, YY+(row*rowHeight), cellWidth * 11, rowHeight);	
				
				sheet.addChild(createText("Subtotales "+cliente.nombre, {x:XX, y:YY+(row*rowHeight), width:260, height:rowHeight, fontSize:12, align:'rigth', bold:true}));
				sheet.addChild(createText(moneda.nombre, {x:XX+(cellWidth*5), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'left', bold:true}));
				sheet.addChild(createText(nf.format(doc.getTotalFacturado(moneda.codigo)), {x:XX+(cellWidth*6), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth', bold:true}));
				sheet.addChild(createText(nf.format(doc.getTotalCancelado(moneda.codigo)), {x:XX+(cellWidth*7), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth', bold:true}));
				sheet.addChild(createText(nf.format(doc.getTotalAdeudado(moneda.codigo)), {x:XX+(cellWidth*8), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth', bold:true}));
				sheet.addChild(createText("", {x:XX+(cellWidth*9), y:YY+(row*rowHeight), width:cellWidth, height:rowHeight, fontSize:12, align:'rigth', bold:true}));
				sheet.addChild(createText(nf.format(doc.getTotalAdeudadoNeto(moneda.codigo)), {x:XX+(cellWidth*10), y:YY+(row*rowHeight), width:cellWidth - 8, height:rowHeight, fontSize:12, align:'rigth', bold:true}));
				
				row++;
				row++;
			}

			var totalAdeudadoPesos:BigDecimal = BigDecimal.ZERO.setScale(2);
			var totalAdeudadoDolares:BigDecimal = BigDecimal.ZERO.setScale(2);
			var totalAdeudadoEuros:BigDecimal = BigDecimal.ZERO.setScale(2);
			
			for each (var data:DocPendientesCliente in _documetosPendientes) {
				for each (var docdd:DocumentoDeudor in data.documentos) {
					if (docdd.moneda.codigo == Moneda.PESOS || docdd.moneda.codigo == Moneda.PESOS_ASTER) {
						totalAdeudadoPesos = totalAdeudadoPesos.add(docdd.getAdeudadoNetoValue());
					} else if (docdd.moneda.codigo == Moneda.DOLARES || docdd.moneda.codigo == Moneda.DOLARES_ASTER) {
						totalAdeudadoDolares = totalAdeudadoDolares.add(docdd.getAdeudadoNetoValue());
					} else {
						totalAdeudadoEuros = totalAdeudadoEuros.add(docdd.getAdeudadoNetoValue());
					}
				}
				
			}
			
			
			sheet.graphics.lineStyle(1, isEMail ? 0x333333 : 0xffffff);
			sheet.graphics.drawRect(XX, YY+(row*rowHeight)-10, cellWidth * 11, rowHeight*3+20);	

			sheet.addChild(createText("Total Adeudado Neto en Pesos: ", {x:XX+5, y:YY+(row*rowHeight), width:280, height:rowHeight, fontSize:14, align:'left', bold:true}));
			sheet.addChild(createText(nf.format(totalAdeudadoPesos), {x:XX+250, y:YY+(row*rowHeight), width:240, height:rowHeight, fontSize:16, align:'rigth', bold:true, color:0xAA0000}));
			row++;
			sheet.addChild(createText("Total Adeudado Neto en Dolares: ", {x:XX+5, y:YY+(row*rowHeight), width:280, height:rowHeight, fontSize:14, align:'left', bold:true}));
			sheet.addChild(createText(nf.format(totalAdeudadoDolares), {x:XX+250, y:YY+(row*rowHeight), width:240, height:rowHeight, fontSize:16, align:'rigth', bold:true, color:0xAA0000}));
			row++;
			sheet.addChild(createText("Total Adeudado Neto en Euros: ", {x:XX+5, y:YY+(row*rowHeight), width:280, height:rowHeight, fontSize:14, align:'left', bold:true}));
			sheet.addChild(createText(nf.format(totalAdeudadoEuros), {x:XX+250, y:YY+(row*rowHeight), width:240, height:rowHeight, fontSize:16, align:'rigth', bold:true, color:0xAA0000}));
			row++;

			if (isEMail) {
				sheet.addChild(createText("---", {x:XX, y:YY+(row*rowHeight), width:195, height:rowHeight, fontSize:12, align:'left'}));
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
			txtFormat.font = "Arial";
			txtFormat.bold = propValue.bold;
			
			txtFormat.color = propValue.color;
			

			
			// Set Format
			txt.setTextFormat(txtFormat);
			
			txt.border = false;
			txt.wordWrap = false;
			txt.antiAliasType = AntiAliasType.ADVANCED;
			
			return txt;
		}

		
	}
}
