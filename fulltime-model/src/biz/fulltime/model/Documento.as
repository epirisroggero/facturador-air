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

import flash.events.Event;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import util.CatalogoFactory;
import util.Utils;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Documento")]
public class Documento extends DocumentoBase {

	public var vendedor:Vendedor;

	public var preciosVenta:PreciosVenta;

	public var depositoOrigen:Deposito;

	public var depositoDestino:Deposito;

	private var _entrega:Entrega;

	public var cantidadBultos:int = 0;

	public var comisiones:ComisionesDocumento;

	public var lineas:LineasDocumento;

	public var cuotasDocumento:CuotasDocumento;

	public var costoOperativo:String;

	public var pagos:ArrayCollection = new ArrayCollection();

	public var saldo:String;

	public var recibosVinculados:ArrayCollection = new ArrayCollection();
	
	public var facturasVinculadas:ArrayCollection = new ArrayCollection();

	private var _emitido:Boolean;

	public var emitidoPor:String;

	public var pendiente:Boolean = true;

	public var agencia:String;

	private var _localidad:String;

	public var reparto:String;

	public var ordenCompra:String;

	public var ordenVenta:String;

	public var chofer:String;

	public var costoEstimadoEntrega:String;

	private var _descuentos:String = "0.00";
	
	public var descuentosPorc:String = "0.00";

	private var _planPagos:PlanPagos;

	private var _condicion:PlanPagos;

	private var _total:BigDecimal;

	private var _subTotal:BigDecimal;
	
	private var _iva:BigDecimal;

	private var _costo:BigDecimal;

	private var _precioDist:BigDecimal;

	private var totalServicios:BigDecimal;

	private var _nuevo:Boolean = false;

	private var remObjStock:RemoteObject;

	private var clienteRemObj:RemoteObject;

	private var proveedorRemObj:RemoteObject;

	public var nroEnvio:String;

	public var departamento:String;

	public var usuarioId:String;

	public var permisosDocumentoUsuario:PermisosDocumentoUsuario = new PermisosDocumentoUsuario();

	public var referencia:String;

	private var _esCotizacionDeVenta:Boolean;

	private var _esOrdenDeVenta:Boolean;

	private var _esSolicitudCompra:Boolean;

	public var stock:BigDecimal = BigDecimal.ZERO;

	private var _rentaNetaComercial:BigDecimal;

	private var _utilidad:BigDecimal;

	private var _cajaId:Number;

	public var prevDocId:String;

	public var prevDocSerieNro:String;

	public var usuIdAut:String;

	public var fanfold1:String = "";

	public var fanfold2:String = "";

	public var fanfold3:String = "";

	// FACTURA ELECTRÓNICA

	private var _docCFEetapa:String;

	private var _docCFEId:Number;

	private var _docCFEstatus:Number;

	private var _docCFEstatusAcuse:Number;

	private var _serieCFEIdDoc:String;

	private var _numCFEIdDoc:String;
	
	public var indGlobalCFERef:String;

	public var tipoCFERef:String;

	public var serieCFERef:String;

	public var numCFERef:String;

	public var razonCFERef:String;
	
	public var fechaCFERef:Date;
	
	public var codSeguridadCFE:String;
	
	public var codigoQR:ByteArray;
	
	public var CAEdesde:Number;
	
	public var CAEemision:Date;
	
	public var CAEhasta:Number;
	
	public var CAEnom:String; 
	
	public var CAEnro:String;
	
	public var CAEserie:String;
	
	public var tipoCFEid:Number;

	public var docRecMda:Moneda;
	
	private var _docRecNeto:String;
	
	public var docRenFin:String = BigDecimal.ZERO.toString();
	
	public var titular:String;
	
	public var bancoIdDoc:String;
	
	public var concepto:String;
	
		// FIN FACTURA ELECTRÓNICA

	public function get numCFEIdDoc():String {
		return _numCFEIdDoc;
	}

	public function set numCFEIdDoc(value:String):void {
		_numCFEIdDoc = value;
	}

	public function get serieCFEIdDoc():String {
		return _serieCFEIdDoc;
	}

	public function set serieCFEIdDoc(value:String):void {
		_serieCFEIdDoc = value;
	}

	public function get docCFEstatusAcuse():Number {
		return _docCFEstatusAcuse;
	}

	public function set docCFEstatusAcuse(value:Number):void {
		_docCFEstatusAcuse = value;
	}

	public function get docCFEstatus():Number {
		return _docCFEstatus;
	}

	public function set docCFEstatus(value:Number):void {
		_docCFEstatus = value;
	}

	public function get docCFEId():Number {
		return _docCFEId;
	}

	public function set docCFEId(value:Number):void {
		_docCFEId = value;
	}

	public function get docCFEetapa():String {
		return _docCFEetapa;
	}

	public function set docCFEetapa(value:String):void {
		_docCFEetapa = value;
	}

	public function get esSolicitudCompra():Boolean {
		return _esSolicitudCompra;
	}

	public function set esSolicitudCompra(value:Boolean):void {
		_esSolicitudCompra = value;
	}

	public function get cajaId():Number {
		return _cajaId;
	}

	public function set cajaId(value:Number):void {
		_cajaId = value;
	}

	public function get condicion():PlanPagos {
		return _condicion;
	}

	public function set condicion(value:PlanPagos):void {
		_condicion = value;
	}

	public function get esOrdenDeVenta():Boolean {
		return _esOrdenDeVenta;
	}

	public function set esOrdenDeVenta(value:Boolean):void {
		_esOrdenDeVenta = value;
	}

	public function esRemito():Boolean {
		return comprobante.aster;
	}

	public function get esCotizacionDeVenta():Boolean {
		return _esCotizacionDeVenta;
	}

	public function set esCotizacionDeVenta(value:Boolean):void {
		_esCotizacionDeVenta = value;
	}

	public function Documento(value:Comprobante = null) {
		super();

		comisiones = new ComisionesDocumento();
		lineas = new LineasDocumento();
		cuotasDocumento = new CuotasDocumento();

		comisiones.documento = this;
		lineas.documento = this;
		cuotasDocumento.documento = this;

		comprobante = value;

		if (comprobante != null) {
			depositoOrigen = comprobante.depositoOrigen;
			depositoDestino = comprobante.depositoDestino;
		}

		if (CatalogoFactory.getInstance().entrega.length > 0) {
			entrega = CatalogoFactory.getInstance().entrega[0] as Entrega;
		}

		proveedorRemObj = new RemoteObject();
		proveedorRemObj.destination = "CreatingRpc";
		proveedorRemObj.channelSet = ServerConfig.getInstance().channelSet;
		proveedorRemObj.addEventListener(ResultEvent.RESULT, resultProveedor);
		proveedorRemObj.addEventListener(FaultEvent.FAULT, handleFault);
		proveedorRemObj.showBusyCursor = true;

		remObjStock = new RemoteObject();
		remObjStock.destination = "CreatingRpc";
		remObjStock.channelSet = ServerConfig.getInstance().channelSet;
		remObjStock.addEventListener(ResultEvent.RESULT, resultStock);
		remObjStock.addEventListener(FaultEvent.FAULT, handleFault);
		remObjStock.showBusyCursor = true;

	}

	public function get entrega():Entrega {
		return _entrega;
	}

