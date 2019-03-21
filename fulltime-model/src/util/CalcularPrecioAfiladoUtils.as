package util {
import biz.fulltime.model.Articulo;
import biz.fulltime.model.ArticuloPrecio;

public class CalcularPrecioAfiladoUtils {

	public static function calcularPrecio(articuloPrecio:ArticuloPrecio, largo:BigDecimal):BigDecimal {
		var familia:String = articuloPrecio.articulo.familiaId;

		switch (familia) {
			case "9900201": // Cuchilla HSS
			case "9800201": // Cuchilla HS
			case "8900201": // Cuchillas Rectas
				var costo:BigDecimal = articuloPrecio.articulo.costo ? new BigDecimal(articuloPrecio.articulo.costo) : BigDecimal.ZERO;
				return new BigDecimal(articuloPrecio.precio).add(largo.multiply(costo));
			
			case "9800101": // Sierra Circular
			case "9800301": // Cuchillas Perfiladas
			case "9800401": // Fresas
				return new BigDecimal(articuloPrecio.precio);
				
			default:
				return new BigDecimal(articuloPrecio.precio);

		}

	}

}
}