//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.conf {

import biz.fulltime.model.Caja;
import biz.fulltime.model.Localescomerciale;
import biz.fulltime.model.Usuario;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import spark.collections.Sort;
import spark.collections.SortField;

public class GeneralOptions extends EventDispatcher {

	private static var _instance:GeneralOptions;

	private var _emailStock:String;

	private var _emailRentaBaja:String;

	private var _emailFactPendientes:String;

	private var _impresoraFactura:String;

	private var _impresoraOtros:String;

	private var _articulosServicio:ArrayCollection;

	private var _usuarios:ArrayCollection = new ArrayCollection();

	private var _cajas:ArrayCollection = new ArrayCollection();

	private var _locales:ArrayCollection = new ArrayCollection();

	private var _loggedUser:Usuario;

	private var _cajaSeleccionada:Caja;

	private var _localSeleccionada:Localescomerciale;

	private var _opciones:XML =
		<opciones>
			<modoMostrador>false</modoMostrador>
			<usarCajaPrincipal>false</usarCajaPrincipal>
			<envioAutomaticoMail>false</envioAutomaticoMail>
			<email>
				<stock>fernando@fulltime.com</stock>
				<factPendientes>luigi@fulltime.com</factPendientes>
				<topeCredito>ernesto@fulltime.com</topeCredito>
			</email>
			<impresoras>
				<facturacion>doPDF v7</facturacion>
				<remitos>doPDF v7</remitos>
				<otros>Universal Document Converter</otros>
			</impresoras>
			<fanfold>
				<facturas>F</facturas>
				<remitos>R</remitos>
			</fanfold>
			<eFactura>
				<abrirPDF>true</abrirPDF>
			</eFactura>
		</opciones>
		;

	private var remObjLogin:RemoteObject;

	private var _mostrarPrecioInd:Boolean = false; // F11

	private var _mostrarPrecioIndRev:Boolean = false; // F9

	private var _mostrarPrecioIndRevDist:Boolean = false; // F8


	public function GeneralOptions(caller:Function = null) {
		if (caller != GeneralOptions.getInstance) {
			throw new Error("GeneralOptions is a singleton class, use getInstance() instead");
		}
	}

	[Bindable]
	public function get mostrarPrecioIndRevDist():Boolean {
		return _mostrarPrecioIndRevDist;
	}

	public function set mostrarPrecioIndRevDist(value:Boolean):void {
		_mostrarPrecioIndRevDist = value;
	}

	[Bindable]
	public function get mostrarPrecioIndRev():Boolean {
		return _mostrarPrecioIndRev;
	}

	public function set mostrarPrecioIndRev(value:Boolean):void {
		_mostrarPrecioIndRev = value;
	}

	[Bindable]
	public function get mostrarPrecioInd():Boolean {
		return _mostrarPrecioInd;
	}

	public function set mostrarPrecioInd(value:Boolean):void {
		_mostrarPrecioInd = value;
	}

	[Bindable]
	public function get locales():ArrayCollection {
		return _locales;
	}

	public function set locales(value:ArrayCollection):void {
		_locales = value;
	}

	public function get localSeleccionada():Localescomerciale {
		return _localSeleccionada;
	}

	public function set localSeleccionada(value:Localescomerciale):void {
		_localSeleccionada = value;
	}

	[Bindable]
	public function get cajaSeleccionada():Caja {
		return _cajaSeleccionada;
	}

	public function set cajaSeleccionada(value:Caja):void {
		_cajaSeleccionada = value;
	}

	[Bindable]
	public function get loggedUser():Usuario {
		return _loggedUser;
	}

	public function set loggedUser(value:Usuario):void {
		_loggedUser = value;
	}

	[Bindable]
	public function get usuarios():ArrayCollection {
		return _usuarios;
	}

	public function set usuarios(value:ArrayCollection):void {
		_usuarios = value;
	}

	[Bindable]
	public function get cajas():ArrayCollection {
		return _cajas;
	}

	public function set cajas(value:ArrayCollection):void {
		_cajas = value;
	}

	public function get articulosServicio():ArrayCollection {
		return _articulosServicio;
	}

