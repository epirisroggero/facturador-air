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
import biz.fulltime.dto.CodigoNombre;
import biz.fulltime.event.ClienteEvent;
import biz.fulltime.event.FacturasGrabadasEvent;
import biz.fulltime.event.FacturasPendientesEvent;
import biz.fulltime.model.deudores.DocPendientesCliente;
import biz.fulltime.model.deudores.DocumentoDeudor;

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import spark.components.TitleWindow;

import util.CatalogoFactory;
import util.ErrorPanel;
import util.WarningPnl;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Cliente")]
public class Cliente extends CodigoNombreEntity {
	
	public var contacto:Contacto;
		
	public var categCliId:String;
	
	public var encargadoPagos:String;
	
	public var encargadoCuenta:String;
	
	public var energiaElectrica:String;
	
	public var direccionCobranza:String;
	
	public var diaHoraPagos:String;

	public var lugarEntrega:String;
	
	public var cliTopeCredito:Number;
	
	public var cliDto1:Number = 0;
	
	public var grupo:CodigoNombre;
			
	public var agencia:String;
	
	public var locIdCli:Number = 1;
	
	private var _moneda:Moneda;
	
	public var planPagos:PlanPagos;
	
	public var preciosVenta:PreciosVenta;
	
	public var vendedor:Vendedor;
	
	private var remFactPendientes:RemoteObject;
	
	private var docPendientes:DocPendientesCliente;
	
	private var remFactGrabadas:RemoteObject;
	
	private var remSave:RemoteObject;
	
	private var remVerify:RemoteObject;
	
	private var remMerge:RemoteObject;

	public var foto:ByteArray;

	public var especialista1:String;
	
	public var especialista2:String;

	public var precioVentaIdCli:Number;
	
	public var pPidCli:String;
	
	public var esNuevo:Boolean;
	
	public var cliIdNom:String;
	
	public var cliRanking:Number;
	
	public var permisoStock:String;

	public var permisoPrecios:String;
	
	public var googleMaps:String;
	
	private var _documentsPendientes:DocPendientesCliente;

	
	public function Cliente() {		
		moneda = CatalogoFactory.getInstance().monedas[1];
		
		var precioVentaId:String = String(CatalogoFactory.getInstance().parametrosAdministracion.precioVentaIdParAdm);
		for each(var pv:PreciosVenta in CatalogoFactory.getInstance().preciosVenta) { 
			if (pv.codigo == precioVentaId) {
				preciosVenta = pv;
				break;
			}
		}
	}	
	
	public function get moneda():Moneda {
		return _moneda;
	}

	public function set moneda(value:Moneda):void {
		_moneda = value;
	}

	public function obtenerDocumentosPendientes():void {
		if (!remFactPendientes) { 
			remFactPendientes = new RemoteObject();
			remFactPendientes.destination = "CreatingRpc";
			remFactPendientes.channelSet = ServerConfig.getInstance().channelSet;
			remFactPendientes.addEventListener(ResultEvent.RESULT, resultDocumentsPendientes);
			remFactPendientes.addEventListener(FaultEvent.FAULT, handleFault);
		}

		remFactPendientes.getDocumentosDeudores();
	}
	
	
	public function obtenerDocumentosGrabados():void {
		if (remFactGrabadas == null) {
			remFactGrabadas = new RemoteObject();
			remFactGrabadas.destination = "CreatingRpc";
			remFactGrabadas.channelSet = ServerConfig.getInstance().channelSet;
			remFactGrabadas.addEventListener(ResultEvent.RESULT, resultdocumentsGrabadas);
			remFactGrabadas.addEventListener(FaultEvent.FAULT, handleFault);
		}

		remFactGrabadas.getDocumentosPendientes(codigo);
	}

	
	private function resultDocumentsPendientes(event:ResultEvent):void {
		var data:ArrayCollection = event.result as ArrayCollection;
		
		var resultPendientes:ArrayCollection = new ArrayCollection();
		
		for each (var doc:DocumentoDeudor in data) {
			if (doc.deudor.codigo == codigo) {
				if (resultPendientes.length > 0) {
					var pendiente:DocPendientesCliente = resultPendientes.getItemAt(0) as DocPendientesCliente;
					pendiente.documentos.addItem(doc);
				} else {
					var docsDeudores:DocPendientesCliente = new DocPendientesCliente();
					docsDeudores.codCliente = doc.deudor.codigo;
					docsDeudores.cliente = doc.deudor;
					docsDeudores.documentos.addItem(doc);
					
					resultPendientes.addItem(docsDeudores);
				}
			}
		}
		if (resultPendientes.length > 0) {
			docPendientes = resultPendientes.getItemAt(0) as DocPendientesCliente;
			documentsPendientes = docPendientes;
			dispatchEvent(new FacturasPendientesEvent(FacturasPendientesEvent.FACTURAS_PENDIENTES_CHANGED, docPendientes));
		} else {
			documentsPendientes = null;
			dispatchEvent(new FacturasPendientesEvent(FacturasPendientesEvent.FACTURAS_PENDIENTES_CHANGED, null));
		}
	}
	
	private function resultdocumentsGrabadas(event:ResultEvent):void {
		var resultG:* = event.result;
		
		if (resultG is ArrayCollection) {
			var res:ArrayCollection = resultG as ArrayCollection;
			if (res.length > 0) {
				// trace("### El cliente: " + codigo + " tiene " + res.length + " documents Grabadas.");
				dispatchEvent(new FacturasGrabadasEvent(FacturasGrabadasEvent.FACTURAS_GRABADAS_CHANGED, res));
			}
		}
	}
	
