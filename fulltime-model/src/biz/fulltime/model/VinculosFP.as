package biz.fulltime.model {

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.VinculosFP")]
public class VinculosFP {

	private var _docIdFP1:Number;

	private var _docIdFP2:Number;

	private var _vinFPTipo:Number;

	private var _vinIE:String;

	public var docFP1:Documento;
	
	public var docFP2:Documento;

	
	public function VinculosFP() {
	}

	public function get docIdFP1():Number {
		return _docIdFP1;
	}

	public function set docIdFP1(value:Number):void {
		_docIdFP1 = value;
	}

	public function get docIdFP2():Number {
		return _docIdFP2;
	}

	public function set docIdFP2(value:Number):void {
		_docIdFP2 = value;
	}

	public function get vinFPTipo():Number {
		return _vinFPTipo;
	}

	public function set vinFPTipo(value:Number):void {
		_vinFPTipo = value;
	}

	public function get vinIE():String {
		return _vinIE;
	}

	public function set vinIE(value:String):void {
		_vinIE = value;
	}


}
}