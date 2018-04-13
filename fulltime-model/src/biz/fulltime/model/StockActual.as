package biz.fulltime.model {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.StockActual")]
public class StockActual {
	public var articulo:Articulo;

	public var deposito:Deposito;

	public var SAcantidad:String;

	public function StockActual() {
	}
}
}