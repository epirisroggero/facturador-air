package biz.fulltime.util {
import mx.validators.StringValidator;
import mx.validators.ValidationResult;
import mx.validators.Validator;

import util.Utils;

public class RutValidator extends StringValidator {

	private var _checkRut:Boolean;


	// Define Array for the return value of doValidation().
	private var results:Array;

	public function RutValidator() {
		super();
	}

	// Define the doValidation() method.

	public function get checkRut():Boolean {
		return _checkRut;
	}

	public function set checkRut(value:Boolean):void {
		_checkRut = value;
	}

	override protected function doValidation(value:Object):Array {

		// Convert value to a Number.
		var inputValue:Number = Number(value);

		// Clear results Array.
		results = [];

		// Call base class doValidation().
		results = super.doValidation(value);
		// Return if there are errors.
		if (results.length > 0) {
			return results;
		}

		if (checkRut) {
			var isValidRut:Boolean = Utils.validate_isRUT(value.toString());
			if (!isValidRut) {
				results.push(new ValidationResult(true, null, "Error", "Número de RUT inválido."));
			}
			
		} else {
			var isValidCI:Boolean = Utils.validate_isCI(value.toString());
			if (!isValidCI) {
				results.push(new ValidationResult(true, null, "Error", "Número de documento inválido."));
			}
		
		}
		
		return results;
	}






}
}