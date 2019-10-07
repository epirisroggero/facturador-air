//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Comprobante")]
public class Comprobante extends CodigoNombreEntity {

	/**
	 *
	 */
	public static const VENTA_CREDITO:int = 1;

	public static const NOTA_CREDITO:int = 2;

	public static const VENTA_CONTADO:int = 3;

	public static const DEVOLUCION_CONTADO:int = 4;
	
	public static const RECIBO_COBRO:int = 5;
	
	public static const COMPRA_CREDITO:int = 21;

	public static const COMPRA_CONTADO:int = 23;
	
	public static const NOTA_CREDITO_COMPRA:int = 22;
	
	public static const DEVOLUCION_COMPRA_CONTADO:int = 24;

	public static const MOVIMIENTO_DE_STOCK_DE_CLIENTE:int = 32;
	
	public static const MOVIMIENTO_DE_STOCK_DE_PROVEEDOR:int = 31;


	/**
	 * Tambien los llamo comprobantes venta (y si, tambien incluyen devoluciones)
	 */
	private static var comprobantesSoportados:Array = new Array(VENTA_CREDITO, VENTA_CONTADO, NOTA_CREDITO, DEVOLUCION_CONTADO);

	public var depositoOrigen:Deposito;

	public var depositoDestino:Deposito;

	public var tipo:int;
	
	public var cmptiponom:String;
	
	public var cmpgastos:String;
	
	public var cmpfifo:String;
	
	public var formatoidcmp:String;

	private var _aster:Boolean = false;
	
	private var _exento:Boolean = false;

	public var descuentoPrometido:String;

	public var descuentosPrometidos:ArrayCollection = new ArrayCollection(); // En JAVA --> List<DescuentoPrometidoComprobante> descuentosPrometidos;

	public var numCmpId:String;
	
	public var cmpiva:String;
	

	public function Comprobante(codigo:String = null, nombre:String = null) {
		super(codigo, nombre);
	}

	public function get exento():Boolean {
		return _exento;
	}

	public function set exento(value:Boolean):void {
		_exento = value;
	}

	/**
	 * Retorna true si es un comprobante que genera deuda para el cliente.
	 * @return
	 */
	public function isCredito():Boolean {
		return tipo == VENTA_CREDITO || tipo == COMPRA_CREDITO;
	}
	
	/**
	 * @return
	 */
	public function isContado():Boolean {
		return tipo == VENTA_CONTADO || tipo == COMPRA_CONTADO;
	}
	
	/**
	 * Retorna true si es un comprobante que genera deuda para el cliente.
	 * @return
	 */
	public function isNotaCredito():Boolean {
		return tipo == NOTA_CREDITO;
	}

	public function isNotaCreditoFinanciera():Boolean { 
		return codigo == "28";
	}

	/**
	 * Los documentos de comprobantes que mueven caja deben especificar una {@link FormaPago}
	 *
	 * @return
	 */
	public function isMueveCaja():Boolean {
		return (tipo == VENTA_CONTADO || tipo == DEVOLUCION_CONTADO || tipo == COMPRA_CONTADO || tipo == RECIBO_COBRO) && 
			codigo != "94" && codigo != "99";
	}

	/**
	 * {@link #isDevolucion()}
	 * @return
	 */
	public function isVenta():Boolean {
		return tipo == VENTA_CONTADO || tipo == VENTA_CREDITO;
	}
	
	/**
	 * {@link #isCompra()}
	 * @return
	 */
	public function isCompra():Boolean {
		return tipo == COMPRA_CONTADO || tipo == COMPRA_CREDITO;
	}

	/**
	 * {@link #isVenta()}
	 * @return
	 */
	public function isDevolucion():Boolean {
		return tipo == DEVOLUCION_CONTADO || tipo == NOTA_CREDITO;
	}

	/**
	 * {@link #isMovimentoDeStockDeCliente()}
	 * @return
	 */
	public function isMovimentoDeStockDeCliente():Boolean {
		return tipo == MOVIMIENTO_DE_STOCK_DE_CLIENTE;
	}

	/**
	 * {@link #isMovimentoDeStockDeCliente()}
	 * @return
	 */
	public function isMovimentoDeStockDeProveedor():Boolean {
		return tipo == MOVIMIENTO_DE_STOCK_DE_PROVEEDOR;
	}

	public function isRecibo():Boolean {
		return tipo == RECIBO_COBRO;
	}

