package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.ArticuloCompraVentaCosto")]
public class ArticuloCompraVentaCosto extends CodigoNombreEntity {
		
	public var costo:String;
	
	public var fichaMonedaId:String;
	
	public var compraMonedaId:String;
	
	public var ventaMonedaId:String;
	
	public var costoCompra:String;
	
	public var costoVenta:String;
	
	
	public var comprobanteCompra:String;
	
	public var costoCompraSinDescuentos:String;
	
	public var costoCompraDescuento:String;
	
	
	public var comprobanteVenta:String;
	
	public var docCompraId:String;
	
	public var docVentaId:String;
	
	public var selected:Boolean = true;

}
}