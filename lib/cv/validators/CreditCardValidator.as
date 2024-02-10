package cv.validators {
	
	public class CreditCardValidator {
		
		/**
		 * Determines if credit card is valid using the Luhn formula.
		 * 
		 * @param strCardNumber The credit card number.
		 * @return Returns true if String is a valid credit card number; otherwise false.
		 */
		public static function validate(strCardNumber:String):Boolean {
			if (cardNumber.length < 7 || cardNumber.length > 19 || Number(cardNumber) < 1000000) return false;
			
			var pre:Number;
			var sum:Number = 0;
			var alt:Boolean = true;
			var i:Number = cardNumber.length;
			
			while (--i > -1) {
				if (alt) {
					sum += Number(cardNumber.substr(i, 1));
				} else {
					pre =  Number(cardNumber.substr(i, 1)) * 2;
					sum += (pre > 8) ? pre -= 9 : pre;
				}
				
				alt = !alt;
			}
			
			return sum % 10 == 0;
		}
		
		/**
		 * Determines credit card provider by card number.
		 * 
		 * @param strCardNumber The credit card number.
		 * @return Returns name of the provider; values can be "visa", "mastercard", "discover", "amex", "diners", "other" or "invalid".
		 */
		public static function getCreditCardProvider(strCardNumber:String):String {
			if (!CreditCardValidator.validate(cardNumber)) return 'invalid';
			
			if (cardNumber.length == 13 || cardNumber.length == 16 && cardNumber.indexOf('4') == 0) {
				return 'visa';
			} else if (cardNumber.indexOf('51') == 0 || cardNumber.indexOf('52') == 0 || cardNumber.indexOf('53') == 0 || cardNumber.indexOf('54') == 0 || cardNumber.indexOf('55') == 0 && cardNumber.length == 16) {
				return 'mastercard';
			} else if (cardNumber.length == 16 && cardNumber.indexOf('6011') == 0) {
				return 'discover';
			} else if (cardNumber.indexOf('34') == 0 || cardNumber.indexOf('37') == 0 && cardNumber.length == 15) {
				return 'amex';
			} else if (cardNumber.indexOf('300') == 0 || cardNumber.indexOf('301') == 0 || cardNumber.indexOf('302') == 0 || cardNumber.indexOf('303') == 0 || cardNumber.indexOf('304') == 0 || cardNumber.indexOf('305') == 0 || cardNumber.indexOf('36') == 0 || cardNumber.indexOf('38') == 0 && cardNumber.length == 14) {
				return 'diners';
			} else {
				return 'other';
			}
		}
	}
}