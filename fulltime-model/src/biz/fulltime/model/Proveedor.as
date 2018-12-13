package biz.fulltime.model {
import biz.fulltime.conf.ServerConfig;

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.ByteArray;

import mx.collections.XMLListCollection;
import mx.controls.Alert;
import mx.core.FlexGlobals;
import mx.events.CloseEvent;
import mx.managers.ISystemManager;
import mx.managers.PopUpManager;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;
import mx.styles.StyleManager;

import spark.components.TitleWindow;

import util.CatalogoFactory;
import util.ErrorPanel;
import util.WarningPnl;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Proveedor")]
public class Proveedor extends CodigoNombreEntity {

	public var esNuevo:Boolean;

	public var contacto:Contacto;

	public var categPrvId:String;

	public var foto:ByteArray;

	public var rubIdPrv:String;

	public var prvIdNom:String;

	public var locIdPrv:Number;

	public var pPidPrv:String;

	public var prvAplicaTopes:String;

	public var prvContribuyente:Number;

	public var prvDto1:String;

	public var prvDto2:String;

	public var prvDto3:String;

	public var prvIvaInc:String = "S";

	public var prvRanking:String;

	public var prvSRIautorizacion:String;

	public var prvSRIvencimiento:Date;

	public var retencionIdPrv:Number;

	public var textoIdPrv:String;

	public var planPagos:PlanPagos;
	
	public var canalYoutube:String;
	
	public var googleMaps:String;
	
	public var descuentoRecibo:String;
	
	public var facturaElectronica:String = "N";


	/// Persistence
	private var remSave:RemoteObject;
	
	private var remVerify:RemoteObject;

	private var remMerge:RemoteObject;


	public function Proveedor() {
		super();
	}

	public function mergeProveedor():void {
		if (!remMerge) {
			remMerge = new RemoteObject();
			remMerge.destination = "CreatingRpc";
			remMerge.channelSet = ServerConfig.getInstance().channelSet;
			remMerge.addEventListener(ResultEvent.RESULT, resultMergeProveedor);
			remMerge.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remMerge.modificarProveedor(this);
	}

	private function resultMergeProveedor(event:ResultEvent):void {
		var resultM:* = event.result;
		dispatchEvent(new Event("_savedProveedorOk"));
	}
	
	public function verificarDatosProveedor():void {
		this.contacto.nombre = nombre;
		
		if (!remVerify) { 
			remVerify = new RemoteObject();
			remVerify.destination = "CreatingRpc";
			remVerify.channelSet = ServerConfig.getInstance().channelSet;
			remVerify.addEventListener(ResultEvent.RESULT, resultVerifyProveedor);
			remVerify.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remVerify.verifyAltaProveedor(this);
	}
	
	private function resultVerifyProveedor(event:ResultEvent):void {
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
				saveProveedor();
			});
			
			helpWindow2.addEventListener(CloseEvent.CLOSE, function (event:Event):void {
				PopUpManager.removePopUp(helpWindow2);
			});			
			PopUpManager.addPopUp(helpWindow2, parent, true);
			PopUpManager.centerPopUp(helpWindow2);			
			
			
		} else {
			saveProveedor();
		}
	}
	
	private function myCloseHandler(evt:CloseEvent):void {
		if (evt.detail == Alert.YES) {
			saveProveedor();
		}
	}


	public function saveProveedor():void {
		this.contacto.nombre = nombre;

		if (!remSave) {
			remSave = new RemoteObject();
			remSave.destination = "CreatingRpc";
			remSave.channelSet = ServerConfig.getInstance().channelSet;
			remSave.addEventListener(ResultEvent.RESULT, resultAddedProveedor);
			remSave.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remSave.altaProveedor(this);
	}

	private function resultAddedProveedor(event:ResultEvent):void {
		var resultS:String = event.result as String;

		this.codigo = resultS;

		CatalogoFactory.getInstance().loadCatalogo("Contacto");

		dispatchEvent(new Event("_addedProveedorOk"));
	}


	private function handleFault(event:FaultEvent):void {
		var message:String = event.fault && event.fault.rootCause && event.fault.rootCause.localizedMessage ? event.fault.rootCause.localizedMessage : null;
		if (!message) {
			message = event.message.toString();
		}				
		Alert.show(message, "Error", 4, null, null, StyleManager.getStyleManager(null).getStyleDeclaration('.icons32').getStyle('ErrorIcon'));
	}


}

}
