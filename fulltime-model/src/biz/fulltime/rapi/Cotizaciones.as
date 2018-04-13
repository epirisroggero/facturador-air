package biz.fulltime.rapi {

[RemoteClass(alias = "uy.com.tmwc.facturator.rapi.Cotizaciones")]
public class Cotizaciones {

	public var map:Object; // new HashMap<CotizacionesKey, BigDecimal>();

	public function agregarCotizacion(monedaCotizacion:String, moneda:String, esCompra:Boolean, valor:String):void {
		if (map == null) {
			map = new Object();
		}
		var key:CotizacionesKey = new CotizacionesKey(monedaCotizacion, moneda, esCompra);

		map[key.toString()] = valor;
	}

/*
public function getCotizacion(monedaCotizacion:String, moneda:String, esCompra:Boolean):BigDecimal {
  return BigDecimal(this.map.(new CotizacionesKey(monedaCotizacion, moneda, esCompra)));
}
*/

}
}
