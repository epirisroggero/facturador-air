package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.Iva")]
public class Iva extends CodigoNombreEntity {
	private var _tasa:String;

	public function Iva() {
	}

	public function get tasa():String {
		return _tasa;
	}

	public function set tasa(value:String):void {
		this._tasa = value;
	}

	public function getTasaIva():BigDecimal {
		if (_tasa) {
			return new BigDecimal(_tasa);
		} else {
			return BigDecimal.ZERO;
		}
	}

}

}
