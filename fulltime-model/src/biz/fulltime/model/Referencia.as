package biz.fulltime.model {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Referencia")]
public class Referencia extends CodigoNombreEntity {
	public function Referencia(codigo:String = null, nombre:String = null) {
		super(codigo, nombre)
	}
}
}