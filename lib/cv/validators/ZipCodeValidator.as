package cv.validators {
	
	public class ZipCodeValidator {
		
		public static const US:String = "US";
		public static const UK:String = "UK";
		public static const EU:String = "EU";
		public static const CA:String = "CA";
		
		//private var regexUK:String = "(?:(?:A[BL]|B[ABDHLNRST]?|C[ABFHMORTVW]|D[ADEGHLNTY]|E[CHNX]?|F[KY]|G[LUY]?|H[ADGPRSUX]|I[GMPV]|JE|K[ATWY]|L[ADELNSU]?|M[EKL]?|N[EGNPRW]?|O[LX]|P[AEHLOR]|R[GHM]|S[AEGKLMNOPRSTWY]?|T[ADFNQRSW]|UB|W[ACDFNRSV]?|YO|ZE)\d(?:\d|[A-Z])? \d[A-Z]{2})";
		private var regexUK:String = "(?:[A-Z]{1,2}\d(?:\d|[A-Z])? \d[A-Z]{2})";
		private var regexUS:String = "(?:\d{5}(?:-\d{4})?)";
		private var regexCA:String = "(?:[A-Z]\d[A-Z] \d[A-Z]\d)";
		//private var regexEU:String = "(?:NL-\d{4}(?: [A-Z][A-Z])|(?:IS|FO)\d{3}|(?:A|B|CH|CY|DK|EE|H|L|LT|LV|N)-\d{4}|(?:BA|DE?|E|FR?|FIN?|HR|I|SI|YU)-\d{5}|(?:CZ|GR|S|SK)-\d{3} \d{2}|PL-\d\d-\d{3}|PT-\d{4}(?:-\d{3})?)";
		private var regexEU:String = "(?:NL[- ]\d{4} [A-Z][A-Z]|(?:[A-Z]{1,2}[- ])?\d{2,3}(?:\d\d?| \d\d|\d-\d{3}))";
		
		/**
		 * Validates zip code based on country
		 *
		 * @param	strPostalCode	The postal code	 *
		 * @param	strCountry		The country you are validating the zip code against
		 * @return	Whether postal code is valid or not.
		 */
		public static function validate(strPostalCode:String, strCountryCode:String = "ALL"):Boolean {
			if (strCountryCode) {
				switch(strCountryCode) {
					case US :
						var regex:RegExp = new RegExp(regexUS);
						break;
					case UK :
						var regex:RegExp = new RegExp(regexUK);
						break;
					case CA :
						var regex:RegExp = new RegExp(regexCA);
						break;
					case EU :
						var regex:RegExp = new RegExp(regexEU);
						break;
					default :
						var regex:RegExp = new RegExp(regexUK + "|" + regexUS + "|" + regexCA + "|" + regexEU);
						break;
				}
				
				return regex.test(strPostalCode);
			} else {
				return false;
			}
		}
	}
}