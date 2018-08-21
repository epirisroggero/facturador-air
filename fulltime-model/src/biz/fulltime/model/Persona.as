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

import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.events.CloseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import spark.components.TitleWindow;

import util.ErrorPanel;

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
		var sm:ISystemManager = ISystemManager(FlexGlobals.topLevelApplication.systemManager);
		// no types so no dependencies
		var mp:Object = sm.getImplementation("mx.managers.IMarshallPlanSystemManager");
		var parent:Sprite;
		if (mp && mp.useSWFBridge()) {
			parent = Sprite(sm.getSandboxRoot());
		} else {
			parent = Sprite(FlexGlobals.topLevelApplication);
		}

		var  helpWindow:TitleWindow = new TitleWindow();
		helpWindow.title = "Error";
		helpWindow.width = 640;
		
		var errorPnl:ErrorPanel = new ErrorPanel();
		errorPnl.type = 0;
		errorPnl.textColor = 0x000000;
		errorPnl.errorText = "No se pudo guardar " + codigo + " - " + nombre + ".";
		errorPnl.detailsText = event.fault.getStackTrace();
		errorPnl.showButtons = true;
		
		PopUpManager.addPopUp(helpWindow, parent, true);
		PopUpManager.centerPopUp(helpWindow);
				
		helpWindow.addElement(errorPnl);
		
		helpWindow.addEventListener(CloseEvent.CLOSE, function():void {
			PopUpManager.removePopUp(helpWindow as IFlexDisplayObject);
		});					
		errorPnl.addEventListener(CloseEvent.CLOSE, function():void {
			PopUpManager.removePopUp(helpWindow as IFlexDisplayObject);
		});

		
	}

}
}