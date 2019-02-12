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

	public var cuponeras:ArrayCollection = new ArrayCollection();

	private var _cliente:Cliente;

	private var _proveedor:Proveedor;
	
	private var _fechaDoc:Date = new Date();

	private var _fechaStr:String;

	private var _fechaEmision:Date = new Date();

	private var _fechaEmisionStr:String;
	
	public var estado:String;

	private var clienteRemObj:RemoteObject;

	
	public function DocumentoBase() {
		// Remote object
		clienteRemObj = new RemoteObject();
		clienteRemObj.destination = "CreatingRpc";
		clienteRemObj.channelSet = ServerConfig.getInstance().channelSet;
		clienteRemObj.addEventListener(ResultEvent.RESULT, resultCliente);
		clienteRemObj.addEventListener(FaultEvent.FAULT, handleFault);
		clienteRemObj.showBusyCursor = true;

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

		if (this.cliente != null && (this.comprobante.codigo == "80" || this.comprobante.codigo == "90")) {
			cargarCuponeras();
		}

	}

	private function cargarCuponeras():void {
		cuponeras.removeAll();

		for each (var elem:Articulo in CatalogoFactory.getInstance().articulos) {
			cuponeras.addItem(elem);
		}
		cuponeras.filterFunction = filtrarArticulos;
		cuponeras.refresh();

	}

	private function filtrarArticulos(item:Object):Boolean {
		var articulo:Articulo = item as Articulo;
		var codigo:String = articulo.codigo;
		var familiaId:String = articulo.familiaId ? articulo.familiaId : "";
		
		var filtrar:Boolean = false;
		if (codigo) {
			// Tengo que reemplazar el . por la Z por el tema de que el punto es un pattern en Flex 
			filtrar = codigo.replace(".", "Z").toLowerCase().match(new RegExp("^" + cliente.codigo.toLowerCase() + "Z", 'i'));
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

			clienteLoaded();
		}
	}

	public function clienteLoaded():void {
	}





}

}