	public function set entrega(value:Entrega):void {
		_entrega = value;

		dispatchEvent(new Event("changeLineasVenta"));
	}

	public function get localidad():String {
		return _localidad;
	}

	public function set localidad(value:String):void {
		_localidad = value;
	}

	public function getLocalidad():String {
		if (localidad && localidad.length > 0) {
			return localidad;
		} else if (cliente) {
			return cliente.contacto.ctoLocalidad;
		}
		return null;
	}

	public function getDepartamento():String {
		if (departamento && departamento.length > 0) {
			return departamento;
		} else if (cliente) {
			departamento = null;

			var dptoCodigo:String = cliente.contacto.deptoIdCto;
			for each (var dpto:Object in CatalogoFactory.getInstance().departamentos) {
				if (dptoCodigo == dpto.codigo) {
					departamento = dpto.nombre;
					break;
				}
			}
			return departamento;
		}
		return null;
	}


	public function getAgencia():String {
		if (agencia && agencia.length > 0) {
			return agencia;
		} else if (cliente) {
			return cliente.agencia;
		}
		return "";
	}


	public function get planPagos():PlanPagos {
		return _planPagos;
	}

	public function set planPagos(value:PlanPagos):void {
		_planPagos = value;
	}

	public function updatePlanPagos(value:PlanPagos):void {
		_planPagos = value;

		if (cuotasDocumento == null) {
			cuotasDocumento = new CuotasDocumento();
			cuotasDocumento.documento = this;
		}

		if (!emitido) {
			cuotasDocumento.documento = this;
			cuotasDocumento.inicializarCuotas();
		}
	}


	private function resultProveedor(event:ResultEvent):void {
		var result:* = event.result;

		if (result == null) {
			trace("Advertencia: ", " El resultado de la consulta fue vacio.");
		}

		if (result is Proveedor) {
			proveedor = result as Proveedor;
			if (!emitido) {
				if (comprobante && comprobante.isNotaCreditoFinanciera()) {
					planPagos = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
					condicion = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
				} else {
					if (proveedor.planPagos) {
						planPagos = proveedor.planPagos;
						condicion = proveedor.planPagos;
					} else {
						planPagos = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
						condicion = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
					}
				}
			}

			rut = proveedor.contacto.ctoRUT;
			razonSocial = proveedor.contacto.ctoRSocial;
			direccion = proveedor.contacto.ctoDireccion;

			if (proveedor.contacto.ctoTelefono) {
				if (proveedor.contacto.ctoTelefono.length > 30) {
					telefono = proveedor.contacto.ctoTelefono.substring(0, 30);
				} else {
					telefono = proveedor.contacto.ctoTelefono;
				}
			} else {
				telefono = null;
			}

			departamento = null;
			if (proveedor.contacto) {
				cargarDepartamento(proveedor.contacto);
			}

			var hayLineasVenta:Boolean = lineas && lineas.lineas && lineas.lineas.length > 0 && Number(LineaDocumento(lineas.lineas[0]).cantidad) > 0;
			if (!hayLineasVenta) {
				if (proveedor.contacto.paisIdCto == "UY") {
					moneda = CatalogoFactory.getInstance().monedas[0]; // Pesos oficiales
				} else {
					moneda = CatalogoFactory.getInstance().monedas[1]; // Dolares oficiales.
				}
			}

		}

	}


	private function resultCliente(event:ResultEvent):void {
		var result:* = event.result;

		if (result == null) {
			trace("Advertencia: ", " El resultado de la consulta fue vacio.");
		}

		if (result is Cliente) {
			cliente = result as Cliente;

			if (!emitido) {
				// Obtener facturas Grabadas del cliente.
				// En el caso de este tener facturas Grabadas, 
				// mostrarlas y permitir seleccionar una.
				cliente.obtenerDocumentosGrabados();

				if (comprobante && comprobante.isNotaCreditoFinanciera()) {
					planPagos = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
					condicion = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
				} else {
					if (cliente.planPagos) {
						planPagos = cliente.planPagos;
						condicion = cliente.planPagos;
					} else {
						planPagos = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
						condicion = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
					}
				}

			}
			if (cliente.vendedor) {
				vendedor = cliente.vendedor;
			} else {
				for each (var v:Vendedor in CatalogoFactory.getInstance().vendedores) {
					if (v.codigo == "099") {
						vendedor = v;
						break;
					}
				}
			}

			if (vendedor) {
				if (comisiones.participaciones.length == 0) {
					var _nueva:ParticipacionVendedor = new ParticipacionVendedor();
					_nueva.vendedor = vendedor;

					var encargadoDeCuenta:Vendedor;
					if (cliente.encargadoCuenta) {
						for each (var v:Vendedor in CatalogoFactory.getInstance().vendedores) {
							if (cliente.encargadoCuenta == v.codigo) {
								encargadoDeCuenta = v;
								break;
							}
						}
					}

					if (encargadoDeCuenta && (encargadoDeCuenta.codigo != vendedor.codigo)) {
						var _nueva2:ParticipacionVendedor = new ParticipacionVendedor();
						_nueva2.vendedor = encargadoDeCuenta;

						_nueva.porcentaje = 50;
						_nueva2.porcentaje = 50;

						comisiones.participaciones.addItem(_nueva);
						comisiones.participaciones.addItem(_nueva2);
					} else {
						_nueva.porcentaje = 100;
						comisiones.participaciones.addItem(_nueva);
					}


					dispatchEvent(new Event("_changeComisiones"));

				} else if (comisiones.participaciones.length == 1) {
					ParticipacionVendedor(comisiones.participaciones[0]).vendedor = vendedor;
					dispatchEvent(new Event("_changeComisiones"));

				}
			}

			if (cliente.preciosVenta && !emitido) {
				preciosVenta = null;

				for each (var pvu:PreciosVenta in CatalogoFactory.getInstance().preciosVentaUsuario) {
					if (pvu.codigo == cliente.preciosVenta.codigo) {
						preciosVenta = cliente.preciosVenta;
						break;
					}
				}

				if (!preciosVenta) {
					var precioVentaId:String = String(CatalogoFactory.getInstance().parametrosAdministracion.precioVentaIdParAdm);
					for each (var pvu2:PreciosVenta in CatalogoFactory.getInstance().preciosVentaUsuario) {
						if (pvu2.codigo == precioVentaId) {
							preciosVenta = pvu2;
							break;
						}
					}
				}
			}

			var hayLineasVenta:Boolean = !esRecibo() && (lineas.lineas && (lineas.lineas.length > 1 || Number(LineaDocumento(lineas.lineas[0]).cantidad) > 0));
			if (!emitido && (moneda == null || !hayLineasVenta)) {
				var mdaCliente:Moneda = (comprobante.esProceso90()) ? CatalogoFactory.getInstance().monedas[1] : ((comprobante.esProceso14()) ? CatalogoFactory.getInstance().monedas[4] : (comprobante.esProceso80() ? CatalogoFactory.getInstance().monedas[0] : (cliente.moneda ? cliente.moneda : CatalogoFactory.getInstance().monedas[1])));
				var remObj:RemoteObject = new RemoteObject();
				remObj.destination = "CreatingRpc";
				remObj.channelSet = ServerConfig.getInstance().channelSet;
				remObj.addEventListener(FaultEvent.FAULT, handleFault);

				remObj.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
						var esCotizacionDeVenta:Boolean = evt.result as Boolean;
						if (esCotizacionDeVenta) {
							moneda = mdaCliente;
							if (moneda.nombre.indexOf("*") <= 0) { // Agrega las monedas oficiales.
								comprobante.aster = false;
							} else {
								comprobante.aster = true;
							}
							update();
						} else if (esRecibo()) {
							if (!docRecMda) {
								if (comprobante.aster) {
									docRecMda = mdaCliente && mdaCliente.nombre.indexOf("*") > 0 ? mdaCliente : CatalogoFactory.getInstance().monedas[3];
								} else {
									docRecMda = mdaCliente && mdaCliente.nombre.indexOf("*") < 1 ? mdaCliente : CatalogoFactory.getInstance().monedas[0];
								}								
							} 
							moneda = docRecMda;
						} else {
							if ((comprobante.aster && mdaCliente.aster) || (!comprobante.aster && !mdaCliente.aster)) {
								moneda = mdaCliente;
							} else {
								if (!comprobante.aster) {
									moneda = CatalogoFactory.getInstance().monedas[0]; // Pesos oficiales
								} else {
									moneda = CatalogoFactory.getInstance().monedas[3]; // Pesos NO oficiales.
								}
							}
						}
					});

				remObj.showBusyCursor = false;
				remObj.esCotizacionDeVenta(comprobante.codigo);
			}
			
