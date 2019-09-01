//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import biz.fulltime.conf.ServerConfig;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;
import flash.utils.setTimeout;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.formatters.DateFormatter;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import util.CatalogoFactory;
import util.ErrorPanel;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.AgendaTarea")]
public class AgendaTarea extends EventDispatcher {
	public var ageId:String;

	public var empId:String;

	public var descripcion:String;

	public var notas:String;

	private var _estado:String;

	private var _fechaHora:Date;

	private var _contacto:Contacto;

	public var fechaHoraFin:Date;

	private var _fechaInicio:Date;

	public var prioridad:String = "M";

	public var tipo:String;

	public var vinculo:String;

	private var _nroOrden:String;

	private var _orden:Number;


	public var tarea:Tarea;

	public var usuarioSolicitante:Usuario;

	public var usuarioAsignado:Usuario;

	public var selected:Boolean;

	public var ageBlob:ByteArray;

	public var ageBlobExt:String;

	public var textoAdjunto:String;

	public var supervisor1:String;

	public var supervisor2:String;

	public var supervisor3:String;

	public var notify:Boolean;

	public var repetir:Boolean;

	public var repetirCantidad:int = 1;

	public var repetirModo:int = -1;

	public var repetirFechas:ArrayCollection;
	
	public var usuEstado:String;
	
	public var usuCliId:String;

	public function AgendaTarea() {
	}

	public function get fechaInicio():Date {
		return _fechaInicio;
	}

	public function set fechaInicio(value:Date):void {
		_fechaInicio = value;
	}

	public function get contacto():Contacto {
		return _contacto;
	}

	public function set contacto(value:Contacto):void {
		_contacto = value;
	}

	public function get estado():String {
		return _estado;
	}

	public function set estado(value:String):void {
		var oldEstado:String = _estado;
		_estado = value;

		if (oldEstado && oldEstado != _estado) {
			fechaHoraFin = _estado == "C" ? new Date() : null;

			var remObjMod:RemoteObject = new RemoteObject();
			remObjMod.destination = "CreatingRpc";
			remObjMod.channelSet = ServerConfig.getInstance().channelSet;
			remObjMod.showBusyCursor = true;

			var dateFormatter:DateFormatter = new DateFormatter();
			dateFormatter.formatString = "DD-MM-YYYY";

			remObjMod.addEventListener(ResultEvent.RESULT, function():void {
				if (estado == "C" && notify) {
					for each (var user:Usuario in CatalogoFactory.getInstance().usuarios) {
						if (user.codigo == usuarioSolicitante.codigo && user.usuEmail.length > 0) {
							var msg:String = "\n";
							msg += "TAREA: " + tarea.nombre.toUpperCase() + " \n\n";
							if (contacto && contacto.codigo && contacto.nombre) {
								msg += "\nCLIENTE: " + contacto.codigo.toUpperCase()+ "-" + contacto.nombre.toUpperCase()  + "\n\n";
							}
							msg += "USUARIO ASIGNADO: " + usuarioAsignado.nombre.toUpperCase() + "\n\n";
							msg += "FECHA INICIO: " + dateFormatter.format(fechaInicio) + "\n";
							msg += "FECHA FINALIZACIÓN: " + dateFormatter.format(fechaHoraFin) + "\n\n";
							msg += "PRIORIDAD: " + (prioridad == "M" ? 'MEDIA' : (prioridad == "A" ? "ALTA" : "BAJA")) + "\n";

							if (vinculo && vinculo.length > 0) {
								msg += "VINCULO: " + vinculo + "\n";
							}
							msg += "" + "\n";
							msg += "DESCRIPCIÓN DE TAREA" + "\n";
							msg += descripcion + "\n\n";

							var index:int = notas.indexOf('NOTA FIN DE TAREA');
							if (index >= 0) {
								msg += notas.substring(index) + "\n";
							}

							var remObj:RemoteObject = new RemoteObject();
							remObj = new RemoteObject();
							remObj.destination = "CreatingRpc";
							remObj.channelSet = ServerConfig.getInstance().channelSet;
							remObj.addEventListener(FaultEvent.FAULT, onFault);
							remObj.showBusyCursor = false;

							var addresses:Array = new Array();

							addresses[0] = user.usuEmail;

							remObj.sendEmailExpediciones(addresses, "FINALIZACIÓN DE TAREA", msg, this, false);

							break;
						}
					}

				}

			});

			remObjMod.addEventListener(FaultEvent.FAULT, onFault);

			remObjMod.modificar(this);
		}
	}
	
	private function resultSendEMail(event:ResultEvent):void {
		var result:String = event.result as String;
		var resultXML:XML = new XML(result);
		
		var error:ErrorPanel = new ErrorPanel();
		error.backgroundAlpha = .75;
		error.showButtons = false;
		
		var parent:Sprite;
		
		var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		// no types so no dependencies
		var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		if (mp && mp.useSWFBridge()) {
			parent = Sprite(sm.getSandboxRoot());
		} else {
			parent = Sprite(FlexGlobals.topLevelApplication);
		}

		if (resultXML.state == "true") {
			error.type = 2;
			error.errorText = "El correo se ha enviado correctamente.";

			PopUpManager.addPopUp(error, parent, true);
			PopUpManager.centerPopUp(error);
		} else {
			error.type = 0;
			error.errorText = "Error al enviar correo.";
		}
		
		PopUpManager.addPopUp(error, parent, true);
		PopUpManager.centerPopUp(error);
		setTimeout(function():void {
			PopUpManager.removePopUp(error)
		}, 500);
		
	}


	private function onFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, 'Error');
	}

	public function get fechaHora():Date {
		return _fechaHora;
	}

	public function set fechaHora(value:Date):void {
		_fechaHora = value;

		dispatchEvent(new Event("cambioHora"));
	}

	public function get turno():String {
		if (fechaHora.hours < 12) {
			return "matutino";
		} else {
			return "vespertino";
		}
	}

	public function set turno(value:String):void {
		if (value == "matutino") {
			fechaHora.hours = 9;
		} else {
			fechaHora.hours = 14;
		}
	}

	public function get nroOrden():String {
		return _nroOrden;
	}

	public function set nroOrden(value:String):void {
		_nroOrden = value;
	}

	public function get orden():Number {
		return _orden;
	}

	public function set orden(value:Number):void {
		_orden = value;
	}


}
}
