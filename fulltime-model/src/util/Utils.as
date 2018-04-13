package util {

public class Utils {
	
	public static function validate_isCI(ci:String):Boolean {
		if (ci.length == 0) {
			return true;
		}
		if (ci.length < 7) { 
			return false;
		}
		if (isNaN(Number( ci ))) {
			return false;
		}
		
		ci = clean_ci(ci);
		var dig:Number = new Number(ci.substr(7, 1));
		ci = ci.replace(/[0-9]$/, '');
		
		return (dig == validation_digit(ci));
		
	}
	
	public static function clean_ci(ci:String):String {
		if (!ci || ci.length == 0) {
			return '';			
		}
		return ci.replace(/\D/g, '');
	}

	public static function validation_digit(ci:String):Number {
		var a:int = 0;
		var i:int = 0;
		
		if (ci.length <= 6){
			for(i = ci.length; i < 7; i++){
				ci = '0' + ci;
			}
		}
		for(i = 0; i < 7; i++){
			a += (parseInt("2987634".substr(i, 1)) * parseInt(ci.substr(i, 1))) % 10;
		}
		if (a%10 === 0) {
			return 0;
		} else {
			return 10 - a % 10;
		}
	}
	
	public static function validate_isRUT(rut:String):Boolean {
		if (rut.length == 0) {
			return true;
		}
		if (rut.length != 12) {
			return false;
		}
		if (isNaN(Number( rut ))) {
			return false;
		}

		var dc:String = rut.substr(11, 1);
		var _rut:String = rut.substr(0, 11);
		var total:Number = 0;
		var factor:Number = 2;

		for (var i:int = 10; i >= 0; i--) {
			total += (factor * Number(_rut.substr(i, 1)));
			factor = (factor == 9) ? 2 : ++factor;
		}

		var dv:Number = 11 - (total % 11);

		if (dv == 11) {
			dv = 0;
		} else if (dv == 10) {
			dv = 1;
		}
		if (dv.toString() == dc) {
			return true;
		}
		return false;
	}
}

}