			if (cliente.contacto.ctoRUT && cliente.contacto.ctoRUT.length == 12) {
				rut = cliente.contacto.ctoRUT;
				tipoDoc = "R";
			} else {
				rut = Utils.clean_ci(cliente.contacto.ctoDocumento);
				if (cliente.contacto.ctoDocumentoTipo == "R") {
					tipoDoc = "R";
				} else {
					tipoDoc = "C";
				}
				
			}
			dispatchEvent(new Event("_changeTipoDoc"));

			razonSocial = cliente.contacto.ctoRSocial;
			direccion = cliente.contacto.ctoDireccion;

			if (cliente.contacto.ctoTelefono) {
				if (cliente.contacto.ctoTelefono.length > 30) {
					telefono = cliente.contacto.ctoTelefono.substring(0, 30);
				} else {
					telefono = cliente.contacto.ctoTelefono;
				}
			} else {
				telefono = null;
			}

			departamento = null;
			if (cliente.contacto) {
				cargarDepartamento(cliente.contacto);
			}
		}
	}

	public function cargarDepartamento(contacto:Contacto):void {
		if (contacto) {
			var dptoCodigo:String = contacto.deptoIdCto;
			for each (var dpto:Object in CatalogoFactory.getInstance().departamentos) {
				if (dptoCodigo == dpto.codigo) {
					departamento = dpto.nombre;
					break;
				}
			}
		}
	}

	private function filtrarArticulos(item:Object):Boolean {
		var articulo:Articulo = item as Articulo;
		var codigo:String = articulo.codigo;

		var filtrar:Boolean = false;
		if (codigo) {
			filtrar = codigo.toLowerCase().match(new RegExp("^" + cliente.codigo.toLowerCase(), 'i'));
		}
		return filtrar;
	}


	public function updateLineasVenta(moneda1:String, moneda2:String):void {
		var items:ArrayCollection = lineas.lineas;

		for each (var linea:LineaDocumento in items) {
			var precio:BigDecimal = linea.precio ? new BigDecimal(linea.precio).setScale(4, MathContext.ROUND_UP) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_UP);
			var costo:BigDecimal = linea.costo ? new BigDecimal(linea.costo).setScale(4, MathContext.ROUND_UP) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_UP);
			var precioDist:BigDecimal = linea.precioDistribuidor ? new BigDecimal(linea.precioDistribuidor).setScale(4, MathContext.ROUND_UP) : BigDecimal.ZERO.setScale(4, MathContext.ROUND_UP);

			linea.precio = updateMoneda(moneda1, moneda2, precio).toString();
			linea.costo = updateMoneda(moneda1, moneda2, costo).toString();
			linea.precioDistribuidor = updateMoneda(moneda1, moneda2, precioDist).toString();
		}

		update();

	}

	public function updateMoneda(moneda1:String, moneda2:String, value:BigDecimal):BigDecimal {
		var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();

		var dolarCompraStr:String = cotizaciones.cotizaciones.dolarCompra.@value;
		var dolarVentaStr:String = cotizaciones.cotizaciones.dolarVenta.@value;
		var euroCompraStr:String = cotizaciones.cotizaciones.euroCompra.@value;
		var euroVentaStr:String = cotizaciones.cotizaciones.euroVenta.@value;
		var euroCompraDStr:String = cotizaciones.cotizaciones.euroCompraXDolar.@value;
		var euroVentaDStr:String = cotizaciones.cotizaciones.euroVentaXDolar.@value;


		var dolarCompra:BigDecimal = new BigDecimal(dolarCompraStr);
		var dolarVenta:BigDecimal = new BigDecimal(dolarVentaStr);

		var euroCompra:BigDecimal = new BigDecimal(euroCompraStr);
		var euroVenta:BigDecimal = new BigDecimal(euroVentaStr);

		var euroCompraDolar:BigDecimal = new BigDecimal(euroCompraDStr);
		var euroVentaDolar:BigDecimal = new BigDecimal(euroVentaDStr);

		if (moneda1 == Moneda.PESOS || moneda1 == Moneda.PESOS_ASTER) {
			if (moneda2 == Moneda.DOLARES || moneda2 == Moneda.DOLARES_ASTER) { // OK
				return value.divideScaleRound(dolarCompra, 4, MathContext.ROUND_HALF_UP);
			} else if (moneda2 == Moneda.EUROS || moneda2 == Moneda.EUROS_ASTER) { // OK
				return value.divideScaleRound(euroCompra, 4, MathContext.ROUND_HALF_UP);
			}

		} else if (moneda1 == Moneda.DOLARES || moneda1 == Moneda.DOLARES_ASTER) {
			if (moneda2 == Moneda.PESOS || moneda2 == Moneda.PESOS_ASTER) { // OK
				return value.multiply(dolarVenta);
			} else if (moneda2 == Moneda.EUROS || moneda2 == Moneda.EUROS_ASTER) { // OK
				return value.divideScaleRound(euroCompraDolar, 4, MathContext.ROUND_HALF_UP);
			}

		} else if (moneda1 == Moneda.EUROS || moneda1 == Moneda.EUROS_ASTER) {
			if (moneda2 == Moneda.PESOS || moneda2 == Moneda.PESOS_ASTER) { // OK
				return value.multiply(euroVenta);
			} else if (moneda2 == Moneda.DOLARES || moneda2 == Moneda.DOLARES_ASTER) { // OK
				return value.multiply(euroVentaDolar);
			}
		}

		return value;
	}


	public function update(ajustarPrecios:Boolean = false, factor:BigDecimal = null):void {
		if (ajustarPrecios) {
			var items:ArrayCollection = lineas.lineas;
			for each (var lineaDocumento:LineaDocumento in items) {
				if (lineaDocumento.coeficienteImp && lineaDocumento.coeficienteImp.length > 0) {
					lineaDocumento.updateLineaPrecio(new BigDecimal(lineaDocumento.coeficienteImp));
				} else {
					lineaDocumento.updateLineaPrecio(factor);
				}
			}
		}
		
		if (!emitido || _total == null) {
			_total = getTotalRedondeado();
		}
		if (!emitido || _subTotal == null) {
			_subTotal = getSubTotal();
		}
		if (!emitido || _iva == null) {
			_iva = getIva();
		}

		_costo = getCostoTotal();
		_precioDist = getPrecioDistTotal();

		if (cuotasDocumento == null) {
			cuotasDocumento = new CuotasDocumento();
		}
		cuotasDocumento.documento = this;
		cuotasDocumento.inicializarCuotas();

		if (cliente) {
			cargarDepartamento(cliente.contacto);
		} else if (proveedor) {
			cargarDepartamento(proveedor.contacto);
		}

		dispatchEvent(new Event("changeLineasVenta"));
	}

	public function get nuevo():Boolean {
		return _nuevo;
	}

	public function set nuevo(value:Boolean):void {
		_nuevo = value;
	}

	public function set participaciones(participaciones:ArrayCollection):void {
		this.comisiones.participaciones = participaciones;
	}

	public function get participaciones():ArrayCollection {
		return this.comisiones.participaciones;
	}

	public function getCostoOperativo():BigDecimal {
		if (costoOperativo) {
			return new BigDecimal(costoOperativo);
		} else {
			return null;
		}
	}

	/**
	 * Inicializa campos del documento a partir del cliente establecido. No tiene efecto si el valor es null.
	 */
	/*public function tomarCamposDelCliente(codigoCliente:String):void {
		if (codigoCliente == null) {
			return;
		}

		// Obtener todos los dataos del cliente ...
		clienteRemObj.findCatalogEntity("Cliente", codigoCliente);
	}*/


	/**
	 * Inicializa campos del documento a partir del cliente establecido. No tiene efecto si el valor es null.
	 */
	public function tomarCamposDelProveedor(codigoProveedor:String):void {
		if (codigoProveedor == null) {
			return;
		}

		// Obtener todos los dataos del cliente ...
		proveedorRemObj.findCatalogEntity("Proveedor", codigoProveedor);
	}

	public function get docRecNeto():String {
		return _docRecNeto;
	}
	
	public function set docRecNeto(value:String):void {
		_docRecNeto = value;
	}	
	
	public function getDocRecNeto():BigDecimal {
		if (!_docRecNeto || _docRecNeto.length == 0) {
			return BigDecimal.ZERO.setScale(4);
		}
		return new BigDecimal(_docRecNeto).setScale(4);
	}
	
	[Bindable(event="changeLineasVenta")]
	public override function get total():String {
		if (_total != null) {
			return _total.setScale(4).toString();
		}
		return getTotalRedondeado().toString();
	}

	public override function set total(value:String):void {
		if (!value || value.length == 0) {
			_total = BigDecimal.ZERO.setScale(4);
		} else {
			_total = new BigDecimal(value).setScale(4);
		}
	}

	[Bindable(event="changeLineasVenta")]
	public function get subTotal():String {
		if (_subTotal != null) {
			return _subTotal.setScale(4).toString();
		}
		return BigDecimal.ZERO.setScale(4).toString();
	}

	public function set subTotal(value:String):void {
		_subTotal = new BigDecimal(value).setScale(4, MathContext.ROUND_UP);
	}


	[Bindable(event="changeLineasVenta")]
	public function get iva():String {
		if (_iva != null) {
			return _iva.setScale(4).toString();
		}
		return BigDecimal.ZERO.setScale(4).toString();
	}

	public function set iva(value:String):void {
		if (value) {
			_iva = new BigDecimal(value).setScale(4, MathContext.ROUND_UP);
		} else {
			_iva = BigDecimal.ZERO.setScale(4);
		}
	}

	public function getTotalRedondeado():BigDecimal {
		return getRedondeoExacto(getTotalExacto());
	}

	private function getRedondeoExacto(exacto:BigDecimal):BigDecimal {
		if (moneda) {
			return exacto.setScale(moneda.getRedondeo(), MathContext.ROUND_HALF_EVEN);
		} else {
			return exacto.setScale(4, MathContext.ROUND_HALF_UP);
		}
	}


	public function getTotalExacto():BigDecimal {
		var items:ArrayCollection = lineas.lineas;
		var sum:BigDecimal = BigDecimal.ZERO;
		for each (var lineaDocumento:LineaDocumento in items) {
			if (!lineaDocumento.articulo) {
				continue;
			}
			sum = sum.add(lineaDocumento.getSubTotal().setScale(2, MathContext.ROUND_HALF_EVEN));
			if (comprobanteComputaIva()) {
				sum = sum.add(lineaDocumento.getIva().setScale(2, MathContext.ROUND_HALF_EVEN));
			}
		}
		return sum;
	}

	public function comprobanteComputaIva():Boolean {
		switch (comprobante.codigo) {
			case '122':
			case '124':
				return false;
		}
		return !(comprobante.aster || comprobante.exento);
	}

	// ---------------------------------
	// Calcular total, subtotal, costo, iva
	// ---------------------------------

	public function getIva():BigDecimal {
		if (!comprobanteComputaIva()) {
			return BigDecimal.ZERO.setScale(4);
		} else {
			var items:ArrayCollection = lineas.lineas;
			var sum:BigDecimal = BigDecimal.ZERO;
			for each (var lineaDocumento:LineaDocumento in items) {
				if (!lineaDocumento.articulo) {
					continue;
				}
				sum = sum.add(lineaDocumento.getIva());
			}
			return sum.setScale(4, MathContext.ROUND_HALF_EVEN);
		}
	}

	public function getSubTotal():BigDecimal {
		var items:ArrayCollection = lineas.lineas;
		var sum:BigDecimal = BigDecimal.ZERO;
		for each (var lineaDocumento:LineaDocumento in items) {
			if (!lineaDocumento.articulo) {
				continue;
			}
			sum = sum.add(lineaDocumento.getSubTotal());
		}
		return sum.setScale(4, MathContext.ROUND_UP);
	}

	private function getCostoTotal():BigDecimal {
		var sum:BigDecimal = BigDecimal.ZERO;
		for each (var lineaDocumento:LineaDocumento in lineas.lineas) {
			if (!lineaDocumento.articulo) {
				continue;
			}
			sum = sum.add(lineaDocumento.getCostoTotal());
		}
		return sum;
	}

	private function getPrecioDistTotal():BigDecimal {
		var sum:BigDecimal = BigDecimal.ZERO;
		for each (var lineaDocumento:LineaDocumento in lineas.lineas) {
			if (!lineaDocumento.articulo) {
				continue;
			}
			sum = sum.add(lineaDocumento.getPrecioBaseDistribuidorTotal());
		}
		return sum;
	}

	private function getCostoTotalServicios():BigDecimal {
		var items:ArrayCollection = lineas.lineas;
		var sum:BigDecimal = BigDecimal.ZERO;
		for each (var linea:LineaDocumento in items) {
			if (!linea.articulo) {
				continue;
			}
			if (linea.esArticuloServicio()) {
				sum = sum.add(linea.getCostoTotal());
			}
		}
		return sum;

	}


	/**
	 * Es la sumatoria de linea.dtoImp1 + linea.dtoImp2 + linea.dtoImp3
	 *
	 * @return descuentos
	 */
	[Bindable(event="changeLineasVenta")]
	public function updateDescuentos():BigDecimal {
		if (!comprobante.isRecibo()) {
			var items:ArrayCollection = lineas.lineas;
			var sum:BigDecimal = BigDecimal.ZERO;
			for each (var lineaDocumento:LineaDocumento in items) {
				if (!lineaDocumento.articulo) {
					continue;
				}
				sum = sum.add(lineaDocumento.getImporteDescuentoTotal());
			}
			descuentos = sum.setScale(4, MathContext.ROUND_HALF_UP).toString();
			
			return sum.setScale(4, MathContext.ROUND_HALF_UP);
		} else {
			return BigDecimal.ZERO;
		}
	}

	/**
	 * El redondeo se resta al importe exacto de la factura (la suma de las
	 * linas) para obtener el importe "real".
	 */
	[Bindable(event="changeLineasVenta")]
	public function get redondeo():BigDecimal {
		var exacto:BigDecimal = getTotalExacto();
		var redondeado:BigDecimal = getTotalRedondeado();

		return exacto.subtract(redondeado).setScale(4);
	}


	public function getUtilidadEstimada():BigDecimal {
		var totalcuesta:BigDecimal = BigDecimal.ZERO;
		var totalventa:BigDecimal = BigDecimal.ZERO;

		for each (var linea:LineaDocumento in lineas.lineas) {
			if (!linea.articulo) {
				continue;
			}
			totalcuesta = totalcuesta.add(linea.getCostoTotal());
			totalventa = totalventa.add(linea.getNetoTotal());
		}

		if (entrega != null) {
			totalcuesta = totalcuesta.add(costoEstimadoEntrega ? new BigDecimal(costoEstimadoEntrega) : BigDecimal.ZERO);
		}

		if (totalventa.compareTo(BigDecimal.ZERO) != 0) {
			return (totalventa.subtract(totalcuesta)).multiply(new BigDecimal(100)).divideScaleRound(totalventa, 4, MathContext.ROUND_HALF_UP);
		}
		return null;
	}

	/**
	 * Se trata del porcentaje de ganancia, pero considerando solo la renta comercial y nunca el costo operativo asociado.
	 * El calculo se diferencia notablemente del de la utilidad por linea en que considera el costo
	 * asociado a la forma de entrega.
	 *
	 * @param  costoEntrega Costo de la entrega expresada en la moneda del documento
	 */
	[Bindable(event="changeLineasVenta")]
	public function getUtilidad():BigDecimal {
		if (entrega) {
			var totalcuesta:BigDecimal = BigDecimal.ZERO;
			var totalventa:BigDecimal = BigDecimal.ZERO;

			for each (var linea:LineaDocumento in lineas.lineas) {
				if (!linea.articulo) {
					continue;
				}
				totalcuesta = totalcuesta.add(linea.getCostoTotal());
				totalventa = totalventa.add(linea.getNetoTotal());
			}

			if (lineas.lineas.length < 1) {
				return BigDecimal.ZERO;
			}

			// Agregar el costo de la entrega al costo
			if (entrega != null) {
				var costoEntrega:BigDecimal = entrega.costo ? new BigDecimal(entrega.costo) : BigDecimal.ZERO;

				if (moneda.codigo == Moneda.PESOS || moneda.codigo == Moneda.PESOS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
					var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();
					var dolar:BigDecimal;
					if (docTCC != null) {
						dolar = new BigDecimal(docTCC);
					} else {
						var dolarStr:String = cotizaciones.cotizaciones.dolarVenta.@value;
						dolar = new BigDecimal(dolarStr);
					}
					costoEntrega = costoEntrega.multiply(dolar);

				} else if (moneda.codigo == Moneda.EUROS || moneda.codigo == Moneda.EUROS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
					var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();

					var euroStr:String = cotizaciones.cotizaciones.euroVenta.@value;
					var euro:BigDecimal = new BigDecimal(euroStr);

					costoEntrega = costoEntrega.divideScaleRound(euro, 4, MathContext.ROUND_HALF_UP);
				}
				totalcuesta = totalcuesta.add(costoEntrega);
			}
			if (totalventa.compareTo(BigDecimal.ZERO) != 0) {
				return (totalventa.subtract(totalcuesta)).multiply(new BigDecimal(100)).divideScaleRound(totalventa, 4, MathContext.ROUND_HALF_UP);
			} else {
				return BigDecimal.ZERO;
			}

		} else {
			if (ventaNeta.compareTo(BigDecimal.ZERO) == 0) {
				return BigDecimal.ZERO;
			} else {
				if (getCostoTotalServicios() == BigDecimal.ZERO) {
					return getRentaNetaComercial().multiply(new BigDecimal(100)).divideScaleRound(ventaNeta, 4, MathContext.ROUND_HALF_UP);
				} else {
					var totalcuesta:BigDecimal = BigDecimal.ZERO;
					var totalventa:BigDecimal = BigDecimal.ZERO;

					for each (var linea:LineaDocumento in lineas.lineas) {
						if (!linea.articulo) {
							continue;
						}
						totalcuesta = totalcuesta.add(linea.getCostoTotal());
						totalventa = totalventa.add(linea.getNetoTotal());
					}
					if (totalventa.compareTo(BigDecimal.ZERO) != 0) {
						return (totalventa.subtract(totalcuesta)).multiply(new BigDecimal(100)).divideScaleRound(totalventa, 4, MathContext.ROUND_HALF_UP);
					} else {
						return BigDecimal.ZERO;
					}
				}
			}
		}
	}



	/**
	 * Se trata del porcentaje de ganancia, pero considerando solo la renta comercial y nunca el costo operativo asociado.
	 * El calculo se diferencia notablemente del de la utilidad por linea en que considera el costo
	 * asociado a la forma de entrega.
	 *
	 * @param  costoEntrega Costo de la entrega expresada en la moneda del documento
	 */
	[Bindable(event="changeLineasVenta")]
	public function getUtilidadDistribuidor():BigDecimal {
		if (entrega) {
			var totalcuesta:BigDecimal = BigDecimal.ZERO;
			var totalventa:BigDecimal = BigDecimal.ZERO;

			for each (var linea:LineaDocumento in lineas.lineas) {
				if (!linea.articulo) {
					continue;
				}
				totalcuesta = totalcuesta.add(linea.getPrecioBaseDistribuidorTotal());
				totalventa = totalventa.add(linea.getNetoTotal());
			}

			if (lineas.lineas.length < 1) {
				return BigDecimal.ZERO;
			}

			// Agregar el costo de la entrega al costo
			if (entrega != null) {
				var costoEntrega:BigDecimal = entrega.costo ? new BigDecimal(entrega.costo) : BigDecimal.ZERO;

				if (moneda.codigo == Moneda.PESOS || moneda.codigo == Moneda.PESOS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
					var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();
					var dolar:BigDecimal;
					if (docTCC != null) {
						dolar = new BigDecimal(docTCC);
					} else {
						var dolarStr:String = cotizaciones.cotizaciones.dolarVenta.@value;
						dolar = new BigDecimal(dolarStr);
					}
					costoEntrega = costoEntrega.multiply(dolar);

				} else if (moneda.codigo == Moneda.EUROS || moneda.codigo == Moneda.EUROS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
					var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();

					var euroStr:String = cotizaciones.cotizaciones.euroVenta.@value;
					var euro:BigDecimal = new BigDecimal(euroStr);

					costoEntrega = costoEntrega.divideScaleRound(euro, 4, MathContext.ROUND_HALF_UP);
				}
				totalcuesta = totalcuesta.add(costoEntrega);
			}
			if (totalventa.compareTo(BigDecimal.ZERO) != 0) {
				return (totalventa.subtract(totalcuesta)).multiply(new BigDecimal(100)).divideScaleRound(totalventa, 4, MathContext.ROUND_HALF_UP);
			} else {
				return BigDecimal.ZERO;
			}

		} else {
			if (ventaNeta.compareTo(BigDecimal.ZERO) == 0) {
				return BigDecimal.ZERO;
			} else {
				if (getCostoTotalServicios() == BigDecimal.ZERO) {
					return getRentaNetaComercial().multiply(new BigDecimal(100)).divideScaleRound(ventaNeta, 4, MathContext.ROUND_HALF_UP);
				} else {
					var totalcuesta:BigDecimal = BigDecimal.ZERO;
					var totalventa:BigDecimal = BigDecimal.ZERO;

					for each (var linea:LineaDocumento in lineas.lineas) {
						if (!linea.articulo) {
							continue;
						}
						totalcuesta = totalcuesta.add(linea.getPrecioBaseDistribuidorTotal());
						totalventa = totalventa.add(linea.getNetoTotal());
					}
					if (totalventa.compareTo(BigDecimal.ZERO) != 0) {
						return (totalventa.subtract(totalcuesta)).multiply(new BigDecimal(100)).divideScaleRound(totalventa, 4, MathContext.ROUND_HALF_UP);
					} else {
						return BigDecimal.ZERO;
					}
				}
			}
		}
	}


	/**
	 * Si el comprobante mueve caja, establece la forma pago por defecto, EFECTIVO.
	 */
	public function establecerFormaPago():void {
		if (comprobante.isMueveCaja()) {
			if (pagos == null || pagos.length == 0) {
				pagos = new ArrayCollection();
				pagos.addItem(new DocumentoFormaPago(this));
			}
		} else {
			pagos = null;
		}
	}

	/**
	 * Tira validaciones sobre los datos ingresados, en busqueda de inconsistencias y
	 * datos ausentes.
	 * @throws ValidationException
	 *
	 *
	 */
	public function validate():void {
		if (comprobante.isCredito()) {
			cuotasDocumento.validate();
		}
	}

	public function isEmitible():Boolean {
		return comprobante.isEmitible();
	}

	/**
	 * Calcula la deuda considerando los descuentos prometidos que se pueden
	 * concretar si el cliente pagara en la fecha especificada.
	 *
	 * Cada comprobante define una serie de descuentos prometidos, decrecientes a medida
	 * que aumentan los dias de retraso. De ellos, el algoritmo se queda con el mejor (desde
	 * el punto de vista del cliente)  descuento que puede ser aplicado.
	 *
	 *
	 * @param today
	 * @return
	 */
	public function calcularDeuda(today:Date):BigDecimal {
		return new BigDecimal(0); //TODO: cuotasDocumento.calcularDeuda(today, getTotal().subtract(getSaldo()));
	}

	public function calcularMontoDescuentoEsperado(monto:BigDecimal):BigDecimal {
		return comprobante.calcularMontoDescuentoPrometido(monto);
	}

	/**
	 *
	 * @return costo total
	 */
	[Bindable(event="changeLineasVenta")]
	public function get costo():String {
		if (_costo != null) {
			return _costo.toString();
		}
		return null;
	}

	public function set costo(costo:String):void {
		_costo = new BigDecimal(costo).setScale(4);
	}

	/**
	 *
	 * @return utilidad total
	 */
	[Bindable(event="changeLineasVenta")]
	public function get utilidad():String {
		if (_utilidad != null) {
			return _utilidad.toString();
		}
		return null;
		
	}

	public function set utilidad(value:String):void {
		_utilidad = new BigDecimal(value).setScale(4);
	}


	/**
	 *
	 * @return Renta Neta Comercial
	 */
	[Bindable(event="changeLineasVenta")]
	public function get rentaNetaComercial():String {
		if (_rentaNetaComercial != null) {
			return _rentaNetaComercial.toString();
		}
		return null;

	}

	public function set rentaNetaComercial(value:String):void {
		_rentaNetaComercial = new BigDecimal(value).setScale(4);
	}

	/**
	 *
	 * @return precio distribuidor total
	 */
	[Bindable(event="changeLineasVenta")]
	public function get precioDist():String {
		if (_precioDist != null) {
			return _precioDist.toString();
		}
		return null;

	}

	public function set precioDist(value:String):void {
		_precioDist = new BigDecimal(value).setScale(4);
	}


	public function invalidarRedundancia():void {
		_costo = null;
		_subTotal = null;
		_total = null;
	}


	/**
	 * La renta neta comercial es un concepto util a la hora de liquidar
	 * comisiones. Se define como venta neta - costo, donde venta neta es el
	 * total del documento sin iva y descontando el descuento esperado asociado
	 * al comprobante (ademas, el signo es negativo en caso de devoluciones).
	 *
	 * Suena raro que se aplique el descuento prometido? El hecho es que si el
	 * descuento realmente aplicado (en la cobranza) es menor, el beneficio
	 * para fulltime aparece como ganancia financiera, que se calcula en otro lado.
	 *
	 *
	 * @return
	 */
	[Bindable(event="changeLineasVenta")]
	public function getRentaNetaDistComercial():BigDecimal {
		var _ventaNeta:BigDecimal = ventaNeta;
		var _precioDst:BigDecimal = getPrecioDistTotal(); //new BigDecimal(precioDist); 
		var precioDistCSigno:BigDecimal = comprobante.isDevolucion() ? _precioDst.negate() : _precioDst;

		if (!comprobante.isDevolucion() && entrega != null) { // Agregar costo de entrega
			if (moneda.codigo == Moneda.PESOS || moneda.codigo == Moneda.PESOS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
				var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();

				var dolar:BigDecimal;
				if (docTCC) {
					dolar = new BigDecimal(docTCC);
				} else {
					var dolarStr:String = cotizaciones.cotizaciones.dolarVenta.@value;
					dolar = new BigDecimal(dolarStr);
				}
				var entregaValor:BigDecimal = new BigDecimal(entrega.costo);
				precioDistCSigno = precioDistCSigno.add(entregaValor.multiply(dolar));
			} else if (moneda.codigo == Moneda.EUROS || moneda.codigo == Moneda.EUROS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
				var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();

				var euroStr:String = cotizaciones.cotizaciones.euroVenta.@value;
				var euro:BigDecimal = new BigDecimal(euroStr);

				var entregaValor:BigDecimal = new BigDecimal(entrega.costo);
				precioDistCSigno = precioDistCSigno.add(entregaValor.divideScaleRound(euro, 4, MathContext.ROUND_HALF_UP));
			} else {
				precioDistCSigno = precioDistCSigno.add(new BigDecimal(entrega.costo));
			}
		}

		return ventaNeta.subtract(precioDistCSigno);
	}


	[Bindable(event="changeLineasVenta")]
	public function getRentaNetaComercial():BigDecimal {
		var _ventaNeta:BigDecimal = ventaNeta;
		var _costo:BigDecimal = getCostoTotal();
		var costoCSigno:BigDecimal = comprobante.isDevolucion() ? _costo.negate() : _costo;

		if (!comprobante.isDevolucion() && entrega != null) { // Agregar costo de entrega
			var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();
			if (moneda.codigo == Moneda.PESOS || moneda.codigo == Moneda.PESOS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
				var dolar:BigDecimal;
				if (docTCC != null) {
					dolar = new BigDecimal(docTCC);
				} else {
					var dolarStr:String = cotizaciones.cotizaciones.dolarVenta.@value;
					dolar = new BigDecimal(dolarStr);
				}
				var entregaValor:BigDecimal = new BigDecimal(entrega.costo);
				costoCSigno = costoCSigno.add(entregaValor.multiply(dolar));

			} else if (moneda.codigo == Moneda.EUROS || moneda.codigo == Moneda.EUROS_ASTER) { // El costo de entrega esta siempre en dólares por lo que tengo q  //Falta calcualr si la factura esta en euros
				var euroStr:String = cotizaciones.cotizaciones.euroVenta.@value;
				var euro:BigDecimal = new BigDecimal(euroStr);

				var entregaValor:BigDecimal = new BigDecimal(entrega.costo);
				costoCSigno = costoCSigno.add(entregaValor.divideScaleRound(euro, 4, MathContext.ROUND_HALF_UP));
			} else {
				costoCSigno = costoCSigno.add(new BigDecimal(entrega.costo));
			}
		}
		return ventaNeta.subtract(costoCSigno);
	}


	/**
	 * Ver definicion de venta neta en {@link #getRentaNetaComercial()}
	 *
	 * @return
	 */
	[Bindable(event="changeLineasVenta")]
	public function get ventaNeta():BigDecimal {
		var ventaNeta:BigDecimal = comprobante.aplicarDescuentoPrometido(getSubTotal(), 0, cliente ? cliente.categCliId : null); //llamemosle neta, mas por historia que otra cosa
		return comprobante.isDevolucion() ? ventaNeta.negate().setScale(4, MathContext.ROUND_UP) : ventaNeta.setScale(4, MathContext.ROUND_UP);
	}


	private function handleFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, "Error");
	}

	public static function getNuevoDocumento(comprobante:Comprobante, esRecibo:Boolean = false):Documento {
		var doc:Documento = new Documento(comprobante);

		var fecha:Date = new Date();
		fecha.hours = 12;
		fecha.minutes = 0;
		fecha.seconds = 0;

		doc.fechaDoc = fecha;

		doc.nuevo = true;
		doc.comisiones = new ComisionesDocumento();
		doc.comisiones.documento = doc;

		if (!esRecibo) {
			doc.lineas = new LineasDocumento();
			doc.lineas.documento = doc;
	
			// Agregar una linea vacia al documento
			var lineaDoc:LineaDocumento = new LineaDocumento();
			lineaDoc.articulo = null;
			lineaDoc.documento = doc;
			LineasDocumento(doc.lineas).lineas.addItem(lineaDoc);
		} else {
			doc.planPagos = null;
			doc.cuotasDocumento.cuotas = new ArrayCollection();
			doc.lineas.lineas = new ArrayCollection();
		}

		doc.registroFecha = new Date();
		doc.registroHora = new Date();

		if (GeneralOptions.getInstance().loggedUser.permisoId == Usuario.USUARIO_SUPERVISOR) {
			doc.usuIdAut = GeneralOptions.getInstance().loggedUser.codigo;
		}
		if (CatalogoFactory.getInstance().entrega.length > 0) {
			doc.entrega = CatalogoFactory.getInstance().entrega[0] as Entrega;
		}
		return doc;
	}

	public function get emitido():Boolean {
		return _emitido;
	}

	public function set emitido(value:Boolean):void {
		_emitido = value;
	}

	public function obtenerStock(deposito:String, cuponera:String):void {
		if (!cuponera) {
			return;
		}
		if (!deposito) {
			return;
		}
		remObjStock.getStock(cuponera, deposito);

	}

	private function resultStock(event:ResultEvent):void {
		var value:* = event.result;
		stock = value is String ? new BigDecimal(value) : BigDecimal.ZERO;
	}
	
	public function esRecibo():Boolean {
		return (comprobante.tipo == 5);
	}
	
	public function esCompra():Boolean {
		switch (comprobante.tipo) {
			case 21:
			case 23:
				return comprobante.codigo != "122";
			default:
				return false;
		}
	}
	
	public function esConsumoFinal():Boolean {
		if (tipoDoc == "R" || tipoCFEid == 111 || tipoCFEid == 112) {
			return false;
		}		
		var cotizaciones:CotizacionesModel = CotizacionesModel.getInstance();
		var maxUI:BigDecimal = new BigDecimal("32426"); // Valor de la UI año 2016
		
		if (moneda && moneda.codigo == Moneda.DOLARES) {
			var dolarStr:String = cotizaciones.cotizaciones.dolarVenta.@value;
			var dolar:BigDecimal = new BigDecimal(dolarStr);
			
			maxUI = maxUI.divide(dolar);
		} else if (moneda && moneda.codigo == Moneda.EUROS) {
			var euroStr:String = cotizaciones.cotizaciones.euroVenta.@value;
			var euro:BigDecimal = new BigDecimal(dolarStr);
			
			maxUI = maxUI.divide(euro);
		}
		if (_total.compareTo(maxUI) > 0) {
			return false;
		}		
		return true;

	}
	
	public function updateCaja():void {
		if (GeneralOptions.getInstance().usarCajaPrincipal) {
			cajaId = Caja.CAJA_PRINCIPAL;			
		} else {
			cajaId = comprobante ? comprobante.getCajaId() : null;
		}

	}
	
	public override function clienteLoaded():void {
		if (!emitido) {
			// Obtener facturas Grabadas del cliente.
			// En el caso de este tener facturas Grabadas, 
			// mostrarlas y permitir seleccionar una.
			cliente.obtenerDocumentosGrabados();
			
			// Obtener las facturas pendientes del cliente.
			cliente.obtenerDocumentosPendientes();
			
			if (cliente.planPagos) {
				planPagos = cliente.planPagos;
				condicion = cliente.planPagos;
			} else {
				planPagos = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
				condicion = CatalogoFactory.getInstance().planPagos[1] as PlanPagos;
			}
			
		}
		if (cliente.vendedor) {
			vendedor = cliente.vendedor;
		} else {
			for each (var v:Vendedor in CatalogoFactory.getInstance().vendedores) {
				if (v.codigo == "099") {
					vendedor = v;
					break;
				}
			}
		}
		
		if (vendedor) {
			if (comisiones.participaciones.length == 0) {
				var _nueva:ParticipacionVendedor = new ParticipacionVendedor();
				_nueva.vendedor = vendedor;
				
				var encargadoDeCuenta:Vendedor;
				if (cliente.encargadoCuenta) {
					for each (var v:Vendedor in CatalogoFactory.getInstance().vendedores) {
						if (cliente.encargadoCuenta == v.codigo) {
							encargadoDeCuenta = v;
							break;
						}
					}
				}
				
				if (encargadoDeCuenta && (encargadoDeCuenta.codigo != vendedor.codigo)) {
					var _nueva2:ParticipacionVendedor = new ParticipacionVendedor();
					_nueva2.vendedor = encargadoDeCuenta;
					
					_nueva.porcentaje = 50;
					_nueva2.porcentaje = 50;
					
					comisiones.participaciones.addItem(_nueva);
					comisiones.participaciones.addItem(_nueva2);
				} else {
					_nueva.porcentaje = 100;
					comisiones.participaciones.addItem(_nueva);
				}
				
				
				dispatchEvent(new Event("_changeComisiones"));
				
			} else if (comisiones.participaciones.length == 1) {
				ParticipacionVendedor(comisiones.participaciones[0]).vendedor = vendedor;
				dispatchEvent(new Event("_changeComisiones"));				
			}
			
			
		}
		
		if (cliente.preciosVenta && !emitido) {
			preciosVenta = null;
			
			for each (var pvu:PreciosVenta in CatalogoFactory.getInstance().preciosVentaUsuario) {
				if (pvu.codigo == cliente.preciosVenta.codigo) {
					preciosVenta = cliente.preciosVenta;
					break;
				}
			}
			
			if (!preciosVenta) {
				var precioVentaId:String = String(CatalogoFactory.getInstance().parametrosAdministracion.precioVentaIdParAdm);
				for each (var pvu2:PreciosVenta in CatalogoFactory.getInstance().preciosVentaUsuario) {
					if (pvu2.codigo == precioVentaId) {
						preciosVenta = pvu2;
						break;
					}
				}
			}
		}
		
		var hayLineasVenta:Boolean = !esRecibo() && (lineas.lineas && (lineas.lineas.length > 1 || Number(LineaDocumento(lineas.lineas[0]).cantidad) > 0));
		if (!emitido && (moneda == null || !hayLineasVenta)) {
			var mdaCliente:Moneda = (comprobante.esProceso90()) ? CatalogoFactory.getInstance().monedas[1] : ((comprobante.esProceso14()) ? CatalogoFactory.getInstance().monedas[4] : (comprobante.esProceso80() ? CatalogoFactory.getInstance().monedas[0] : (cliente.moneda ? cliente.moneda : CatalogoFactory.getInstance().monedas[1])));
			var remObj:RemoteObject = new RemoteObject();
			remObj.destination = "CreatingRpc";
			remObj.channelSet = ServerConfig.getInstance().channelSet;
			remObj.addEventListener(FaultEvent.FAULT, handleFault);
			
			remObj.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
				var esCotizacionDeVenta:Boolean = evt.result as Boolean;
				if (esCotizacionDeVenta) {
					moneda = mdaCliente;
					comprobante.aster = moneda.nombre.indexOf("*") > 0;
					update();
				} else if (esRecibo()) {
					if (!docRecMda) {
						if (comprobante.aster) {
							docRecMda = mdaCliente && mdaCliente.nombre.indexOf("*") > 0 ? mdaCliente : CatalogoFactory.getInstance().monedas[3];
						} else {
							docRecMda = mdaCliente && mdaCliente.nombre.indexOf("*") < 1 ? mdaCliente : CatalogoFactory.getInstance().monedas[0];
						}								
					} 
					moneda = docRecMda;

				} else {
					if ((comprobante.aster && mdaCliente.aster) || (!comprobante.aster && !mdaCliente.aster)) {
						moneda = mdaCliente;
					} else {
						moneda = CatalogoFactory.getInstance().monedas[comprobante.aster ? 3 : 0]; 
					}
				}
			});
			
			remObj.showBusyCursor = false;
			remObj.esCotizacionDeVenta(comprobante.codigo);
		}
		
		if (comprobante.isRecibo()) {
			tipoDoc = "R";
			if (cliente.contacto.ctoRUT && cliente.contacto.ctoRUT.length == 12) {
				rut = cliente.contacto.ctoRUT;
			} else {
				rut = null;
			}
		} else {
			if (cliente.contacto.ctoRUT && cliente.contacto.ctoRUT.length == 12) {
				rut = cliente.contacto.ctoRUT;
				tipoDoc = "R";
			} else {
				rut = Utils.clean_ci(cliente.contacto.ctoDocumento);
				if (cliente.contacto.ctoDocumentoTipo == "R") {
					tipoDoc = "R";
				} else {
					tipoDoc = "C";
				}
			}
			
		}

		dispatchEvent(new Event("_changeTipoDoc"));
		
		razonSocial = cliente.contacto.ctoRSocial;
		direccion = cliente.contacto.ctoDireccion;
		
		if (cliente.contacto.ctoTelefono) {
			if (cliente.contacto.ctoTelefono.length > 30) {
				telefono = cliente.contacto.ctoTelefono.substring(0, 30);
			} else {
				telefono = cliente.contacto.ctoTelefono;
			}
		} else {
			telefono = null;
		}
		
		departamento = null;
		if (cliente.contacto) {
			cargarDepartamento(cliente.contacto);
		}
		
	}

	public function get descuentos():String {
		return _descuentos;
	}

	public function set descuentos(value:String):void {
		_descuentos = value;
	}

	
	public function tieneNotasEnLineas():Boolean {
		for each (var l:LineaDocumento in lineas.lineas) {
			if (l.notas && l.notas.length > 0) {
				return true;
			}
		}
		return false;		
		
	}
	
	public function tieneFaturasVincululadas():Boolean {
		for each (var vinculo:VinculoDocumentos in facturasVinculadas) {
			if (vinculo.factura && vinculo.factura.docId && vinculo.factura.docId.length > 0) {
				return true;
			}
		}
		return false;		
		
	}
	
	public function convertirMoneda(monedaOrigen:Moneda, monedaDestino:Moneda, monto:BigDecimal, useTCC:Boolean = true):BigDecimal {
		return convertirMonedaStr(monedaOrigen.codigo, monedaDestino.codigo, monto, useTCC);
	}
	
	public function convertirMonedaStr(monedaOrigen:String, monedaDestino:String, monto:BigDecimal, useTCC:Boolean = true):BigDecimal {
		var tipoCambio:BigDecimal;
		if (useTCC) {
			tipoCambio = docTCF ? new BigDecimal(docTCC) : BigDecimal.ZERO;
		} else {
			tipoCambio = docTCF ? new BigDecimal(docTCC) : BigDecimal.ZERO;
		}
		
		var result:BigDecimal = monto;
		
		// Convertir de Dolar o Euro --> Pesos
		if ((monedaOrigen == Moneda.DOLARES || monedaOrigen == Moneda.EUROS || monedaOrigen == Moneda.DOLARES_ASTER || monedaOrigen == Moneda.EUROS_ASTER) 
			&& (monedaDestino == Moneda.PESOS || monedaDestino == Moneda.PESOS_ASTER)) { 
			result = result.multiply(tipoCambio);
			
		// Convertir de Pesos --> Dolar o Euro 
		} else if ((monedaOrigen == Moneda.PESOS || monedaOrigen == Moneda.PESOS_ASTER) 
			&& (monedaDestino == Moneda.DOLARES || monedaDestino == Moneda.DOLARES_ASTER || monedaDestino == Moneda.EUROS || monedaDestino == Moneda.EUROS_ASTER)) {
			if (tipoCambio.compareTo(BigDecimal.ZERO) == 0) {
				return BigDecimal.ZERO;
			}					
			result = result.divideScaleRound(tipoCambio, 4, MathContext.ROUND_HALF_EVEN);					
		}
		
		return result.setScale(4, MathContext.ROUND_HALF_EVEN);
	}	

}

}



