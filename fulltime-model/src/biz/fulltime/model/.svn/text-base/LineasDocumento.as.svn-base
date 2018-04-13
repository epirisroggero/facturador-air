package biz.fulltime.model {

import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.remoting.RemoteObject;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.LineasDocumento")]
public class LineasDocumento extends EventDispatcher {

	public var lineas:ArrayCollection = new ArrayCollection();

	public var documento:Documento;

	private var _deposito:String;

	private var _depositoDestinoId:String;

	private var _depositoOrigenId:String;


	private var _erroresStock:String;

	public function LineasDocumento() {
	}

	public function get depositoOrigenId():String {
		return _depositoOrigenId;
	}

	public function set depositoOrigenId(value:String):void {
		_depositoOrigenId = value;
	}

	public function get depositoDestinoId():String {
		return _depositoDestinoId;
	}

	public function set depositoDestinoId(value:String):void {
		_depositoDestinoId = value;
	}

	public function get deposito():String {
		return _deposito;
	}

	public function set deposito(value:String):void {
		_deposito = value;

		for each (var linea:LineaDocumento in lineas) {
			linea.deposito = _deposito;
		}
	}

	public function get erroresStock():String {
		return _erroresStock;
	}

	public function set erroresStock(value:String):void {
		_erroresStock = value;
	}

	private function handleFault(event:FaultEvent):void {
		Alert.show(event.message.toString(), "Error");
	}

}

}
