package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Banco")]
public class Banco extends CodigoNombreEntity {
	
	public var bancoAbrevia:String;
	
	public var bancoNotas:String;
	
	public var bancoTipo:String;
	
	public function Banco(codigo:String = null, nombre:String = null) {
		super(codigo, nombre)
	}
}
}