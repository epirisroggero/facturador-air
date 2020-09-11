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
import biz.fulltime.event.MonedaEvent;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.controls.Alert;
import mx.events.PropertyChangeEvent;
import mx.formatters.DateFormatter;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;
import mx.utils.StringUtil;

import util.CatalogoFactory;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.DocumentoBase")]
public class DocumentoBase extends EventDispatcher {

	public var docId:String;

	public var serie:String = "";

	public var numero:String;

	public var docTCF:String;

	public var docTCC:String;

	public var docVinculado:String = "N";

	public var conciliado:String = "";

	public var coeficienteImp:String;

	private var _moneda:Moneda;

	public var razonSocial:String;

	public var direccion:String;

	public var dirEntrega:String;

	public var tipoDoc:String = "R";

	public var rut:String;

	public var telefono:String;

	private var _comprobante:Comprobante;

	public var notas:String;

	public var total:String;

	public var registroFecha:Date;

	public var registroHora:Date;
	
	public var estadoFecha:Date;

	

	private var _cliente:Cliente;

	private var _proveedor:Proveedor;
	
	private var _fechaDoc:Date = new Date();

	private var _fechaStr:String;

	private var _fechaEmision:Date = new Date();

	private var _fechaEmisionStr:String;
	
	public var estado:String;

	private var clienteRemObj:RemoteObject;
	
	private var remObjCuponera:RemoteObject;
	
	public var artCuponera:ArrayCollection = new ArrayCollection();
	
	public var cuponerasList:ArrayCollection = new ArrayCollection();

	
	public function DocumentoBase() {
		// Remote object
		clienteRemObj = new RemoteObject();
		clienteRemObj.destination = "CreatingRpc";
		clienteRemObj.channelSet = ServerConfig.getInstance().channelSet;
		clienteRemObj.addEventListener(ResultEvent.RESULT, resultCliente);
		clienteRemObj.addEventListener(FaultEvent.FAULT, handleFault);
		clienteRemObj.showBusyCursor = true;

		remObjCuponera = new RemoteObject();
		remObjCuponera.destination = "CreatingRpc";
		remObjCuponera.channelSet = ServerConfig.getInstance().channelSet;
		remObjCuponera.addEventListener(ResultEvent.RESULT, resultCuponeras);
		remObjCuponera.addEventListener(FaultEvent.FAULT, handleFault);
		remObjCuponera.showBusyCursor = true;

	}

	public function get fechaStr():String {
		return _fechaStr;
	}

	public function set fechaStr(value:String):void {
		_fechaStr = value;

		var formatter:DateFormatter = new DateFormatter();
		_fechaDoc = DateFormatter.parseDateString(_fechaStr);
		_fechaDoc.hours = 12;
		_fechaDoc.minutes = 00;
	}
	
	public function get fechaEmisionStr():String {
		return _fechaEmisionStr;
	}
	
	public function set fechaEmisionStr(value:String):void {
		_fechaEmisionStr = value;
		
		var formatter:DateFormatter = new DateFormatter();
		_fechaEmision= DateFormatter.parseDateString(_fechaEmisionStr);
		_fechaEmision.hours = 12;
		_fechaEmision.minutes = 00;
	}


	public function get fechaDoc():Date {
		return _fechaDoc;
	}

	public function set fechaDoc(value:Date):void {
		if (value == null) {
			value = new Date();
		}

		this._fechaDoc = value;

		var formatter:DateFormatter = new DateFormatter();
		formatter.formatString = "YYYY-MM-DD";
		_fechaStr = formatter.format(value);
	}
	
	public function get fechaEmision():Date {
		return _fechaEmision;
	}
	
	public function set fechaEmision(value:Date):void {
		if (value == null) {
			value = new Date();
		}
		_fechaEmision = value;
				
		var formatter:DateFormatter = new DateFormatter();
		formatter.formatString = "YYYY-MM-DD";
		_fechaEmisionStr = formatter.format(value);
	}
	


	public function get moneda():Moneda {
		return _moneda;
	}

	public function set moneda(value:Moneda):void {
		var oldValue:Moneda;
		if (_moneda) {
			oldValue = new Moneda();
			oldValue.codigo = _moneda.codigo;
			oldValue.nombre = _moneda.nombre;
		}

		var newValue:Moneda = value;

		_moneda = value;
		
		// TODO: Revisar. Se configura el comprobante en base a la moneda...
		if (_moneda && _moneda.nombre) {
			if (_moneda.nombre.indexOf("*") > 0) {
				comprobante.aster = true;
			} else {
				comprobante.aster = false;
			}
		}

		dispatchEvent(new MonedaEvent(MonedaEvent.MONEDA_CHANGED, oldValue, newValue));
	}

