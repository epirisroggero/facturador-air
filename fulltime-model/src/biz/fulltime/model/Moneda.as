package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Moneda")]
public class Moneda extends CodigoNombreEntity {
	
	public static const PESOS:String = "1";
	public static const DOLARES:String = "2";
	public static const EUROS:String = "3";

	public static const PESOS_ASTER:String = "4";
	public static const DOLARES_ASTER:String = "5";
	public static const EUROS_ASTER:String = "6";

	public var redondeo:Number = 4;

	private var _aster:Boolean = false;
	
	public var simbolo:String;

	public function get aster():Boolean {
		if (codigo) {
			return codigo == PESOS_ASTER || codigo == DOLARES_ASTER || codigo == EUROS_ASTER;
		}
		return _aster;
	}

	public function set aster(value:Boolean):void {
		_aster = value;
	}
	
	public function getRedondeo():Number {
		return redondeo;
	}

	public function setRedondeo(redondeo:Number):void {
		this.redondeo = redondeo;
	}

	public function Moneda() {
		super();
	}

}


}
