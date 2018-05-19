//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package util {

import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.conf.ServerConfig;
import biz.fulltime.model.Articulo;
import biz.fulltime.model.Capitulo;
import biz.fulltime.model.CategoriasClientes;
import biz.fulltime.model.Cliente;
import biz.fulltime.model.Comprobante;
import biz.fulltime.model.Contacto;
import biz.fulltime.model.Departamento;
import biz.fulltime.model.Deposito;
import biz.fulltime.model.Entrega;
import biz.fulltime.model.FamiliaArticulos;
import biz.fulltime.model.Fanfold;
import biz.fulltime.model.Moneda;
import biz.fulltime.model.ParametrosAdministracion;
import biz.fulltime.model.PlanPagos;
import biz.fulltime.model.PreciosVenta;
import biz.fulltime.model.Proveedor;
import biz.fulltime.model.Usuario;
import biz.fulltime.model.Vendedor;
import biz.fulltime.model.Zona;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import spark.components.TitleWindow;

[Bindable]
public class CatalogoFactory extends EventDispatcher {

	private static var _instance:CatalogoFactory;

	private var _monedas:ArrayCollection = new ArrayCollection();

	private var _articulos:ArrayCollection = new ArrayCollection();

	private var _articulosActivos:ArrayCollection = new ArrayCollection();

	private var articulosGastos:ArrayCollection = new ArrayCollection();

	private var articulosNC_Fin:ArrayCollection = new ArrayCollection();

	private var articulosNC:ArrayCollection = new ArrayCollection();

	private var articulosAfilados:ArrayCollection = new ArrayCollection();

	private var articulosMNeumaticas:ArrayCollection = new ArrayCollection();

	private var articulosTorneria:ArrayCollection = new ArrayCollection();

	private var articulosProveedor:ArrayCollection = new ArrayCollection();

	private var _clientes:ArrayCollection = new ArrayCollection();

	private var _proveedores:ArrayCollection = new ArrayCollection();

	private var _depositos:ArrayCollection = new ArrayCollection();

	private var _preciosVenta:ArrayCollection = new ArrayCollection();

	private var _vendedores:ArrayCollection = new ArrayCollection();

	private var _comprobantes:ArrayCollection = new ArrayCollection();

	private var _comprobantesUsuario:ArrayCollection = new ArrayCollection();

	private var _preciosVentaUsuario:ArrayCollection = new ArrayCollection();

	private var _entrega:ArrayCollection = new ArrayCollection();

	private var _planPagos:ArrayCollection = new ArrayCollection();

	private var _usuarios:ArrayCollection = new ArrayCollection();

	private var _tareas:ArrayCollection = new ArrayCollection();

	private var _capitulos:ArrayCollection = new ArrayCollection();

	private var _contactos:ArrayCollection = new ArrayCollection();

	private var _zonas:ArrayCollection = new ArrayCollection();

	private var _paises:ArrayCollection = new ArrayCollection();

	private var _cajas:ArrayCollection = new ArrayCollection();

	private var _giros:ArrayCollection = new ArrayCollection();

	private var _familias:ArrayCollection = new ArrayCollection();

	private var _departamentos:ArrayCollection = new ArrayCollection();

	private var _categoriasClientes:ArrayCollection = new ArrayCollection();

	private var _centrosCosto:ArrayCollection = new ArrayCollection();

	private var _rubros:ArrayCollection = new ArrayCollection();

	private var _fanfold:ArrayCollection = new ArrayCollection();

	private var _formasPago:ArrayCollection = new ArrayCollection();
	
	private var _bancos:ArrayCollection = new ArrayCollection();
	

	private var _ivas:ArrayCollection = new ArrayCollection();

	private var trace_text:String = "";

	private var errorPanel:ErrorPanel;

	private var remObjCat:RemoteObject;

	private var helpWindow:TitleWindow;

	private var delay:uint = 3000;

	private var repeat:uint = 1;

	private var catalogo:Number = 0;

