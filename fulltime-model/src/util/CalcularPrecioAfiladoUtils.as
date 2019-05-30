package util {
import biz.fulltime.model.Articulo;
import biz.fulltime.model.ArticuloPrecio;
import biz.fulltime.model.Cuponera;
import biz.fulltime.model.Documento;

public class CalcularPrecioAfiladoUtils {

	public static function calcularPrecio(articuloPrecio:ArticuloPrecio, largo:BigDecimal, documento:Documento):BigDecimal {
		var familia:String = articuloPrecio.articulo.familiaId;

		var precio:BigDecimal = documento.convertirMonedaStr(articuloPrecio.moneda.codigo, documento.moneda.codigo, new BigDecimal(articuloPrecio.precio));
		var costo:BigDecimal = (articuloPrecio.articulo.costo && articuloPrecio.articulo.monedaCosto)
			? documento.convertirMonedaStr(articuloPrecio.articulo.monedaCosto.codigo, documento.moneda.codigo, new BigDecimal(articuloPrecio.articulo.costo)) 
			: BigDecimal.ZERO;
		
		switch (familia) {
			case "9900201": // Cuchilla HSS
			case "9800201": // Cuchilla HS
			case "8900201": // Cuchillas Rectas
				return precio.add(largo.multiply(costo));
			
			default:
				return precio;

		}

	}

}
}