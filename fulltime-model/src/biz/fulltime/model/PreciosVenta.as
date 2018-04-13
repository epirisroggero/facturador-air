package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.PreciosVenta")]
public class PreciosVenta extends CodigoNombreEntity {
	public function PreciosVenta(codigo:String = "", nombre:String = "") {
		super(codigo, nombre);
	}
}

}
