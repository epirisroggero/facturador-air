package biz.fulltime.dto {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.dto.ClienteDTO")]
public class ClienteDTO {

	public var codigo:String;
	public var nombre:String;
	public var razonSocial:String;

	public var direccion:String;
	public var telefono:String;
	public var celular:String;

	public var email:String;
	public var zona:String;
	public var localidad:String;
	public var depto:String;
	public var rut:String;
	
	public var encargadoCuenta:String;
	public var venIdCli:String;

	public var activo:Boolean;

	public function ClienteDTO() {
	}
}
}
