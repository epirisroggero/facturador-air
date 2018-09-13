package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Concepto")]
public class Concepto extends CodigoNombreEntity {

	public var conceptoActivo:String;
	
	public var conceptoIdNom:String;
	
	public var conceptoRetencion:String;
	
	public var conceptoRubro:String;
	
	public var conceptoTipo:String;
	
	public var conceptoTotales:String;
	
	public var grupoCptId:String;
	
	public var ivaIdConcepto:Number;

	public function Concepto() {
	}

}
}