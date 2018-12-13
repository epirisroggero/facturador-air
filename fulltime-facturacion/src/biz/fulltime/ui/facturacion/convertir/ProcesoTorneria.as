//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2015 Ernesto Piris. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF IdeaSoft Co. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.ui.facturacion.convertir {
import biz.fulltime.conf.ServerConfig;
import biz.fulltime.model.Cliente;
import biz.fulltime.model.Comprobante;
import biz.fulltime.model.Documento;
import biz.fulltime.model.PlanPagos;
import biz.fulltime.model.PreciosVenta;
import biz.fulltime.model.Vendedor;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;
import mx.styles.StyleManager;

import spark.components.TitleWindow;

import util.CatalogoFactory;

public class ProcesoTorneria extends EventDispatcher {

	[Bindable]
	private var _documento:Documento;
	
	private var helpWindow:TitleWindow;

	public function ProcesoTorneria() {
	}
	
	protected function convertir(doc:Documento):void {
		_documento = doc;
		
		if (_documento.comprobante.codigo == '70') {
			convertirDocumento(_documento, '71');
		} else if (_documento.comprobante.codigo == '71') {
			convertirDocumento(_documento, '72');
		} else if (_documento.comprobante.codigo == '72') {
			convertirDocumento(_documento, '73');
		} 
		
	}
	
	public function convertirDocumento(doc:Documento, codigo:String):void {
		var comprobante:Comprobante;
		for each (var c:Comprobante in CatalogoFactory.getInstance().comprobantesUsuario) {
			if (c.codigo == codigo) {
				comprobante = c;
				break;
			}
		}

		var clienteRemObj:RemoteObject = new RemoteObject();
		clienteRemObj.destination = "CreatingRpc";
		clienteRemObj.channelSet = ServerConfig.getInstance().channelSet;
		clienteRemObj.addEventListener(FaultEvent.FAULT, handleFault);
		clienteRemObj.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
			var cliente:Cliente = evt.result as Cliente;
			
			var planPagos:PlanPagos = cliente.planPagos;
			var rut:String = cliente.contacto.ctoRUT;
			var razonSocial:String = cliente.contacto.ctoRSocial;
			var direccion:String = cliente.contacto.ctoDireccion;
			var telefono:String = null;
			if (cliente.contacto.ctoTelefono) {
				if (cliente.contacto.ctoTelefono.length > 30) {
					telefono = cliente.contacto.ctoTelefono.substring(0, 30);
				} else {
					telefono = cliente.contacto.ctoTelefono;
				}
			}
			
			var vendedor:Vendedor = cliente.vendedor;
			var preciosVenta:PreciosVenta = cliente.preciosVenta;
			
			var documento:Documento = new Documento(comprobante);
			documento.cliente = cliente;
			documento.moneda = doc.moneda;
			documento.lineas = doc.lineas;
			documento.preciosVenta = doc.preciosVenta ? doc.preciosVenta : preciosVenta;
			
			documento.vendedor = doc.vendedor ? doc.vendedor : vendedor;
			documento.direccion = doc.direccion ? doc.direccion : direccion;
			documento.razonSocial = doc.razonSocial ? doc.razonSocial : razonSocial;
			documento.rut = doc.rut ? doc.rut : rut;
			documento.telefono = doc.telefono ? doc.telefono : telefono;
			
			documento.condicion = doc.condicion ? doc.condicion : planPagos;
			documento.comisiones = doc.comisiones;
			documento.docTCF = doc.docTCF;
			documento.docTCC = doc.docTCC;
			
			documento.pendiente = !(codigo == "73");
			documento.entrega = doc.entrega;
			documento.agencia = doc.agencia;
			documento.cantidadBultos = doc.cantidadBultos
			documento.chofer = doc.chofer;
			documento.fechaDoc = doc.fechaDoc;
			documento.fechaEmision = doc.fechaEmision;
			documento.localidad = doc.localidad;
			documento.notas = doc.notas;
			documento.cuotasDocumento = doc.cuotasDocumento;
			
			if (doc.processId && doc.processId.length > 0) {
				documento.processId = doc.processId;
			} else {
				documento.processId = String(doc.docId);
			}
			documento.usuIdAut = doc.usuIdAut;
			
			documento.planPagos = null;
			documento.cuotasDocumento.cuotas = new ArrayCollection();
			
			if ((codigo == "71" || codigo == "72" || codigo == "73")) { // no generar número de serie para comprobantes.
				documento.serie = codigo;
				documento.numero = doc.numero;
				
				altaMovimientoStock(doc, documento);
			} 

		});
		
		clienteRemObj.addEventListener(FaultEvent.FAULT, function handleFault(e:FaultEvent):void {
			Alert.show(e.fault.faultString, "Error", 4, null, null);
		});
		
		clienteRemObj.findCatalogEntity("Cliente", doc.cliente.codigo);
	}
	
	
	private function altaMovimientoStock(oldDoc:Documento, documento:Documento):void {
		var remObjAlta:RemoteObject = new RemoteObject();
		remObjAlta.destination = "CreatingRpc";
		remObjAlta.channelSet = ServerConfig.getInstance().channelSet;
		remObjAlta.showBusyCursor = true;
		remObjAlta.addEventListener(FaultEvent.FAULT, handleFault);
		remObjAlta.addEventListener(ResultEvent.RESULT, function(event:ResultEvent):void {
			var docId:String = event.result as String;
			
			var remObjUpdate:RemoteObject = new RemoteObject();
			remObjUpdate.destination = "CreatingRpc";
			remObjUpdate.showBusyCursor = true;
			remObjUpdate.channelSet = ServerConfig.getInstance().channelSet;
			remObjUpdate.addEventListener(FaultEvent.FAULT, handleFault);
			remObjUpdate.addEventListener(ResultEvent.RESULT, function(evt1:ResultEvent):void {
				var remObj1:RemoteObject = new RemoteObject();
				remObj1.destination = "CreatingRpc";
				remObj1.showBusyCursor = true;
				remObj1.channelSet = ServerConfig.getInstance().channelSet;
				remObj1.addEventListener(FaultEvent.FAULT, handleFault);
				remObj1.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
					//factura = evt.result as Documento;
					//currentState = "default";
				});
				remObj1.getDocumento(docId);
			});
			remObjUpdate.finalizarMovimientoStock(oldDoc);
		});
		remObjAlta.alta(documento);
	}
	

	
	private function closeHandlerComisiones(event:Event):void {
		helpWindow.removeEventListener(CloseEvent.CLOSE, closeHandlerComisiones);
		PopUpManager.removePopUp(helpWindow as IFlexDisplayObject);
		helpWindow = null;
	}

	
	public function handleFault(event:FaultEvent):void {
		var message:String = event.fault && event.fault.rootCause && event.fault.rootCause.localizedMessage ? event.fault.rootCause.localizedMessage : null;
		if (!message) {
			message = event.message.toString();
		}				
		Alert.show(message, "Error", 4, null, null, StyleManager.getStyleManager(null).getStyleDeclaration('.icons32').getStyle('ErrorIcon'));

	}

}
}