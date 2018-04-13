package biz.fulltime.event {
import flash.events.Event;

public class ListadoFacturasEvent extends Event {
	
	public static const FACTURAS_SELECTED:String = "_facturasSelected";
	
	private var _facturas:Vector.<Object>;
	
	public function ListadoFacturasEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) {
		super(type, bubbles, cancelable);
	}
	
	public function get facturas():Vector.<Object> {
		return _facturas;
	}

	public function set facturas(value:Vector.<Object>):void {
		_facturas = value;
	}

}
}