	/**
	 * Usualmente en comprobantes de credito, se trata de un descuento prometido
	 * al cliente (en caso de que cumpla con los pagos en las fechas previstas)
	 *
	 * Comparada a una venta contado, los precios se incrementan en el
	 * porcentaje dado por este campo. Asimismo, se le promete el mismo
	 * porcentaje como descuento (condicionado al buen pago, como dice mas
	 * arriba)
	 *
	 * Dado un comprobante, pueden haber varios descuentos prometidos, cada uno
	 * asociado a un lapso de tiempo. Usualmente a mayor lapso (lease atraso)
	 * menor descuento.
	 */
	public function getDescuentoPrometido(diasRetraso:int = 0, categoriaCliente:String = null):BigDecimal {
		if (descuentosPrometidos == null || descuentosPrometidos.length == 0) {
			return BigDecimal.ZERO;
		}
		if (diasRetraso == 0) {
			var maxDto:BigDecimal = BigDecimal.ZERO;
			for each (var d:DescuentoPrometidoComprobante in descuentosPrometidos) {
				if (new BigDecimal(d.descuento).compareTo(maxDto) > 0) {
					maxDto = new BigDecimal(d.descuento);
				}
			}
			return maxDto;

		} else {
			if (categoriaCliente) {
				var descuentosParaCategoria:ArrayCollection = getDescuentosParaCategoria(categoriaCliente);
				for each (var descuentoPrometido:DescuentoPrometidoComprobante in descuentosParaCategoria) {
					if (diasRetraso <= descuentoPrometido.retraso) {
						return new BigDecimal(descuentoPrometido.descuento);
					}
				}
			} else {
				for each (var desc:DescuentoPrometidoComprobante in descuentosPrometidos) {
					if (diasRetraso <= desc.retraso) {
						return new BigDecimal(desc.descuento);
					}
				}
				
			}
			return BigDecimal.ZERO; //si me voy de todo rango, no descuento nada. 

		}
	}
	
	private function getDescuentosParaCategoria(categoriaCliente:String):ArrayCollection {
		var result:ArrayCollection = new ArrayCollection();
		for each (var e:DescuentoPrometidoComprobante in descuentosPrometidos) {
			var categCliente:String = e != null ? e.categoriaCliente : null;
			if (categoriaCliente && categoriaCliente == categCliente) {
				result.addItem(e);
			}
		}
		return result;
	}


	public function calcularMontoDescuentoPrometido(monto:BigDecimal):BigDecimal {
		var mathContext:MathContext = new MathContext(2);
		return monto.multiply(getDescuentoPrometido()).divide(new BigDecimal(100), MathContext.DEFAULT);
	}

	public function aplicarDescuentoPrometido(importe:BigDecimal, diasRetraso:int = 0, categoriaCliente:String = null):BigDecimal {
		var descuentoPrometido:BigDecimal = getDescuentoPrometido(diasRetraso, categoriaCliente);
		if (descuentoPrometido.compareTo(BigDecimal.ZERO) == 0) {
			return importe;
		} else {
			return importe.multiply((new BigDecimal(100).subtract(descuentoPrometido))).divide(new BigDecimal(100));
		}
	}

	/**
	 *
	 *
	 * Asumimos que todos los comprobantes soportados por el facturador son emitibles.
	 * Asi que para los 4 tipos, esto va a dar true.
	 *
	 * @return
	 */
	public function isEmitible():Boolean {
		return new ArrayCollection(comprobantesSoportados).contains(tipo);
	}
	
	public function set aster(value:Boolean):void {
		this._aster = value;
	}

	public function get aster():Boolean {
		return _aster;
	}

	public function esProceso70():Boolean {
		return (codigo == '70' || codigo == '71' || codigo == '72' || codigo == '73');
	}
	
	public function esProceso80():Boolean {
		return (codigo == '80' || codigo == '81' || codigo == '82' || codigo == '83' || codigo == '84');
	}
	
	public function esProceso90():Boolean {
		return  codigo == '90' || codigo == '91' || codigo == '92' || codigo == '93' || codigo == '94';
	}
	
	public function esProceso130():Boolean {
		return  codigo == '130' || codigo == '131' || codigo == '132' || codigo == '133';
	}

	
	public function esProceso14():Boolean {
		return codigo == '14' || codigo == '15' || codigo == '16';
	}
	
	public function esImportacion():Boolean {
		return codigo == '120' || codigo == '121' || codigo == '122' || codigo == '124';
	}

	public function esGasto():Boolean {
		switch(codigo) {
			case "110":
			case "111":
			case "112":
			case "113":
			case "114":
			case "115":
			case "116":
			case "212":
			case "213":
			case "214":
			case "215":
				return true;			
			default:
				return false;
		}
	}

	
	public function getCajaId():Number {
		if (isMueveCaja()) {
			if (isVenta() || isDevolucion()) {
				return Caja.CAJA_COBRANZA;
			} else {
				return Caja.CAJA_PRINCIPAL;
			}
		} else {
			return 0;
		}

	}


}

}
