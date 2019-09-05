//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.conf.ServerConfig;
import biz.fulltime.rapi.Cotizaciones;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import util.CalcularPrecioAfiladoUtils;
import util.CatalogoFactory;


[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.LineaDocumento")]
public class LineaDocumento extends EventDispatcher {

	public const ONE_HUNDRED:BigDecimal = new BigDecimal("100");

	public var numeroLinea:int = 0;
	
	public var concepto:String;
	
	public var cantidad:String = "0";
	
	public var precio:String = "0";
	
	public var precioFabrica:String = "0";

	public var precioDistribuidor:String = "0";
	
	public var contactoId:String;

	public var docRefId:Number;
	
	public var coeficienteImp:String = "";
	
	public var costo:String = "0";
	
	public var notas:String="";
	
	private var _conceptoIdLin:String;

	public var documento:Documento;
	
	private var _deposito:String;
	
	private var _articulo:Articulo;
	
	private var _concept:Concepto;
	
	private var remObj:RemoteObject;

	private var remObjPS:RemoteObject;
	
	private var remObjPBD:RemoteObject;
	
	private var remObjPSFab:RemoteObject;
	
	private var remObjStock:RemoteObject;
	
	private var remObjPM:RemoteObject;
	

	private var _valorNeto:String;

	private var _changeDeposito:Boolean = false;
	
	private var _stock:BigDecimal;

	private var _hasStock:Boolean = true;
	
	public var ivaArticulo:Iva;
	
	public var rubIdlin:String;
	
	public var afilador:String;
	
	private var _diametro:String = "0";
	
	public var rotos:String = "0";
	
	public var cascados:String = "0";
	
	public var marca:String;
	
	public var descuento:String = "0";
	
	public var linDto1:String = "0"; // Máximo 10
	
	public var linDto2:String = "0"; // Máximo 10
	
	public var linDto3:String = "0"; // Máximo 33
	
	public var linDto4:String = "0"; // Máximo 25
	
	public var ordenTrabajo:String;
	
	private var articuloPrecio:ArticuloPrecio;

	
	public function LineaDocumento() {
		remObjPS = new RemoteObject();
		remObjPS.destination = "CreatingRpc";
		remObjPS.channelSet = ServerConfig.getInstance().channelSet;
		remObjPS.addEventListener(ResultEvent.RESULT, resultPrecioSugerido);
		remObjPS.addEventListener(FaultEvent.FAULT, handleFault);
		remObjPS.showBusyCursor = false;
		
		remObjPBD = new RemoteObject();
		remObjPBD.destination = "CreatingRpc";
		remObjPBD.channelSet = ServerConfig.getInstance().channelSet;
		remObjPBD.addEventListener(ResultEvent.RESULT, resultPrecioBaseDistribuidor);
		remObjPBD.addEventListener(FaultEvent.FAULT, handleFault);
		remObjPBD.showBusyCursor = false;

		remObj = new RemoteObject();
		remObj.destination = "CreatingRpc";
		remObj.channelSet = ServerConfig.getInstance().channelSet;
		remObj.addEventListener(FaultEvent.FAULT, handleFault);
		remObj.showBusyCursor = false;

		remObjStock = new RemoteObject();
		remObjStock.destination = "CreatingRpc";
		remObjStock.channelSet = ServerConfig.getInstance().channelSet;
		remObjStock.addEventListener(FaultEvent.FAULT, handleFault);
		remObjStock.showBusyCursor = false;
		
		remObjPSFab = new RemoteObject();
		remObjPSFab.destination = "CreatingRpc";
		remObjPSFab.channelSet = ServerConfig.getInstance().channelSet;
		remObjPSFab.addEventListener(ResultEvent.RESULT, resultPrecioFabrica);
		remObjPSFab.addEventListener(FaultEvent.FAULT, handleFault);
		remObjPSFab.showBusyCursor = false;
		
		remObjPM = new RemoteObject();
		remObjPM.destination = "CreatingRpc";
		remObjPM.channelSet = ServerConfig.getInstance().channelSet;
		remObjPM.addEventListener(ResultEvent.RESULT, resultPrecioMinorista);
		remObjPM.addEventListener(FaultEvent.FAULT, handleFault);
		remObjPM.showBusyCursor = false;

	}

	public function get hasStock():Boolean {
		return _hasStock;
	}

	public function set hasStock(value:Boolean):void {
		_hasStock = value;
	}

	public function get deposito():String {
		return _deposito;
	}
	
	public function set deposito(value:String):void {
		_deposito = value;
		
		_changeDeposito = true;

		obtenerStock();
	}

	public function get articulo():Articulo {
		return _articulo;
	}

	public function set articulo(value:Articulo):void {
		this._articulo = value;
		
		if (value) {
			// Obtener todos los dataos del articulo ...
			var remObj:RemoteObject = new RemoteObject();
			remObj.destination = "CreatingRpc";
			remObj.channelSet = ServerConfig.getInstance().channelSet;
			remObj.addEventListener(FaultEvent.FAULT, handleFault);
			remObj.showBusyCursor = false;
			remObj.findCatalogEntity("Articulo", value.codigo);
	
			remObj.addEventListener(ResultEvent.RESULT, function resultDatosArticulo(event:ResultEvent):void {
				var value:* = event.result;
				if (value is Articulo) {
					_articulo = value as Articulo;
					
					obtenerStock();
					obtenerIva(_articulo);
				}
			});
			remObj.findCatalogEntity("Articulo", value.codigo);	
		}		
		
		
	}
	
	private function obtenerIva(articulo:Articulo):void {
		ivaArticulo = articulo.iva;
	}

	public function get stock():BigDecimal {
		return _stock;
	}

	public function set stock(value:BigDecimal):void {
		_stock = value;
		dispatchEvent(new Event("changeStock"));
	}
	
	[Bindable(event="changeStock")]
	public function get stockValue():String {
		if (_hasStock) {
			return _stock ? _stock.setScale(4, MathContext.ROUND_HALF_UP).toString() : "";	
		} else {
			return _stock.setScale(4, MathContext.ROUND_HALF_UP).toString();
		}
	}
	
	[Bindable(event="changeStock")]
	public function getStockFaltante():String {
		if (!esArticuloServicio()) {
			return _stock ? _stock.subtract(getCantidad()).negate().setScale(2, MathContext.ROUND_HALF_UP).toString() : "";	
		} else {
			if (_stock && _stock.compareTo(BigDecimal.ZERO) >= 0) {
				return _stock ? _stock.add(getCantidad()).negate().setScale(2, MathContext.ROUND_HALF_UP).toString() : "";	
			} else {
				return getCantidad().setScale(2, MathContext.ROUND_HALF_UP).toString();
			}
		}
		
	}


	/**
	 * es el subtotal por linea
	 *
	 * con dtos
	 * NO iva
	 *
	 */
	public function getSubTotal():BigDecimal {
		return getPrecioUnitario().multiply(new BigDecimal(cantidad)).setScale(4, MathContext.ROUND_HALF_EVEN);
	}

	/**
	 * precio unitario con descuentos aplicados.
	 *
	 * con dtos.
	 *
	 * @return
	 */
	public function getPrecioUnitario():BigDecimal {
		return getPrecio().subtract(getImporteDescuento());
	}

	/**
	 * El importe del descuento.
	 *
	 * unitario
	 * no iva
	 *
	 * @return
	 */
	public function getImporteDescuento():BigDecimal {
		return getPrecio().multiply(getDescuento()).divide(new BigDecimal('100'));
	}

	/**
	 * {@link #getImporteDescuento()} * {@link #getCantidad()}
	 *
	 * @return
	 */
	public function getImporteDescuentoTotal():BigDecimal {
		return getImporteDescuento().multiply(getCantidad());
	}

	/**
	 * El neto es el precio unitario luego de descuentos (incluyendo el descuento prometido del comprobante).
	 *
	 * @return
	 */
	public function getNeto():BigDecimal {
		var precioUnitario:BigDecimal = getPrecioUnitario().setScale(4, MathContext.ROUND_DOWN);
		var descuentoPrometido:BigDecimal = documento.comprobante.getDescuentoPrometido().setScale(4, MathContext.ROUND_DOWN);

		if (descuentoPrometido != BigDecimal.ZERO) {
			return precioUnitario.multiply(BigDecimal.ONE.subtract(descuentoPrometido.divide(ONE_HUNDRED))).setScale(4, MathContext.ROUND_DOWN);
		} else {
			return precioUnitario.setScale(4, MathContext.ROUND_DOWN);
		}
	}
	

	/**
	 * Establecer el valor neto es una forma indirecta de modificar el precio unitario.
	 * Se calcula el precio que de el valor neto especificado, tomando en cuenta descuento(s)
	 *
	 * @param value
	 */
	public function setNeto(value:BigDecimal):void {
		var descuentoPrometido:BigDecimal = documento.comprobante.getDescuentoPrometido();
		var quot:BigDecimal = ONE_HUNDRED.subtract(new BigDecimal(descuento)).multiply(ONE_HUNDRED.subtract(descuentoPrometido));

		precio = ONE_HUNDRED.multiply(ONE_HUNDRED).multiply(value).divide(quot).toString();
	}

	public function set valorNeto(value:String):void {
		this._valorNeto = value;
		setNeto(new BigDecimal(_valorNeto).setScale(4, MathContext.ROUND_HALF_UP));
	}

	[Bindable(event = "changePrecioSugerido")]
	public function get valorNeto():String {
		_valorNeto = getNeto().setScale(4, MathContext.ROUND_HALF_UP).toString();
		return _valorNeto;
	}


	/**
	 * {@link #neto} *  {@link #cantidad}
	 *
	 * @return
	 */
	public function getNetoTotal():BigDecimal {
		return getNeto().setScale(4, MathContext.ROUND_HALF_UP).multiply(new BigDecimal(cantidad).setScale(4, MathContext.ROUND_HALF_UP)).setScale(4, MathContext.ROUND_HALF_UP);
	}


	public function elegirArticulo(value:Articulo):void {
		if (value != null) {
			if (documento != null) {
				var artNombre:String = value.nombre; 
				if (artNombre && artNombre.length > 50) {
					artNombre = artNombre.substr(0, 50);
				}
				concepto = artNombre;

				obtenerArticulo(value.codigo);
			} 
		} else {
			articulo = null;
			concepto = null;
			precio = "0";
			precioDistribuidor = "0";
			costo = "0";
		}
		
	}

	public function elegirConcepto(value:Concepto):void {
		if (value != null) {
			if (documento != null) {
				var conceptoNombre:String = value.nombre; 
				if (conceptoNombre && conceptoNombre.length > 50) {
					conceptoNombre = conceptoNombre.substr(0, 50);
				}
				
				conceptoIdLin = value.codigo;
			} 
		} 
	}

	public function elegirIva(value:Iva):void {
		if (value != null) {
			ivaArticulo = value;
		} 
	}
	
	public function obtenerStock():void {
		if (documento.comprobante.codigo == "10" || documento.comprobante.codigo == "80" || documento.comprobante.codigo == "90") {
			var param:ParametrosAdministracion = CatalogoFactory.getInstance().parametrosAdministracion;
			_deposito = param.depIdParAdm.toString();			
			if (!_deposito) {
				_deposito = "1";
				
			}
		}		

		if (!_articulo) {
			return;
		}
		if (!_deposito) {
			return;
		}
		
		// Obtener stock del articulo ...
		remObjStock.addEventListener(ResultEvent.RESULT, resultStockArticulo);
		remObjStock.getStock(_articulo.codigo, deposito);
	}
	

	private function resultStockArticulo(event:ResultEvent):void {
		remObjStock.removeEventListener(ResultEvent.RESULT, resultStockArticulo);
		
		var value:* = event.result;
		if (value is String) {
			var stockValue:BigDecimal = new BigDecimal(value);
			if (documento.esAfilado()) {
				stockValue = stockValue.negate().setScale(0, MathContext.ROUND_HALF_UP);
			}
			if (stockValue.subtract(getCantidad()).compareTo(BigDecimal.ZERO) == -1) {
				hasStock = false;
			} else {
				hasStock = true;
			}			
			stock = stockValue;
		} else {
			hasStock = true;
			stock = null;
		}
	}

	private function obtenerArticulo(codigoArt:String):void {
		if (codigoArt == null) {
			return;
		}
		// Obtener todos los dataos del articulo ...
		remObj.addEventListener(ResultEvent.RESULT, resultDatosArticulo);
		remObj.findCatalogEntity("Articulo", codigoArt);
	}

	private function resultDatosArticulo(event:ResultEvent):void {
		remObj.removeEventListener(ResultEvent.RESULT, resultDatosArticulo);

		var value:* = event.result;
		if (value is Articulo) {
			_articulo = value as Articulo;
			
			obtenerStock();
			
			var monedaFacturacion:String = documento.moneda.codigo;
			var oCotizaciones:biz.fulltime.rapi.Cotizaciones = obtenerCotizaciones(CotizacionesModel.getInstance().cotizaciones);
			
			if (documento.esAfilado()) {
				remObjPM.getArticuloPrecio(articulo.codigo, "7");
				
			} else if (!documento.esSolicitudCompra) {
				obtenerPrecioSuguerido(articulo.codigo);			
				obtenerPrecioBaseDistribuidor(articulo.codigo);			
				
				remObj.addEventListener(ResultEvent.RESULT, resultMontoMayorCotizacion);
				if (GeneralOptions.getInstance().loggedUser.usuarioModoDistribuidor) {
					remObj.getPrecioSugerido(_articulo.codigo, "1", documento.moneda.codigo/*, oCotizaciones*/);
				} else if (_articulo.monedaCosto != null) {
					remObj.getMontoMayorCotizacion(_articulo.codigo, _articulo.fechaCosto, _articulo.monedaCosto.codigo, _articulo.costo, monedaFacturacion, documento.esRemito(), oCotizaciones);
				}
			} else {	
				if (documento.comprobante.esImportacion()) {
					if (GeneralOptions.getInstance().loggedUser.esSupervisor()) {
						remObjPSFab.getArticuloPrecio(_articulo.codigo, "7", monedaFacturacion);
					} else {
						this.precio = "0";
					}
					this.costo = _articulo.costo;// al finalizarlo borrar el costo que se agregó de forma provisoria

				} else if (_articulo.monedaCosto && monedaFacturacion != _articulo.monedaCosto.codigo) {
					remObj.addEventListener(ResultEvent.RESULT, resultCostoMayorCotizacion);
					remObj.getMontoMayorCotizacion(_articulo.codigo, _articulo.fechaCosto, _articulo.monedaCosto.codigo, _articulo.costo, monedaFacturacion, documento.esRemito(), oCotizaciones);
				} else {
					this.precio = articulo.costo ? String(articulo.costo) : "0";
				}
			}
			
		}
	}
	
	private function resultPrecioFabrica(event:ResultEvent):void {
		var articuloPrecio:ArticuloPrecio = event.result as ArticuloPrecio;
		if (articuloPrecio && articuloPrecio is ArticuloPrecio) {
			this.precio = articuloPrecio.precio;
		} else {
			this.precio = "0";
		}
		
		precioFabrica = this.precio;
	}	
	
	private function resultPrecioMinorista(event:ResultEvent):void {
		articuloPrecio = event.result as ArticuloPrecio;

		// si es afilado y es una cuponera saco el precio de ahí.
        if (documento.esAfilado()) {
            for each(var cuponera:Cuponera in documento.cuponerasList) {
                if (articulo.codigo && cuponera.articulo && cuponera.articulo.codigo == articulo.codigo) {
                    this.precio = cuponera.precioUnitario;
                    return;
                }
            }
        }

		// 
		if (articuloPrecio) {
			var largo:BigDecimal = diametro != null ? new BigDecimal(diametro) : BigDecimal.ZERO; 
			this.precio = CalcularPrecioAfiladoUtils.calcularPrecio(articuloPrecio, largo, documento).toString();
		} else {
			this.precio = "0";
		}
	}

	private function resultCostoMayorCotizacion(event:ResultEvent):void {
		remObj.removeEventListener(ResultEvent.RESULT, resultCostoMayorCotizacion);
		
		var value:Object = event.result;
		if (value is String) {
			precio = String(value);
		} else {
			precio = null;
		}
	}

	private function resultMontoMayorCotizacion(event:ResultEvent):void {
		remObj.removeEventListener(ResultEvent.RESULT, resultMontoMayorCotizacion);

		if (!esArticuloServicio()) {
			var value:Object = event.result;
			if (value is String) {
				costo = String(value);
			} else {
				costo = null;
			}			
		} else {
		}
		// Avisar que cambió el precio
		dispatchEvent(new Event("changePrecioSugerido"));
	}

	private function obtenerPrecioSuguerido(codigoArt:String):void {
		var precioVentaCod:String = documento.preciosVenta.codigo;
		var monedaVentaCod:String = documento.moneda.codigo;

		remObjPS.getPrecioSugerido(codigoArt, precioVentaCod, monedaVentaCod);
	}

	private function resultPrecioSugerido(event:ResultEvent):void {
		var obj:Object = event.result;
		if (obj is String) {
			this.precio = String(obj);
			
			setPrecioUnitarioSinDescuentoPrometido(new BigDecimal(precio));
		} else {
			this.precio = "0";

			// Avisar que cambió el precio
			dispatchEvent(new Event("changePrecioSugerido"));
		}
		
	}

	private function obtenerPrecioBaseDistribuidor(codigoArt:String):void {
		var precioVentaCod:String = "1";
		var monedaVentaCod:String = documento.moneda.codigo;
		
		remObjPBD.getPrecioSugerido(codigoArt, precioVentaCod, monedaVentaCod);
	}
	
	private function resultPrecioBaseDistribuidor(event:ResultEvent):void {
		var obj:Object = event.result;
		if (obj is String) {
			this.precioDistribuidor = String(obj);
			
			setPrecioBaseDistribuidorSinDescuentoPrometido(new BigDecimal(precioDistribuidor));
		} else {
			this.precioDistribuidor = "0";
		}
		
	}

	
	/**
	 * es el  total de iva por linea
	 *
	 * con/luego de dtos.
	 *
	 * @return
	 */
	public function getIva():BigDecimal {
		return getSubTotal().multiply(getTasaIva()).divideScaleRound(new BigDecimal(100), 2, MathContext.ROUND_HALF_UP);
	}
	
	public function comprobanteComputaIva():Boolean {
		if (documento.comprobante.esGasto()) {
			return conceptoIdLin != null && !documento.comprobante.aster && !documento.comprobante.exento;
			
		} else {
			switch (documento.comprobante.codigo) {
				case '122':
				case '124':
					return false;
			}
			
			return (articulo != null && !documento.comprobante.aster && !documento.comprobante.exento);
		}
		
	}


	public function getTasaIva():BigDecimal {
		if (!documento.comprobante.esGasto()) {
			if (!comprobanteComputaIva() || documento.comprobante.aster) {
				return BigDecimal.ZERO;
			} else {
				return articulo.getTasaIva();
			}			
		} else {
			if (conceptoIdLin && documento.comprobante.esGasto() && comprobanteComputaIva()) {
		
				if (ivaArticulo) {
					return ivaArticulo.getTasaIva();
				} else {
					var ivaIdConcepto:Number = _concept.ivaIdConcepto;getIva()
					
					for each(var iva:Iva in CatalogoFactory.getInstance().ivas) {
						if (iva && _concept && iva.codigo == _concept.ivaIdConcepto.toString()) {
							return iva.getTasaIva();
						}
					}				
				}
			}
			return BigDecimal.ZERO;
		}
	}

	public function getCantidad():BigDecimal {
		if (!cantidad) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(cantidad);	
		}
	}
	
	public function getDiametro():BigDecimal {
		if (!diametro) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(diametro);	
		}
	}
	
	public function getRotos():BigDecimal {
		if (!rotos) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(rotos);	
		}
	}
	
	public function getCascados():BigDecimal {
		if (!rotos) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(cascados);	
		}
	}


	public function getArticulo():Articulo {
		return articulo;
	}

	public function setArticulo(articulo:Articulo):void {
		this.articulo = articulo;
		obtenerStock();
	}

	[Bindable(event = "changePrecioSugerido")]
	public function getPrecioBaseDistribuidor():BigDecimal {
		if (precioDistribuidor != null && precioDistribuidor.length > 0) {
			return new BigDecimal(precioDistribuidor).setScale(4, MathContext.ROUND_HALF_UP);
		} else {
			return BigDecimal.ZERO;
		}
	}
	
	[Bindable(event = "changePrecioSugerido")]
	public function getPrecio():BigDecimal {
		if (precio != null && precio != "-" && precio.length > 0) {
			return new BigDecimal(precio).setScale(4, MathContext.ROUND_UP);
		} else {
			return BigDecimal.ZERO;
		}
	}

	[Bindable(event = "changePrecioSugerido")]
	public function getCosto():BigDecimal {
		if (articulo && articulo.familia && GeneralOptions.getInstance().esArticuloDeServicio(articulo.familia.codigo)) {
			costo = getNeto().toString();
		}
		if (costo && costo.length > 0) {
			return new BigDecimal(costo).setScale(4, MathContext.ROUND_UP);	
		} else {
			return BigDecimal.ZERO;
		}
	}
	
	public function esArticuloServicio():Boolean {
		if (articulo && articulo.codigo && articulo.familia) {
			if (GeneralOptions.getInstance().esArticuloDeServicio(articulo.familia.codigo)) {
				return true;
			}
		} 
		return false;
	}

	/**
	 * {@link #costo} *  {@link #cantidad}
	 *
	 * @return
	 */
	public function getCostoTotal():BigDecimal {
		return getCosto().multiply(new BigDecimal(cantidad)).setScale(4, MathContext.ROUND_UP);
	}
	
	
	public function getPrecioBaseDistribuidorTotal():BigDecimal {
		return getPrecioBaseDistribuidor().multiply(new BigDecimal(cantidad)).setScale(4, MathContext.ROUND_UP);
	}

	public function getDescuento():BigDecimal {
		if (descuento != null && descuento.length > 0) {
			return new BigDecimal(descuento).setScale(4, MathContext.ROUND_UP);
		} else {
			return BigDecimal.ZERO;
		}
	}

	public function getPorcentajeUtilidad():BigDecimal {
		var neto:BigDecimal = getNeto(); // Precio de Venta
		if (neto.compareTo(BigDecimal.ZERO) == 0) {
			return null;
		}
		var utilidad:BigDecimal = getUtilidad();
		return utilidad.compareTo(BigDecimal.ZERO) <= 0 ? BigDecimal.ZERO : new BigDecimal(Math.abs(utilidad.numberValue()) * 100.0 / neto.numberValue());
	}
	
	public function getUtilidad():BigDecimal {
		if (articulo && articulo.codigo) {
			return getNeto().subtract(getCosto());
		} else {
			return BigDecimal.ZERO;
		}
	}
	
	public function getPorcentajeUtilidadDistribuidor():BigDecimal {
		var neto:BigDecimal = getNeto(); // Precio de venta
		if (neto.compareTo(BigDecimal.ZERO) == 0) {
			return null;
		}
		var utilidad:BigDecimal = getUtilidadDist();
		return utilidad.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO : new BigDecimal(utilidad.numberValue() * 100.0 / neto.numberValue());
	}

	public function getUtilidadDist():BigDecimal {
		if (_articulo && _articulo.codigo) {
			return getNeto().subtract(getPrecioBaseDistribuidor());
		} else {
			return BigDecimal.ZERO;
		}
	}
	
	public function getPorcentajeUtilidadFulltime():BigDecimal {
		var neto:BigDecimal = getNeto(); // Precio de venta
		if (neto.compareTo(BigDecimal.ZERO) == 0) {
			return null;
		}
		var utilidad:BigDecimal = getUtilidadFulltime();
		return utilidad.compareTo(BigDecimal.ZERO) == 0 ? BigDecimal.ZERO : new BigDecimal(utilidad.numberValue() * 100.0 / neto.numberValue());
	}
	
	public function getUtilidadFulltime():BigDecimal {
		if (articulo && articulo.codigo) {
			return getPrecioBaseDistribuidor().subtract(getCosto());
		} else {
			return BigDecimal.ZERO;
		}
	}


	public function getNumeroLinea():int {
		return numeroLinea;
	}

	public function getConcepto():String {
		return concepto;
	}

	public function setConcepto(concepto:String):void {
		if (concepto && concepto.length > 50) {
			concepto = concepto.substr(0, 50);
		}
		this.concepto = concepto;
	}
	
	public function setPrecioUnitarioSinDescuentoPrometido(value:BigDecimal):void {
		var t:Number = 1.0 - (this.documento.comprobante.getDescuentoPrometido(0, documento.cliente.categCliId).numberValue() / 100.0);
		if (t != 0.0) {
			this.precio = new BigDecimal(value.numberValue() / t).toString();
		} 
		// Avisar que cambió el precio
		dispatchEvent(new Event("changePrecioSugerido"));
	}
	
	public function setPrecioBaseDistribuidorSinDescuentoPrometido(value:BigDecimal):void {
		var t:Number = 1.0 - (this.documento.comprobante.getDescuentoPrometido(0, documento.cliente.categCliId).numberValue() / 100.0);
		if (t != 0.0) {
			this.precioDistribuidor = new BigDecimal(value.numberValue() / t).toString();
		} 
	}

	
	public function obtenerCotizaciones(_cotizacionesXML:XML):biz.fulltime.rapi.Cotizaciones {
		var cotizaciones:biz.fulltime.rapi.Cotizaciones = new biz.fulltime.rapi.Cotizaciones();
		cotizaciones.agregarCotizacion(Moneda.PESOS, Moneda.DOLARES, true, _cotizacionesXML.dolarCompra.@value);
		cotizaciones.agregarCotizacion(Moneda.PESOS, Moneda.DOLARES, false, _cotizacionesXML.dolarVenta.@value)

		cotizaciones.agregarCotizacion(Moneda.PESOS, Moneda.EUROS, true, _cotizacionesXML.euroCompra.@value);
		cotizaciones.agregarCotizacion(Moneda.PESOS, Moneda.EUROS, false, _cotizacionesXML.euroVenta.@value)

		cotizaciones.agregarCotizacion(Moneda.DOLARES, Moneda.EUROS, true, _cotizacionesXML.euroCompraXDolar.@value);
		cotizaciones.agregarCotizacion(Moneda.DOLARES, Moneda.EUROS, false, _cotizacionesXML.euroVentaXDolar.@value);

		return cotizaciones;
	}

	public function updateLineaPrecio(factor:BigDecimal):void {
		if (!factor) {
			return;
		}		
		var _precio:BigDecimal = new BigDecimal(precio);
		_precio = _precio.multiply(factor);
		this.precio = _precio.toString();
	}

	private function handleFault(event:FaultEvent):void {
		Alert.show(event.message.toString(), "Error al obtener el precio");
	}

	public function get diametro():String {
		return _diametro;
	}

	public function set diametro(value:String):void {
		_diametro = value;
		
		if (documento.esAfilado()) {
			for each(var cuponera:Articulo in documento.artCuponera) {
				if (articulo && cuponera && cuponera.codigo == articulo.codigo) {
					return; // es cuponera por tanto no hago nada
				}
			}
			
			if (articuloPrecio) {
				var largo:BigDecimal = _diametro != null ? new BigDecimal(_diametro) : BigDecimal.ZERO; 
				this.precio = CalcularPrecioAfiladoUtils.calcularPrecio(articuloPrecio, largo, documento).toString();
			} else {
				this.precio = "0";
			}
		}
		
	}

	public function getDcto1():BigDecimal {
		if (!linDto1 || linDto1.length < 1) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(linDto1);	
		}
	}

	public function getDcto2():BigDecimal {
		if (!linDto2 || linDto2.length < 1) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(linDto2);	
		}
	}

	public function getDcto3():BigDecimal {
		if (!linDto3 || linDto3.length < 1) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(linDto3);	
		}
	}

	public function getDcto4():BigDecimal {
		if (!linDto4 || linDto4.length < 1) {
			return BigDecimal.ZERO;
		} else {
			return new BigDecimal(linDto4);	
		}
	}

	public function get concept():Concepto {
		return _concept;
	}

	public function set concept(value:Concepto):void {
		_concept = value;
		
		if (_concept && _concept.codigo) {
			_conceptoIdLin = _concept.codigo;
		}
	}

	public function get conceptoIdLin():String {
		return _conceptoIdLin;
	}

	public function set conceptoIdLin(value:String):void {
		_conceptoIdLin = value;
		
		for each (var c:Concepto in CatalogoFactory.getInstance().conceptos) {
			if (c.codigo == _conceptoIdLin) {
				concept = c;	
				break;
			}															
		}									

	}


}

}