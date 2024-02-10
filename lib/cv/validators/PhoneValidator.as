package cv.validators {
	
	public class PhoneValidator {
		
		/**
		 * Validates US phone number
		 * 
		 * @param	strPhoneNumber
		 * @return Whether phone number is valid or not.
		 */
		public static function validate(strPhoneNumber:String):Boolean {
			var regex:RegExp = /^((\+\d{1,3}(-| )?\(?\d\)?(-| )?\d{1,3})|(\(?\d{2,3}\)?))(-| )?(\d{3,4})(-| )?(\d{4})(( x| ext)\d{1,5}){0,1}$/i;   
			return regex.test(strPhoneNumber);
		}
	}
}