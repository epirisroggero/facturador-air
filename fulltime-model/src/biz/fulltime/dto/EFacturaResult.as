package biz.fulltime.dto {
import flash.utils.ByteArray;

[RemoteClass(alias="uy.com.tmwc.facturator.dto.EFacturaResult")]
public class EFacturaResult {

	private var _filePDFData:ByteArray;

	private var _fileName:String;

	private var _resultData:String;

	private var _docCFEId:Number;
	
	private var _efacturaFail:Boolean;

	public function EFacturaResult() {
	}


	public function get efacturaFail():Boolean {
		return _efacturaFail;
	}

	public function set efacturaFail(value:Boolean):void {
		_efacturaFail = value;
	}

	public function get docCFEId():Number {
		return _docCFEId;
	}

	public function set docCFEId(value:Number):void {
		_docCFEId = value;
	}

	public function get resultData():String {
		return _resultData;
	}

	public function set resultData(value:String):void {
		_resultData = value;
	}

	public function get fileName():String {
		return _fileName;
	}

	public function set fileName(value:String):void {
		_fileName = value;
	}

	public function get filePDFData():ByteArray {
		return _filePDFData;
	}

	public function set filePDFData(value:ByteArray):void {
		_filePDFData = value;
	}

}
}