	public function set articulosServicio(value:ArrayCollection):void {
		_articulosServicio = value;
	}
	

	/**
	 * Cargar articulos de servicio.
	 */
	public function cargarArticulosServicio():void {
		var remObj:RemoteObject = new RemoteObject();
		remObj.destination = "CreatingRpc";
		remObj.channelSet = ServerConfig.getInstance().channelSet;
		remObj.addEventListener(ResultEvent.RESULT, result);
		remObj.addEventListener(FaultEvent.FAULT, handleFault);

		remObj.showBusyCursor = true;

		remObj.getCodigosArticulosServicio();
	}

	/**
	 * Cargar articulos de servicio.
	 */
	public function cargarUsuarios():void {
		var remObjCat:RemoteObject = new RemoteObject();
		remObjCat.destination = "UsuariosRpc";
		remObjCat.channelSet = ServerConfig.getInstance().channelSet;
		remObjCat.addEventListener(ResultEvent.RESULT, resultUsuarios);
		remObjCat.addEventListener(FaultEvent.FAULT, handleFault);

		remObjCat.showBusyCursor = true;
		remObjCat.getCatalogoUsuarios();
	}

	/**
	 * Cargar cajas de servicio.
	 */
	public function cargarCajas():void {
		var remObjCat:RemoteObject = new RemoteObject();
		remObjCat.destination = "UsuariosRpc";
		remObjCat.channelSet = ServerConfig.getInstance().channelSet;
		remObjCat.addEventListener(ResultEvent.RESULT, resultCajas);
		remObjCat.addEventListener(FaultEvent.FAULT, handleFault);

		remObjCat.showBusyCursor = true;
		remObjCat.getCatalogoCajas();
	}

	/**
	 * Cargar locales de servicio.
	 */
	public function cargarLocalesComerciales():void {
		var remObjCat:RemoteObject = new RemoteObject();
		remObjCat.destination = "UsuariosRpc";
		remObjCat.channelSet = ServerConfig.getInstance().channelSet;
		remObjCat.addEventListener(ResultEvent.RESULT, resultLocalesComerciales);
		remObjCat.addEventListener(FaultEvent.FAULT, handleFault);

		remObjCat.showBusyCursor = true;
		remObjCat.getCatalogoLocalesComerciales();
	}

	private function resultUsuarios(event:ResultEvent):void {
		var values:ArrayCollection = event.result as ArrayCollection;
		usuarios = sort(values, true);

		dispatchEvent(new Event("_changeUsuarios", true, true));
	}

	private function resultCajas(event:ResultEvent):void {
		var values:ArrayCollection = event.result as ArrayCollection;
		cajas = sort(values, true);

		dispatchEvent(new Event("_changeCajas", true, true));
	}

	private function resultLocalesComerciales(event:ResultEvent):void {
		var values:ArrayCollection = event.result as ArrayCollection;
		locales = sort(values, true);

		dispatchEvent(new Event("_changeLocalesComerciales", true, true));
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



	private function result(event:ResultEvent):void {
		var values:ArrayCollection = event.result as ArrayCollection;
		_articulosServicio = values;
	}

	public function esArticuloDeServicio(familia:String):Boolean {
		for each (var cod:String in articulosServicio) {
			if (familia.match(new RegExp("^" + cod, 'i'))) {
				return true;
			}
		}
		return false;
	}

	public function handleFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, "Error: " + event.fault.faultCode);
	}

	[Bindable]
	public function get opciones():XML {
		return _opciones;
	}

	public function set opciones(value:XML):void {
		_opciones = value;
	}

	public static function getInstance():GeneralOptions {
		if (_instance == null) {
			_instance = new GeneralOptions(arguments.callee);
		}
		return _instance;
	}

	[Bindable(event="_changeModoMostrador")]
	public function get modoMostrador():Boolean {
		if (loggedUser.usuarioModoMostrador) {
			return true;
		}
		return opciones.modoMostrador == "true";
	}

	public function get usarCajaPrincipal():Boolean {
		return opciones.usarCajaPrincipal == "true";
		
	}
}
}
