package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.CotizacionesMonedas")]
public class CotizacionesMonedas {
	
	public var dia:Date;
	
	public var empId:String;;
	
	public var dolarCompra:String;
	
	public var dolarVenta:String;
	
	public var euroCompra:String;

	public var euroVenta:String;

	public function CotizacionesMonedas() {
	}
}
}
