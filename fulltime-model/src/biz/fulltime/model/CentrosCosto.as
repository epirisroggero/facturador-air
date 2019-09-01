package biz.fulltime.model {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.CentrosCosto")]
public class CentrosCosto extends CodigoNombreEntity {
	public function CentrosCosto(codigo:String = null, nombre:String = null) {
		super(codigo, nombre)
	}
}
}