	public function get cliente():Cliente {
		return _cliente;
	}

	public function set cliente(value:Cliente):void {
		_cliente = value;

		if (this.comprobante != null && (this.comprobante.codigo == "80" || this.comprobante.codigo == "90")) {
			cargarCuponeras();
		}

		dispatchEvent(new Event("_changeCliente", true, true));
	}

	public function get proveedor():Proveedor {
		return _proveedor;
	}

	public function set proveedor(value:Proveedor):void {
		_proveedor = value;
	}

	public function get comprobante():Comprobante {
		return _comprobante;
	}

	public function set comprobante(value:Comprobante):void {
		_comprobante = value;

		if (this.cliente != null && (this.comprobante.codigo == "80" || this.comprobante.codigo == "81" || this.comprobante.codigo == "82" || 
			this.comprobante.codigo == "84" || this.comprobante.codigo == "90")) {
			cargarCuponeras();
		}
	}
	
	public function cargarCuponeras():void {
		artCuponera.removeAll();			
		cuponerasList.removeAll();
		
		artCuponera = getArticulosCuponera();
		
		if (artCuponera.length > 0) {
			remObjCuponera.getCuponeras(artCuponera);
		} else {
			dispatchEvent(new Event("_changeCuponeras", true, true));
		}
	}
	
	public function getArticulosCuponera():ArrayCollection {
		var result:ArrayCollection = new ArrayCollection(); 
		
		if (cliente && cliente.codigo && cliente.codigo != "99") {
			for each (var articulo:Articulo in CatalogoFactory.getInstance().articulos) {
				if (articulo.activo && articulo.codigo.toLowerCase().indexOf(cliente.codigo.toLowerCase() + ".") == 0) {
					var codigo:String = articulo.codigo;
					var familiaId:String = articulo.familiaId ? articulo.familiaId : "";
					for each (var art:String in GeneralOptions.getInstance().articulosServicio) {
						if (familiaId.toLowerCase().match(new RegExp("^" + art, 'i'))) {
							if (!result.contains(articulo)) {
								result.addItem(articulo);
							}								
						}
					}
				}
			}			
		} 
		
		return result;
	
	}
	
	public var tieneCuponeraConSaldo:Boolean = false;	
	
	private function resultCuponeras(event:ResultEvent):void {
		cuponerasList = event.result as ArrayCollection;
		
		tieneCuponeraConSaldo = false;
		for each (var cuponera:Cuponera in cuponerasList) {
			if (cuponera.fecha != null && cuponera.getStockValue().compareTo(BigDecimal.ZERO) > 0) {
				tieneCuponeraConSaldo = true;
				break;
			}			
		}
		
		dispatchEvent(new Event("_changeCuponeras", true, true));
	}


	private function filtrarArticulos(item:Object):Boolean {
		var articulo:Articulo = item as Articulo;
		var codigo:String = articulo.codigo;
		var familiaId:String = articulo.familiaId ? articulo.familiaId : "";
		
		var filtrar:Boolean = false;
		if (codigo) {
			// Tengo que reemplazar el . por la Z por el tema de que el punto es un pattern en Flex 
			filtrar = codigo.replace(".", "Z").toLowerCase().match(new RegExp("^" + cliente.codigo.toLowerCase() + "Z", 'i')) != null;
			if (filtrar) {
				for each (var art:String in GeneralOptions.getInstance().articulosServicio) {
					if (familiaId.toLowerCase().match(new RegExp("^" + art, 'i'))) {
						return true;
					}
				}
				return false

			}
		}
		
		return filtrar;
	}


	/**
	 * Inicializa campos del documento a partir del cliente establecido. No tiene efecto si el valor es null.
	 */
	public function tomarCamposDelCliente(codigoCliente:String):void {
		if (codigoCliente == null) {
			return;
		}

		// Obtener todos los dataos del cliente ...
		clienteRemObj.findCatalogEntity("Cliente", codigoCliente);
	}

	private function handleFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, "Error");
	}

	private function resultCliente(event:ResultEvent):void {
		var result:* = event.result;
		if (result == null) {
			trace("Advertencia: ", " El resultado de la consulta fue vacio.");
		}
		if (result is Cliente) {
			cliente = result as Cliente;

			cliente.obtenerDocumentosPendientes();

			clienteLoaded();
		}
	}

	public function clienteLoaded():void {
	}





}

}
