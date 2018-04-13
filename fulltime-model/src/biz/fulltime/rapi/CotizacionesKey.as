package biz.fulltime.rapi {

[RemoteClass(alias = "uy.com.tmwc.facturator.rapi.CotizacionesKey")]
public class CotizacionesKey {

  public var monedaCotizacion:String;
  public var moneda:String;
  public var esCompra:Boolean;

  public function CotizacionesKey(monedaCotizacion:String = null, moneda:String = null, esCompra:Boolean = false) {
    this.monedaCotizacion = monedaCotizacion;
    this.moneda = moneda;
    this.esCompra = esCompra;
  }

  public function getMonedaCotizacion():String {
    return this.monedaCotizacion;
  }

  public function getMoneda():String {
    return this.moneda;
  }

  public function isEsCompra():Boolean {
    return this.esCompra;
  }
  
  public function toString():String {
	  return monedaCotizacion + "_" + moneda + "_" + esCompra;
  }


}
}