	private var _ultimaCotizacion:Number;

	private var _parametrosAdministracion:ParametrosAdministracion;

	private var myTimer:Timer = new Timer(delay, repeat);

	private var reloadTimer:Timer = new Timer(1000 * 60 * 20); //REcargar catalogos cada 20 minutos
	
	public static const INTERFACE_WEB_EVENT:String = "_web";
	
	public static const INTERFACE_DESCK_TOP_EVENT:String = "_desck_top";
	
	public var  _interface :String;
	

	public function CatalogoFactory(caller:Function = null) {
		if (caller != CatalogoFactory.getInstance) {
			throw new Error("CatalogoFactory is a singleton class, use getInstance() instead");
		}

		remObjCat = new RemoteObject();
		remObjCat.destination = "CreatingRpc";
		remObjCat.channelSet = ServerConfig.getInstance().channelSet;
		remObjCat.addEventListener(ResultEvent.RESULT, result);
		remObjCat.addEventListener(FaultEvent.FAULT, handleFault);
		remObjCat.showBusyCursor = false;

		myTimer.addEventListener(TimerEvent.TIMER, timerHandler);
		myTimer.addEventListener(TimerEvent.TIMER_COMPLETE, completeHandler);

		reloadTimer.addEventListener(TimerEvent.TIMER, timerReloadHandler);
		reloadTimer.start();
	}

	public function get bancos():ArrayCollection {
		return _bancos;
	}

	public function set bancos(value:ArrayCollection):void {
		_bancos = value;
	}

	private function timerReloadHandler(e:TimerEvent):void {
		loadAllCatalogs(false);
	}

	public function get centrosCosto():ArrayCollection {
		return _centrosCosto;
	}

	public function set centrosCosto(value:ArrayCollection):void {
		_centrosCosto = value;
	}

	public function get rubros():ArrayCollection {
		return _rubros;
	}

	public function set rubros(value:ArrayCollection):void {
		_rubros = value;
	}

	public function updateArticulosProveedor(provId:String):void {
		articulosProveedor = new ArrayCollection();
		for each (var elem:Articulo in _articulos) {
			if (elem.prvIdArt == provId || (elem.codigo == "ARTICULOS VARIOS" || elem.codigo == "ARTICULOS VARIOS EX")) {
				articulosProveedor.addItem(elem);
			}
		}
	}

