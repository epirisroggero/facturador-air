package biz.fulltime.model {

import mx.collections.ArrayCollection;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.deudores.Cuponera")]
public class Cuponera {

	public var articulo:Articulo;
	
	public var fecha:Date;
	
	public var tipoComprobante:String;
	
	public var numero:String;

	public var precioTotal:String;

	public var cantidadTotal:String;

	public var precioUnitario:String;
	
	public var moneda:Moneda;
	
	public var stock:String;

	public var lineasCuponera:ArrayCollection = new ArrayCollection();

	public function Cuponera() {
	}
	
	public function getStockValue():BigDecimal {
		if (!stock) {
			return BigDecimal.ZERO;
		}
		return new BigDecimal(stock);
	}

}
}