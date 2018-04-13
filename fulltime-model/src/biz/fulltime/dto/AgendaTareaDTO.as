package biz.fulltime.dto {
	import biz.fulltime.conf.ServerConfig;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.dto.AgendaTareaDTO")]
public class AgendaTareaDTO {
	
	public var ageId:String;
	
	public var fechaHora:Date;
	
	public var fechaInicio:Date;
	
	public var fechaHoraFin:Date;

	public var estado:String;
		
	public var descripcion:String;
	
	public var prioridad:String;
	
	public var tipo:String;
	
	public var ctoNombre:String = "";
	
	public var ctoDireccion:String = "";
	
	public var ctoTelefono:String = "";
	
	public var tarea:String;
	
	public var usuSolicitante:String;
	
	public var idUsuAsignado:String;
	
	public var nroOrden:String;
	
	public var orden:Number;

	public var selected:Boolean;
	
	public function AgendaTareaDTO() {
	}
	
	public function guardarCambios():void {
		var remObjMod:RemoteObject = new RemoteObject();
		remObjMod.destination = "CreatingRpc";
		remObjMod.channelSet = ServerConfig.getInstance().channelSet;
		remObjMod.showBusyCursor = true;		
		
		remObjMod.addEventListener(FaultEvent.FAULT, onFault);
		remObjMod.modificarTareaDTO(this);
		
	}
	
	private function onFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, 'Error');
	}


	
}
}