	public function refrescarArticulos():void {
		var remObj:RemoteObject = new RemoteObject();
		remObj.destination = "CreatingRpc";
		remObj.channelSet = ServerConfig.getInstance().channelSet;
		remObj.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
				var values:ArrayCollection = event.result as ArrayCollection;
				articulos = sort(values);
				articulosGastos = new ArrayCollection();
				articulosNC = new ArrayCollection();
				articulosNC_Fin = new ArrayCollection();
				articulosAfilados = new ArrayCollection();
				articulosMNeumaticas = new ArrayCollection();
				articulosTorneria = new ArrayCollection();

				_articulosActivos = new ArrayCollection();
				for each (var elem:Articulo in articulos) {
					if (elem.activo) {
						_articulosActivos.addItem(elem);
						if (elem.codigo == "GASTOS VARIOS" || elem.codigo == "GASTOS VARIOS2") {
							articulosGastos.addItem(elem);
						}
						if (elem.codigo == "DESCUENTO") {
							articulosNC_Fin.addItem(elem);
						} else if (elem.codigo != "DESCUENTO") {
							articulosNC.addItem(elem);
						}
						if (elem.familiaId.toString().match(new RegExp("^980", 'i'))) {
							articulosAfilados.addItem(elem);
						} else if (elem.familiaId.toString().match(new RegExp("^902", 'i')) || elem.familiaId.toString().match(new RegExp("^903", 'i')) || (elem.codigo == "ARTICULOS VARIOS" || elem.codigo == "ARTICULOS VARIOS EX")) {
							articulosMNeumaticas.addItem(elem);
						} else if (elem.familiaId.toString().match(new RegExp("^970", 'i')) || (elem.codigo == "ARTICULOS VARIOS" || elem.codigo == "ARTICULOS VARIOS EX")) {
							articulosTorneria.addItem(elem);
						}

					}
				}

			});
		remObj.addEventListener(FaultEvent.FAULT, handleFault);
		remObj.showBusyCursor = false;
		remObj.getCatalogoByName("Articulo");
	}


	public function get paises():ArrayCollection {
		return _paises;
	}

	public function set paises(value:ArrayCollection):void {
		_paises = value;
	}

	public function get giros():ArrayCollection {
		return _giros;
	}

	public function set giros(value:ArrayCollection):void {
		_giros = value;
	}

	public function get preciosVentaUsuario():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var pv:PreciosVenta in _preciosVentaUsuario) {
			aux.addItem(pv);
		}
		return aux;
	}

	public function set preciosVentaUsuario(value:ArrayCollection):void {
		_preciosVentaUsuario = value;
	}

	public function get comprobantesUsuario():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Comprobante in _comprobantesUsuario) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set comprobantesUsuario(value:ArrayCollection):void {
		_comprobantesUsuario = value;
	}

	public function get ultimaCotizacion():Number {
		return _ultimaCotizacion;
	}

	public function set ultimaCotizacion(value:Number):void {
		_ultimaCotizacion = value;
	}

	public function get departamentos():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Departamento in _departamentos) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set departamentos(value:ArrayCollection):void {
		_departamentos = value;
	}

	public function get zonas():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Zona in _zonas) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set zonas(value:ArrayCollection):void {
		_zonas = value;
	}

	public function get categoriasClientes():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:CategoriasClientes in _categoriasClientes) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set categoriasClientes(value:ArrayCollection):void {
		_categoriasClientes = value;
	}

	private function timerHandler(e:TimerEvent):void {
		repeat--;
	}

	private function completeHandler(e:TimerEvent):void {
		repeat = 0;
		closeHandler(null);
	}

	public function get planPagos():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:PlanPagos in _planPagos) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set planPagos(value:ArrayCollection):void {
		_planPagos = value;
	}

	public function get entrega():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Entrega in _entrega) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set entrega(value:ArrayCollection):void {
		_entrega = value;
	}

	public function get comprobantes():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Comprobante in _comprobantes) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set comprobantes(value:ArrayCollection):void {
		_comprobantes = value;
	}

	public function get vendedores():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Vendedor in _vendedores) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set vendedores(value:ArrayCollection):void {
		_vendedores = value;
	}

	public function get usuarios():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Usuario in _usuarios) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set usuarios(value:ArrayCollection):void {
		_usuarios = value;
	}

	public function get tareas():ArrayCollection {
		return _tareas;
	}

	public function set tareas(value:ArrayCollection):void {
		_tareas = value;
	}

	public function get contactos():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Contacto in _contactos) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function getContactosActivos(clearing:Boolean = true):ArrayCollection {
		var usuario:Usuario = GeneralOptions.getInstance().loggedUser;
		var aux:ArrayCollection = new ArrayCollection()

		if (usuario.permisoId == Usuario.USUARIO_VENDEDOR_DISTRIBUIDOR) {
			for each (var elem:Cliente in _clientes) {
				if ((clearing || elem.categCliId != 'G') && (elem.vendedor && elem.vendedor.codigo == usuario.venId) && (elem.contacto.ctoActivo != "N")) {
					aux.addItem(elem.contacto);
				}
			}
		} else {
			for each (var cto:Contacto in _contactos) {
				if (cto.ctoActivo != "N") {
					aux.addItem(cto);
				}
			}

		}

		return aux;
	}

	public function set contactos(value:ArrayCollection):void {
		_contactos = value;
	}

	public function get capitulos():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Capitulo in _capitulos) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set capitulos(value:ArrayCollection):void {
		_capitulos = value;
	}

	/**
	 * Disconnect Remote Object.
	 */
	public function resetRemoteObject():void {
		remObjCat.disconnect();
	}

	public function getComprobante(codigo:String):Comprobante {
		for each (var comprobante:Comprobante in comprobantes) {
			if (comprobante.codigo == codigo) {
				return comprobante;
			}
		}
		return null;
	}

	/**
	 * Cargar todos los catalogos.
	 */
	public function loadAllCatalogs(showErrorPanel:Boolean = true):void {
		errorPanel = new ErrorPanel();
		errorPanel.width = 400;
		errorPanel.cornerRadius = 3;
		errorPanel.backgroundAlpha = .75;
		errorPanel.showButtons = false;
		errorPanel.type = 2;
		errorPanel.errorText = "Cargando Catálogos...";

		if (showErrorPanel) {
			var parent:Sprite;

			var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
			// no types so no dependencies
			var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
			if (mp && mp.useSWFBridge()) {
				parent = Sprite(sm.getSandboxRoot());
			} else {
				parent = Sprite(FlexGlobals.topLevelApplication);
			}
			PopUpManager.addPopUp(errorPanel, parent, true);
			PopUpManager.centerPopUp(errorPanel);
		}

		var remObj:RemoteObject = new RemoteObject();
		remObj.destination = "CreatingRpc";
		remObj.channelSet = ServerConfig.getInstance().channelSet;
		remObj.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
				var values:ArrayCollection = evt.result as ArrayCollection;
				if (values && values.length > 0) {
					comprobantesUsuario = sort(values, true);
				} else {
					comprobantesUsuario = new ArrayCollection();
				}
				remObj.disconnect();

				var remObjPV:RemoteObject = new RemoteObject();
				remObjPV.destination = "CreatingRpc";
				remObjPV.channelSet = ServerConfig.getInstance().channelSet;
				remObjPV.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
						var values:ArrayCollection = evt.result as ArrayCollection;
						if (values && values.length > 0) {
							preciosVentaUsuario = sort(values, true);
						} else {
							preciosVentaUsuario = new ArrayCollection();
						}
						catalogo = 0;
						remObjPV.disconnect();

						resetRemoteObject();
						errorPanel.errorText = "Cargando Catálogo de 'Monedas'.";
						remObjCat.getCatalogoByName("Moneda");

					});
				remObjPV.addEventListener(FaultEvent.FAULT, handleFault);
				remObjPV.getPreciosVentaUsuario();

			});
		remObj.addEventListener(FaultEvent.FAULT, handleFault);
		remObj.getComprobantesPermitidosUsuario();


		var remObjFT:RemoteObject = new RemoteObject();
		remObjFT.destination = "CreatingRpc";
		remObjFT.channelSet = ServerConfig.getInstance().channelSet;
		remObjFT.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
				parametrosAdministracion = evt.result as ParametrosAdministracion;

				trace("Fecha de Trabado: ", parametrosAdministracion.parAdmFechaTrabado);
			});
		remObjFT.getParametrosAdministracion();

	}

	/**
	 * Resetear todos los catalogos.
	 */
	public function resetAllCatalogs():void {
		monedas = new ArrayCollection();
		clientes = new ArrayCollection();
		proveedores = new ArrayCollection();
		depositos = new ArrayCollection();
		articulos = new ArrayCollection();
		preciosVenta = new ArrayCollection();
		vendedores = new ArrayCollection();
		comprobantes = new ArrayCollection();
		entrega = new ArrayCollection();
		planPagos = new ArrayCollection();
		departamentos = new ArrayCollection();
		zonas = new ArrayCollection();
		paises = new ArrayCollection();
		giros = new ArrayCollection();
		bancos = new ArrayCollection();


		// Para el tema expediciones
		usuarios = new ArrayCollection();
		tareas = new ArrayCollection();
		contactos = new ArrayCollection();
	}

	/**
	 * Resetear el catalogo de Articulos o clientes.
	 */
	public function resetCatalog(catalog:String):void {
		if (catalog == "Cliente") {
			clientes = new ArrayCollection();
		} else if (catalog == "Proveedor") {
			proveedores = new ArrayCollection();
		} else if (catalog == "Articulo") {
			articulos = new ArrayCollection();
		} else if (catalog == "Vendedor") {
			vendedores = new ArrayCollection();
		} else if (catalog == "Comprobante") {
			comprobantes = new ArrayCollection();
		}
	}

	public function set monedas(value:ArrayCollection):void {
		_monedas = value;
	}

	public function get monedas():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:Moneda in _monedas) {
			aux.addItem(elem);
		}
		return aux;

	}

	public function getMonedas(aster:Boolean = true):ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:Moneda in _monedas) {
			if (elem.aster) {
				if (aster)
					aux.addItem(elem);
			} else {
				aux.addItem(elem);
			}
		}
		return aux;
	}

	public function set clientes(values:ArrayCollection):void {
		if (values) {
			// Cuando es una aliado comercial obtener solamente los clientes que lo tienen como vendedor o encargado de cuentas
			var user:Usuario = GeneralOptions.getInstance().loggedUser;
			if (user.permisoId == Usuario.USUARIO_ALIADOS_COMERCIALES) {
				var clients_aux:ArrayCollection = new ArrayCollection(); 
				for each (var c:Cliente in values) {
					if ((c.vendedor && c.vendedor.codigo == user.venId) || (c.encargadoCuenta == user.venId)) {
						clients_aux.addItem(c);
					}
				}
				_clientes = sort(clients_aux);

			} else {
				_clientes = sort(values);
			}
		} else {
			_clientes = new ArrayCollection();
		}

		dispatchEvent(new Event("changeClients"));
	}

	public function get clientes():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:Cliente in _clientes) {
			aux.addItem(elem);
		}
		return aux;
	}

	[Bindable(event="changeClientes")]
	public function getClientesVendedor(clering:Boolean = false):ArrayCollection {
		var usuario:Usuario = GeneralOptions.getInstance().loggedUser;

		if (usuario.permisoId == Usuario.USUARIO_VENDEDOR_DISTRIBUIDOR) {
			var vendId:String = usuario.venId;
			var aux:ArrayCollection = new ArrayCollection();
			for each (var elem:Cliente in _clientes) {
				if ((clering || elem.categCliId != 'G') && (elem.vendedor && elem.vendedor.codigo == vendId)) {
					aux.addItem(elem);
				}
			}
			return aux;
		} else {
			return getClientesNoClering();
		}
	}

	[Bindable(event="changeClients")]
	public function getClientesNoClering():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:Cliente in _clientes) {
			if (elem.categCliId != 'G') {
				aux.addItem(elem);
			}
		}
		return aux;
	}

	public function set proveedores(value:ArrayCollection):void {
		_proveedores = value;
	}

	public function get proveedores():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:Proveedor in _proveedores) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function getProveedoresExtranjeros():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:Proveedor in _proveedores) {
			if (elem.contacto.paisIdCto && elem.contacto.paisIdCto != "UY")
				aux.addItem(elem);
		}
		return aux;
	}

	public function set articulos(value:ArrayCollection):void {
		_articulos = value;
	}

	public function get articulos():ArrayCollection {
		return _articulos;
	}

	public function getArticulos(cmpId:String = null):ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();

		if (cmpId == "110" || cmpId == "111" || cmpId == "112" || cmpId == "113") {
			return articulosGastos;
		} else if (cmpId == "100" || cmpId == "101" || cmpId == "102" || cmpId == "103" || cmpId == "202" || cmpId == "203" || cmpId == "120" || cmpId == "121" || cmpId == "122" || cmpId == "124") {
			return articulosProveedor;
		} else if (cmpId == "28") {
			return articulosNC_Fin;
		} else if (cmpId == "22" || cmpId == "24" || cmpId == "25" || cmpId == "26" || cmpId == "27") {
			return articulosNC;
		} else if (cmpId == "80" || cmpId == "81" || cmpId == "82" || cmpId == "83" || cmpId == "84" || cmpId == "85" || cmpId == "86") {
			return articulosAfilados;
		} else if (cmpId == "130" || cmpId == "131" || cmpId == "132" || cmpId == "133") {
			return articulosMNeumaticas;
		} else if (cmpId == "70" || cmpId == "71" || cmpId == "72" || cmpId == "73") {
			return articulosTorneria;
		} else {
			return _articulosActivos;
		}
	}


	public function set preciosVenta(value:ArrayCollection):void {
		_preciosVenta = value;
	}

	public function get preciosVenta():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:PreciosVenta in _preciosVenta) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function set depositos(value:ArrayCollection):void {
		_depositos = value;
	}

	public function get depositos():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection()
		for each (var elem:Deposito in _depositos) {
			aux.addItem(elem);
		}
		return aux;
	}

	public function loadCatalogo(catalogo:String):void {
		var remObj:RemoteObject = new RemoteObject();
		remObj.destination = "CreatingRpc";
		remObj.channelSet = ServerConfig.getInstance().channelSet;
		remObj.addEventListener(ResultEvent.RESULT, resultCatalogo);
		remObj.addEventListener(FaultEvent.FAULT, handleFault);

		remObj.getCatalogoByName(catalogo);
	}

	private function resultCatalogo(event:ResultEvent):void {
		var values:ArrayCollection = event.result as ArrayCollection;

		if (values.length > 0) {
			var value:Object = values.getItemAt(0);
			if (value is Entrega) {
				entrega = sort(values);
				dispatchEvent(new Event("changeEntregas", false, false));
			} else if (value is Cliente) {
				clientes = values;
				dispatchEvent(new Event("changeClientes", false, false));
			} else if (value is Proveedor) {
				proveedores = sort(values);
				dispatchEvent(new Event("changeProveedores", false, false));
			} else if (value is Contacto) {
				contactos = sort(values);
				dispatchEvent(new Event("changeContactos", false, false));
			} else if (value is Fanfold) {
				fanfold = sort(values);
				dispatchEvent(new Event("changeFanfold", false, false));
			}

		}

	}


	private function result(event:ResultEvent):void {
		var values:ArrayCollection = event.result as ArrayCollection;

		catalogo++;
		{
			switch (catalogo) {
				case 1:
					{
						if (values) {
							monedas = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Depósitos'.";
						remObjCat.getCatalogoByName("Deposito");
						break;
					}
				case 2:
					{
						if (values) {
							depositos = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Precios Venta'.";
						remObjCat.getCatalogoByName("PreciosVenta");
						break;
					}
				case 3:
					{
						if (values) {
							preciosVenta = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Clientes'.";
						remObjCat.getCatalogoByName("Cliente");
						break;
					}
				case 4:
					{
						clientes = values;
						
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Artículos'.";
						remObjCat.getCatalogoByName("Articulo");
						break;
					}
				case 5:
					{
						if (values) {
							articulos = sort(values);
							articulosGastos = new ArrayCollection();
							articulosNC = new ArrayCollection();
							articulosNC_Fin = new ArrayCollection();
							articulosAfilados = new ArrayCollection();
							articulosMNeumaticas = new ArrayCollection();
							articulosTorneria = new ArrayCollection();

							_articulosActivos = new ArrayCollection();
							for each (var elem:Articulo in articulos) {
								if (elem.activo) {
									_articulosActivos.addItem(elem);
									if (elem.codigo == "GASTOS VARIOS" || elem.codigo == "GASTOS VARIOS2") {
										articulosGastos.addItem(elem);
									}
									if (elem.codigo == "ARTICULOS VARIOS" || elem.codigo == "ARTICULOS VARIOS EX") {
										articulosMNeumaticas.addItem(elem);
										articulosTorneria.addItem(elem);
									}
									if (elem.codigo == "DESCUENTO") {
										articulosNC_Fin.addItem(elem);
									} else {
										articulosNC.addItem(elem);
									}
									if (elem.familiaId.toString().match(new RegExp("^980", 'i'))) {
										articulosAfilados.addItem(elem);
									} else if (elem.familiaId.toString().match(new RegExp("^902", 'i')) || elem.familiaId.toString().match(new RegExp("^903", 'i'))) {
										articulosMNeumaticas.addItem(elem);
									} else if (elem.familiaId.toString().match(new RegExp("^970", 'i'))) {
										articulosTorneria.addItem(elem);
									}
								}
							}
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Vendedores'.";
						remObjCat.getCatalogoByName("Vendedor");
						break;
					}
				case 6:
					{
						if (values) {
							vendedores = sort(values);
						}

						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Comprobantes'.";
						remObjCat.getCatalogoByName("Comprobante");
						break;
					}
				case 7:
					{
						if (values) {
							comprobantes = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Entregas'.";
						remObjCat.getCatalogoByName("Entrega");
						break;
					}
				case 8:
					{
						if (values) {
							entrega = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Planes de Pago'.";
						remObjCat.getCatalogoByName("PlanPagos");
						break;
					}
				case 9:
					{
						if (values) {
							planPagos = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Usuarios'.";
						remObjCat.getCatalogoByName("Usuario");
						break;
					}
				case 10:
					{
						if (values) {
							usuarios = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Tareas'.";
						remObjCat.getCatalogoByName("Tarea");
						break;
					}
				case 11:
					{
						if (values) {
							tareas = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Contactos'.";
						remObjCat.getCatalogoByName("Contacto");
						break;
					}
				case 12:
					{
						if (values) {
							contactos = sort(values);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Zonas'.";
						remObjCat.getCatalogoByName("Zona");
						break;
					}
				case 13:
					{
						if (values) {
							zonas = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Departamentos'.";
						remObjCat.getCatalogoByName("Departamento");
						break;
					}
				case 14:
					{
						if (values) {
							departamentos = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Capitulos'.";
						remObjCat.getCatalogoByName("Capitulo");
						break;
					}
				case 15:
					{
						if (values) {
							capitulos = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Categorias Clientes'.";
						remObjCat.getCatalogoByName("CategoriasClientes");
						break;
					}
				case 16:
					{
						if (values) {
							categoriasClientes = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Giros'.";
						remObjCat.getCatalogoByName("Giro");
						break;
					}
				case 17:
					{
						if (values) {
							giros = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'FamiliaArticulos'.";
						remObjCat.getCatalogoByName("FamiliaArticulos");
						break;
					}
				case 18:
					{
						if (values) {
							familias = sort(values, true);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Proveedores'.";
						remObjCat.getCatalogoByName("Proveedor");
						break;
					}
				case 19:
					{
						if (values) {
							proveedores = sort(values, true);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Países'.";
						remObjCat.getCatalogoByName("Pais");
						break;
					}
				case 20:
					{
						if (values) {
							paises = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Fanfold'.";
						remObjCat.getCatalogoByName("Fanfold");
						break;
					}
				case 21:
					{
						if (values) {
							fanfold = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Rubros'.";
						remObjCat.getCatalogoByName("Rubro");
						break;
					}
				case 22:
					{
						if (values) {
							rubros = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Formas de pago'.";
						remObjCat.getCatalogoByName("FormaPago");
						break;
					}
				case 23:
					{
						if (values) {
							formasPago = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Cento de costos'.";
						remObjCat.getCatalogoByName("CentrosCosto");
						break;
					}
				case 24:
					{
						if (values) {
							centrosCosto = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Tasas de IVA'.";
						remObjCat.getCatalogoByName("Iva");
						break;
					}
				case 25:
					{
						if (values) {
							ivas = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Cargando catálogo de 'Bancos'.";
						remObjCat.getCatalogoByName("Banco");
						break;
					}
				case 26:
					{
						if (values) {
							bancos = sort(values, false);
						}
						resetRemoteObject();
						errorPanel.errorText = "Catálogos cargados.";
						myTimer.start();
						break;
					}

			}
		}
	}

	private function sort(arrColl:ArrayCollection, isNumeric:Boolean = true):ArrayCollection {
		/* Create the SortField object for the "data" field in the ArrayCollection object, and make sure we do a numeric sort. */
		var dataSortField:SortField = new SortField();
		dataSortField.name = "codigo";
		dataSortField.numeric = isNumeric;

		/* Create the Sort object and add the SortField object created earlier to the array of fields to sort on. */
		var numericDataSort:Sort = new Sort();
		numericDataSort.fields = [dataSortField];

		/* Set the ArrayCollection object's sort property to our custom sort, and refresh the ArrayCollection. */
		arrColl.sort = numericDataSort;
		arrColl.refresh();

		return arrColl;
	}

	public function handleFault(event:FaultEvent):void {
		myTimer.start();

		trace_text += "----------------------------------------------\n";
		trace_text += "ERROR\n";
		trace_text += "----------------------------------------------\n";

		trace_text += event.message.toString();

		helpWindow = new TitleWindow();
		helpWindow.title = "Catálogos";
		helpWindow.width = 380;

		var error:ErrorPanel = new ErrorPanel();
		error.type = 0;
		error.errorText = "Error Cargando Catálogos...";
		error.detailsText = trace_text;

		var parent:Sprite;

		var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		// no types so no dependencies
		var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		if (mp && mp.useSWFBridge()) {
			parent = Sprite(sm.getSandboxRoot());
		} else {
			parent = Sprite(FlexGlobals.topLevelApplication);
		}

		PopUpManager.addPopUp(helpWindow, parent, true);
		PopUpManager.centerPopUp(helpWindow);

		helpWindow.y = 60;

		helpWindow.addEventListener(CloseEvent.CLOSE, closeHandler);
		error.addEventListener(CloseEvent.CLOSE, closeHandler);

		helpWindow.addElement(error);

	}

	private function closeHandler(event:Event):void {
		if (helpWindow) {
			helpWindow.removeEventListener(CloseEvent.CLOSE, closeHandler);

			PopUpManager.removePopUp(helpWindow as IFlexDisplayObject);
			helpWindow = null;
		}
		trace_text = "";

		PopUpManager.removePopUp(errorPanel);
	}

	public static function getInstance():CatalogoFactory {
		if (_instance == null) {
			_instance = new CatalogoFactory(arguments.callee);
		}
		return _instance;
	}

	public function get parametrosAdministracion():ParametrosAdministracion {
		return _parametrosAdministracion;
	}

	public function set parametrosAdministracion(value:ParametrosAdministracion):void {
		_parametrosAdministracion = value;
	}

	public function get familias():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var elem:FamiliaArticulos in _familias) {
			aux.addItem(elem);
		}
		return aux;

	}

	public function set familias(value:ArrayCollection):void {
		_familias = value;
	}

	public function get usuariosClaveSupervisora():ArrayCollection {
		var aux:ArrayCollection = new ArrayCollection();
		for each (var user:Usuario in _usuarios) {
			if (user.claveSup && user.claveSup.length > 0 && user.permisoId == Usuario.USUARIO_SUPERVISOR) {
				aux.addItem(user);
			}
		}
		return aux;

	}

	public function get fanfold():ArrayCollection {
		return _fanfold;
	}

	public function set fanfold(value:ArrayCollection):void {
		_fanfold = value;
	}

	public function get formasPago():ArrayCollection {
		return _formasPago;
	}

	public function set formasPago(value:ArrayCollection):void {
		_formasPago = value;
	}

	public function get ivas():ArrayCollection {
		return _ivas;
	}

	public function set ivas(value:ArrayCollection):void {
		_ivas = value;
	}


}
}
