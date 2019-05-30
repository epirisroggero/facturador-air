package biz.fulltime.ui.facturacion {
	
import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.conf.ServerConfig;
import biz.fulltime.event.CapturarImagenEvent;
import biz.fulltime.model.Documento;
import biz.fulltime.model.LineaDocumento;
import biz.fulltime.model.ParticipacionVendedor;
import biz.fulltime.model.VinculoDocumentos;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.net.URLRequest;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.ByteArray;

import mx.controls.Alert;

import org.alivepdf.fonts.FontFamily;

import spark.formatters.DateTimeFormatter;
import spark.formatters.NumberFormatter;

public class CapturarImagen extends EventDispatcher {

	private var sheet1:Sprite;

	private var url_factura:String = "assets/general/Factura.jpg";

	private var url_recibo:String = "assets/general/Recibo.jpg";

	private var loader:Loader = new Loader();
	
	private var frame:Sprite = new Sprite();
	
	private var frameQR:Sprite = new Sprite();
	
	private var documento:Documento;


	public function CapturarImagen() {
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
	}
	
	public function capturarImagen(doc:Documento):void {
		this.documento = doc;
		
		loader.load(request);
		
		var request:URLRequest = null;
		if (doc.esRecibo()) {
			request = new URLRequest(url_recibo);
		} else {
			request = new URLRequest(url_factura);
		}
		
		
	}
	
	private function completeHandler(event:Event):void {
		sheet1 = new Sprite();
		
		createSheet(sheet1);
		
		dispatchEvent(new CapturarImagenEvent(CapturarImagenEvent.CAPTURA_FINALIZADA, documento.docId));
	}
	
	private function createSheet(sheet:Sprite):void {
		var picture:Bitmap = Bitmap(loader.content);
		var bitmap:BitmapData = picture.bitmapData;
		
		var myBitmap:BitmapData = new BitmapData(loader.width, loader.height, false);
		var matrix:Matrix = new Matrix();
		matrix.scale((626 / bitmap.width), (557 / bitmap.height));
		
		frame.graphics.lineStyle(1, 0xffffff);
		frame.graphics.beginBitmapFill(bitmap, matrix, true);
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
		
		if (documento.esRecibo()) {
			var row:Number = 0;
			for each (var v:VinculoDocumentos in documento.facturasVinculadas) {
				var factura:String = v.factura.serie + "/" + v.factura.numero;
				sheet.addChild(createText(factura, {x:XX - 32, y:YY + 12 * row, width:32, height:12, fontSize:8, align:'left'})); 
				
				row++;
			}
			
		} else if (documento.esAfilado()) {		
			var cantLineas:int = documento.lineas.lineas.length;
			var j:int = 1;
			for each (var l:LineaDocumento in documento.lineas.lineas) {
				sheet.addChild(createText(l.articulo ? l.articulo.codigo : "", {x:68, y:YY + 18 * row, width:145, height:18, fontSize:12, align:'left'}));
				if (l.getCantidad() != BigDecimal.ZERO) {
					sheet.addChild(createText(nf2.format(l.getCantidad().toString()), {x:223, y:YY + 18 * row, width:54, height:18, fontSize:12, align:'center'}));
				} else {
					sheet.addChild(createText("", {x:223, y:YY + 18 * row, width:36, height:18, fontSize:12, align:'center'}));
					
				}
				sheet.addChild(createText(l.concepto, {x:288, y:YY + 18 * row, width:324, height:18, fontSize:12, align:'left'}));
				
				sheet.addChild(createText(nf.format(l.getPrecio().toString()), {x:628, y:YY + 18 * row, width:78, height:18, fontSize:12, align:'rigth'}));
				
				var descuento:int = l.getDescuento().setScale(0, MathContext.ROUND_DOWN).intValueExact();
				if (descuento > 0) {
					sheet.addChild(createText(descuento + "%", {x:702, y:YY + 18 * row, width:48, height:18, fontSize:12, align:'rigth'}));
				}
				sheet.addChild(createText(nf.format(l.getSubTotal().toString()), {x:770, y:YY + 18 * row, width:117, height:18, fontSize:12, align:'rigth'}));
				
				row++;
			}
			
		} else {
			var row:Number = 0;
			for each (var l:LineaDocumento in documento.lineas.lineas) {
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
			}
		}
		
		var byteArray:ByteArray = documento.codigoQR;
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
		
		sheet.addChild(createText(documento.moneda.nombre.toUpperCase(), {x:500, y:YY_TOTALES + 508, width:82, height:14, fontSize:8, align:'center'}));
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
		txtFormat.font = FontFamily.HELVETICA;
		
		// Set Format
		txt.setTextFormat(txtFormat);
		
		txt.border = showBorder;
		txt.wordWrap = false;
		
		return txt;
	}
	
	private function ioErrorHandler(event:IOErrorEvent):void {
		Alert.show("No se pudo cargar la imagen de la factura");
	}

}
}