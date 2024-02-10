/**
 * Version: 1.0 Alpha-1 
 * Build Date: 12-Nov-2007
 * Copyright (c) 2006-2007, Coolite Inc. (http://www.coolite.com/). All rights reserved.
 * License: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/. 
 * Website: http://www.datejs.com/ or http://www.coolite.com/datejs/
 */

package cv.util {
	
	/**
	 **************************************************************
	 ** SugarPak - Domain Specific Language -  Syntactical Sugar **
	 **************************************************************
	 */
	public class Sugarpak {
		
		protected var _orient:int = 1;
		
		// Build dynamic date element, month name and day name functions.
		public function Sugarpak() {
			var $D = Date.prototype, $N = Number.prototype;
			
			/* Do NOT modify the following string tokens. These tokens are used to build dynamic functions. */
			var dx:Array = ("sunday monday tuesday wednesday thursday friday saturday").split(/\s/);
			var mx:Array = ("january february march april may june july august september october november december").split(/\s/);
			var px:Array = ("Millisecond Second Minute Hour Day Week Month Year").split(/\s/);
			var de:String;
			
			for (var i:uint = 0 ; i < dx.length ; i++) { 
				$D[dx[i]] = $D[dx[i].substring(0, 3)] = df(i);
			}
			
			for (var j:uint = 0 ; j < mx.length ; j++) { 
				$D[mx[j]] = $D[mx[j].substring(0, 3)] = mf(j);
			}
			
			for (var k:uint = 0 ; k < px.length ; k++) {
				de = px[k].toLowerCase();
				$D[de] = $D[de + "s"] = ef(px[k]);
				$N[de] = $N[de + "s"] = nf(de);
			}
		}
		
		// Create day name functions and abbreviated day name functions (eg. monday(), friday(), fri()).
		private function df(n) { 
			return function () { 
				if (this._is) { 
					this._is = false; 
					return this.getDay() == n; 
				}
				return this.moveToDayOfWeek(n, this._orient);
			};
		};
		
		// Create month name functions and abbreviated month name functions (eg. january(), march(), mar()).
		private function mf(n) { 
			return function () {
				if (this._is) { 
					this._is = false; 
					return this.getMonth() === n; 
				}
				return this.moveToMonth(n, this._orient); 
			};
		};
		
		// Create date element functions and plural date element functions used with Number (eg. day(), days(), months()).
		private function nf(n) {
			return function () {
				this._dateElement = n;
				return this;
			};
		};
		
		// Create date element functions and plural date element functions used with Date (eg. day(), days(), months()).
		private function ef(j) { 
			return function () {
				if (j.substring(j.length - 1) != "s") { 
					j += "s"; 
				}
				return this["add" + j](this._orient); 
			};
		};
		
		/**
		 * Gets a date that is set to the current date and time. 
		 * @return {Date}    The current date and time.
		 */
		public function now() {
			return new Date();
		};
		
		/** 
		 * Gets a date that is set to the current date. The time is set to the start of the day (00:00 or 12:00 AM).
		 * @return {Date}    The current date.
		 */
		public function today() {
			return Date.now().clearTime();
		};
		
		// Prototypes of Number
		
		// private
		protected var _dateElement = "day";
		
		/** 
		 * Creates a new Date (Date.now()) and adds this (Number) to the date based on the preceding date element function (eg. second|minute|hour|day|month|year).
		 * Example
		<pre><code>
		// Undeclared Numbers must be wrapped with parentheses. Requirment of JavaScript.
		(3).days().fromNow();
		(6).months().fromNow();
		
		// Declared Number variables do not require parentheses. 
		var n = 6;
		n.months().fromNow();
		</code></pre>
		 *  
		 * @return {Date}    A new Date instance
		 */
		public function fromNow() {
			var c:Object = {};
			c[this._dateElement] = this;
			return Date.now().add(c);
		};
		
		/** 
		 * Creates a new Date (Date.now()) and subtract this (Number) from the date based on the preceding date element function (eg. second|minute|hour|day|month|year).
		 * Example
		<pre><code>
		// Undeclared Numbers must be wrapped with parentheses. Requirment of JavaScript.
		(3).days().ago();
		(6).months().ago();
		
		// Declared Number variables do not require parentheses. 
		var n = 6;
		n.months().ago();
		</code></pre>
		 *  
		 * @return {Date}    A new Date instance
		 */
		public function ago() {
			var c = {};
			c[this._dateElement] = this * -1;
			return Date.now().add(c);
		};
		
		
		// Prototypes of Date
		
		/** 
		 * Moves the date to the next instance of a date as specified by a trailing date element function (eg. .day(), .month()), month name function (eg. .january(), .jan()) or day name function (eg. .friday(), fri()).
		 * Example
		<pre><code>
		Date.today().next().friday();
		Date.today().next().fri();
		Date.today().next().march();
		Date.today().next().mar();
		Date.today().next().week();
		</code></pre>
		 * 
		 * @return {Date}    this
		 */
		public function next() {
			this._orient = +1;
			return this;
		};
		
		/** 
		 * Moves the date to the previous instance of a date as specified by a trailing date element function (eg. .day(), .month()), month name function (eg. .january(), .jan()) or day name function (eg. .friday(), fri()).
		 * Example
		<pre><code>
		Date.today().last().friday();
		Date.today().last().fri();
		Date.today().last().march();
		Date.today().last().mar();
		Date.today().last().week();
		</code></pre>
		 *  
		 * @return {Date}    this
		 */
		public function last = public function prev = public function previous = function () {
			this._orient = -1;
			return this;
		};
		
		// private
		protected var _is:Boolean = false;
		
		/** 
		 * Performs a equality check when followed by either a month name or day name function.
		 * Example
		<pre><code>
		Date.today().is().friday(); // true|false
		Date.today().is().fri();
		Date.today().is().march();
		Date.today().is().mar();
		</code></pre>
		 *  
		 * @return {bool}    true|false
		 */
		public function is() { 
			this._is = true; 
			return this; 
		}; 
		
		/**
		 * Converts the current date instance into a JSON string value.
		 * @return {String}  JSON string of date
		 */
		public function toJSONString() {
			return this.toString("yyyy-MM-ddThh:mm:ssZ");
		};
		
		/**
		 * Converts the current date instance to a string using the culture specific shortDatePattern.
		 * @return {String}  A string formatted as per the culture specific shortDatePattern
		 */
		public function toShortDateString() {
			return this.toString(Date.CultureInfo.formatPatterns.shortDatePattern);
		};
		
		/**
		 * Converts the current date instance to a string using the culture specific longDatePattern.
		 * @return {String}  A string formatted as per the culture specific longDatePattern
		 */
		public function toLongDateString() {
			return this.toString(Date.CultureInfo.formatPatterns.longDatePattern);
		};
		
		/**
		 * Converts the current date instance to a string using the culture specific shortTimePattern.
		 * @return {String}  A string formatted as per the culture specific shortTimePattern
		 */
		public function toShortTimeString() {
			return this.toString(Date.CultureInfo.formatPatterns.shortTimePattern);
		};
		
		/**
		 * Converts the current date instance to a string using the culture specific longTimePattern.
		 * @return {String}  A string formatted as per the culture specific longTimePattern
		 */
		public function toLongTimeString() {
			return this.toString(Date.CultureInfo.formatPatterns.longTimePattern);
		};
		
		/**
		 * Get the ordinal suffix of the current day.
		 * @return {String}  "st, "nd", "rd" or "th"
		 */
		public function getOrdinal() {
			switch (this.getDate()) {
				case 1: 
				case 21: 
				case 31: 
					return "st";
				case 2: 
				case 22: 
					return "nd";
				case 3: 
				case 23: 
					return "rd";
				default: 
					return "th";
			}
		};
	}
}