package biz.fulltime.event {
	
	import biz.fulltime.model.Documento;
	
	import flash.events.Event;
	
	public class ReciboEvent extends Event {
		
		public static const RECIBO_MODIFICADO:String = "reciboModificado";
		
		public var recibo:Documento;
		
		public function ReciboEvent(type:String) {
			super(type, true, true);
		}
	}
}
