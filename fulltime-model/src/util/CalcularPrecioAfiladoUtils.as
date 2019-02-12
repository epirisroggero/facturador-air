package util {
import biz.fulltime.model.Articulo;
import biz.fulltime.model.ArticuloPrecio;

public class CalcularPrecioAfiladoUtils {

	public static function calcularPrecio(articuloPrecio:ArticuloPrecio, largo:BigDecimal):BigDecimal {
		var familia:String = articuloPrecio.articulo.familiaId;

		switch (familia) {
			case "9800101": // Sierra Circular
				return new BigDecimal(articuloPrecio.precio);
			//obtenerPrecioMinorista(articulo.codigo);

			case "9900201": // Cuchilla HSS
				return new BigDecimal(articuloPrecio.precio);
			//obtenerPrecioMinorista(articulo.codigo);

			case "9800201": // Cuchilla HS
				return new BigDecimal(articuloPrecio.precio);
			//obtenerPrecioMinorista(articulo.codigo);

			case "9800301": // Cuchillas Perfiladas
				return new BigDecimal(articuloPrecio.precio);
			//obtenerPrecioMinorista(articulo.codigo);

			case "9800401": // Fresas
				return new BigDecimal(articuloPrecio.precio);
			//obtenerPrecioMinorista(articulo.codigo);

		}

		return BigDecimal.ZERO;

	}

}
}