package cv.validators {
	
	public class EmailValidator {
		
		/**
		 * Validates email address
		 *
		 * @param	strEmail	The email address
		 * @return	Whether email address is valid or not.
		 */
		public static function validate(strEmail:String):Boolean {
			var regex:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;           
			return regex.test(strEmail);
		}
	}
}