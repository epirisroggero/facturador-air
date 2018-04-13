package biz.fulltime.util {
	import mx.validators.StringValidator;
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import util.Utils;
	
	public class CIValidator extends StringValidator {
		
		private var _checkCI:Boolean;
		
		
		// Define Array for the return value of doValidation().
		private var results:Array;
		
		public function CIValidator() {
			super();
		}
		
		// Define the doValidation() method.
		
		public function get checkCI():Boolean {
			return _checkCI;
		}
		
		public function set checkCI(value:Boolean):void {
			_checkCI = value;
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
			
			if (checkCI) {
				var isValidCI:Boolean = Utils.validate_isCI(value.toString());
				if (!isValidCI) {
					results.push(new ValidationResult(true, null, "Error", "Número de Documento es inválido."));
				}
				
			}
			return results;
		}
		
		
		
		
		
		
	}
}