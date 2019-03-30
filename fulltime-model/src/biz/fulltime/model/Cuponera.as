package biz.fulltime.model {

import mx.collections.ArrayCollection;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.deudores.Cuponera")]
public class Cuponera {

	public var artId:String;
	
	public var fecha:Date;

	public var precioTotal:String;

	public var cantidadTotal:String;

	public var precioUnitario:String;
	
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