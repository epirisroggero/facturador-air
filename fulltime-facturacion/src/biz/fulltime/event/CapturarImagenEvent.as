// ActionScript file

package biz.fulltime.event {
	
import flash.events.Event;

public class CapturarImagenEvent extends Event {
	
	public static const CAPTURA_FINALIZADA:String = "_capturaImagenFinalizada_";

	public var dataImage:Object;
	
	public var docId:String;
		
	public function CapturarImagenEvent(type:String, docId:String = null) {
		super(type, false, false);
	
		this.docId = docId;
	}
}

}