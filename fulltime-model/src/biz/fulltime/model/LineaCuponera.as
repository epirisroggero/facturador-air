package biz.fulltime.model {

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.deudores.LineaCuponera")]
public class LineaCuponera {
	
	public function LineaCuponera() {
	}

	private var _docId:String;

	private var _fecha:Date;

	private var _serie:String;

	private var _numero:Number;

	private var _cantidad:Number;

	private var _saldo:Number;
	
	private var _comprobante:String;

	
	
	public function get docId():String {
		return _docId;
	}

	public function set docId(value:String):void {
		_docId = value;
	}

	public function get fecha():Date {
		return _fecha;
	}

	public function set fecha(value:Date):void {
		_fecha = value;
	}

	public function get serie():String {
		return _serie;
	}

	public function set serie(value:String):void {
		_serie = value;
	}

	public function get numero():Number {
		return _numero;
	}

	public function set numero(value:Number):void {
		_numero = value;
	}

	public function get cantidad():Number {
		return _cantidad;
	}

	public function set cantidad(value:Number):void {
		_cantidad = value;
	}

	public function get saldo():Number {
		return _saldo;
	}

	public function set saldo(value:Number):void {
		_saldo = value;
	}

	public function get comprobante():String {
		return _comprobante;
	}

	public function set comprobante(value:String):void {
		_comprobante = value;
	}


}
}