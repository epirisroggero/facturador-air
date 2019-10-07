package biz.fulltime.util {
	import biz.fulltime.conf.ServerConfig;
	
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.remoting.RemoteObject;
	import mx.styles.StyleManager;
	
	public class DocumentosUtils {
		
		public static function getNewRemoteObject(showBusyCursor:Boolean = true):RemoteObject {
			var remObj:RemoteObject = new RemoteObject();
			remObj.destination = "CreatingRpc";
			remObj.showBusyCursor = showBusyCursor;
			remObj.channelSet = ServerConfig.getInstance().channelSet;

			return remObj;
		}		
	}
}