	public function mergeCliente():void {
		if (!remMerge) { 
			remMerge = new RemoteObject();
			remMerge.destination = "CreatingRpc";
			remMerge.channelSet = ServerConfig.getInstance().channelSet;
			remMerge.addEventListener(ResultEvent.RESULT, resultMergeCliente);
			remMerge.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remMerge.modificarCliente(this);
	}

	private function resultMergeCliente(event:ResultEvent):void {
		var resultM:* = event.result;
		dispatchEvent(new Event("_savedClientOk"));
	}
	
	public function verificarDatosCliente():void {
		this.contacto.nombre = nombre;
		
		if (!remVerify) { 
			remVerify = new RemoteObject();
			remVerify.destination = "CreatingRpc";
			remVerify.channelSet = ServerConfig.getInstance().channelSet;
			remVerify.addEventListener(ResultEvent.RESULT, resultVerifyCliente);
			remVerify.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remVerify.verifyAltaCliente(this);
	}
	
	private function resultVerifyCliente(event:ResultEvent):void {
		var resultS:String = event.result as String;
		
		var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		// no types so no dependencies
		var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		var parent:Sprite;
		if (mp && mp.useSWFBridge()) {
			parent = Sprite(sm.getSandboxRoot());
		} else {
			parent = Sprite(FlexGlobals.topLevelApplication);
		}

		var resultXML:XML = new XML(resultS);
		if (resultXML.errors.error[0] != null) {
			var errores:String = "";
			for each (var item1:XML in resultXML.errors.error) {
				errores += item1.text() + "\n";
			}
			var errorPnl:ErrorPanel = new ErrorPanel();
			errorPnl.errorText = "Ya existe contacto con el mismo nombre y/o código.";
			errorPnl.detailsText = errores;
			errorPnl.showButtons = true;
			
			var helpWindow:TitleWindow = new TitleWindow();
			helpWindow.title = "Error";
			helpWindow.width = 480;
			helpWindow.visible = true;

			helpWindow.addElement(errorPnl);
			errorPnl.addEventListener(CloseEvent.CLOSE, function (event:Event):void {
				PopUpManager.removePopUp(helpWindow);
			});
			helpWindow.addEventListener(CloseEvent.CLOSE, function (event:Event):void {
				PopUpManager.removePopUp(helpWindow);
			});
			
			PopUpManager.addPopUp(helpWindow, parent, true);
			PopUpManager.centerPopUp(helpWindow);			
			
			
			
		} else if (resultXML.warnings.warning[0] != null) {
			var warnings:String = "";
			for each (var item2:XML in resultXML.warnings.warning) {
				warnings += item2.text() + "\n";
			}
			var warningPnl:WarningPnl = new WarningPnl();
			warningPnl.warningText = "Ya existen contactos con alguno de estos datos. \n\n¿Desea Continuar?";
			warningPnl.dataProvider = new XMLListCollection(resultXML.warnings.warning);
			warningPnl.showButtons = true;
			
			var helpWindow2:TitleWindow = new TitleWindow();
			helpWindow2.title = "Advertencias";
			helpWindow2.width = 480;
			helpWindow2.visible = true;
			
			helpWindow2.addElement(warningPnl);
			warningPnl.addEventListener(CloseEvent.CLOSE, function (event:Event):void {
				PopUpManager.removePopUp(helpWindow2);
			});
			warningPnl.addEventListener("_continuarEvent", function (event:Event):void {
				saveCliente();
				PopUpManager.removePopUp(helpWindow2);
			});

			helpWindow2.addEventListener(CloseEvent.CLOSE, function (event:Event):void {
				PopUpManager.removePopUp(helpWindow2);
			});			
			PopUpManager.addPopUp(helpWindow2, parent, true);
			PopUpManager.centerPopUp(helpWindow2);			

			
		} else {
			saveCliente();
		}
	}

	private function myCloseHandler(evt:CloseEvent):void {
		if (evt.detail == Alert.YES) {
			saveCliente();
		}
	}
	
	
	public function saveCliente():void {
		this.contacto.nombre = nombre;

		if (!remSave) { 
			remSave = new RemoteObject();
			remSave.destination = "CreatingRpc";
			remSave.channelSet = ServerConfig.getInstance().channelSet;
			remSave.addEventListener(ResultEvent.RESULT, resultAddedCliente);
			remSave.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remSave.altaCliente(this, false);
	}

	private function resultAddedCliente(event:ResultEvent):void {
		var resultS:String = event.result as String;
		this.codigo = resultS;
		CatalogoFactory.getInstance().loadCatalogo("Contacto");
		CatalogoFactory.getInstance().loadCatalogo("Cliente");
		dispatchEvent(new Event("_addedClientOk"));
	}

	private function handleFault(event:FaultEvent):void {
		if (event.fault.message.toString().indexOf("IllegalArgumentException") > 0) {
			var alert:Alert = Alert.show(event.fault.rootCause.causedByException.message + "\n¿Desea guardar de todos modos?", "Advertencia", Alert.YES + Alert.NO, null, myCloseHandler);
			alert.width = 480;
		} else {
			Alert.show(event.fault.message);
		}		
	}	

	public function get razonSocial():String {
		return contacto ? contacto.ctoRSocial : "";
	}

	public function set razonSocial(value:String):void {
	}

	public function get rut():String {
		return contacto ? contacto.ctoRUT : "";
	}
	
	public function set rut(value:String):void {
	}

	public function get direccion():String {
		return contacto ? contacto.ctoDireccion : "";
	}
	
	public function set direccion(value:String):void {
	}

	public function get documentsPendientes():DocPendientesCliente {
		return _documentsPendientes;
	}

	public function set documentsPendientes(value:DocPendientesCliente):void{
		_documentsPendientes = value;
	}


}
}
