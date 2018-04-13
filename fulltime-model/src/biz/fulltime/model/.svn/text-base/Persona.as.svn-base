//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import flash.events.Event;

import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import biz.fulltime.conf.ServerConfig;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Persona")]
public class Persona extends CodigoNombreEntity {

	public function Persona() {
	}

	private var remSave:RemoteObject;

	private var remUpdate:RemoteObject;

	private var remDelete:RemoteObject

	public var ctoPerCargo:String;

	public var ctoPerEmail:String;

	public var ctoPerTelefono:String;

	public var ctoPerCelular:String;

	public var ctoPerCumple:Date;

	public var ctoPerAniversario:Date;

	public var ctoPerNotas:String;

	public function savePersona():void {
		if (!remSave) {
			remSave = new RemoteObject();
			remSave.destination = "CreatingRpc";
			remSave.channelSet = ServerConfig.getInstance().channelSet;
			remSave.addEventListener(ResultEvent.RESULT, resultAddPerson);
			remSave.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remSave.altaPersona(this);
	}

	public function updatePersona():void {
		if (!remUpdate) {
			remUpdate = new RemoteObject();
			remUpdate.destination = "CreatingRpc";
			remUpdate.channelSet = ServerConfig.getInstance().channelSet;
			remUpdate.addEventListener(ResultEvent.RESULT, resultUpdatePerson);
			remUpdate.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remUpdate.editarPersona(this);
	}

	public function borrarPersona():void {
		if (!remDelete) {
			remDelete = new RemoteObject();
			remDelete.destination = "CreatingRpc";
			remDelete.channelSet = ServerConfig.getInstance().channelSet;
			remDelete.addEventListener(ResultEvent.RESULT, resultDeletePerson);
			remDelete.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remDelete.borrarPersona(this);
	}

	private function resultAddPerson(event:ResultEvent):void {
		var result:String = event.result as String;

		this.codigo = result;

		dispatchEvent(new Event("_addPersonaOk"));
	}

	private function resultUpdatePerson(event:ResultEvent):void {
		dispatchEvent(new Event("_updatePersonaOk"));
	}

	private function resultDeletePerson(event:ResultEvent):void {
		dispatchEvent(new Event("_deletePersonaOk"));
	}

	private function handleFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, "Error");
	}

}
}