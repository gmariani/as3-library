/**
 * Version: 1.0 Alpha-1 
 * Build Date: 13-Nov-2007
 * Copyright (c) 2006-2007, Coolite Inc. (http://www.coolite.com/). All rights reserved.
 * License: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/. 
 * Website: http://www.datejs.com/ or http://www.coolite.com/datejs/
 */

package cv.date {
	
	import cv.date.Exception;
	
	public class Parser {
		
		public var _:Operators = new Operators();
		
		public function Parser() {
			var gx:Array = String("optional not ignore cache").split(/\s/);
			for (var i = 0 ; i < gx.length; i++) { 
				_[gx[i]] = _generator(_[gx[i]]); 
			}
			
			var vx:Array = String("each any all").split(/\s/);
			for (var j = 0 ; j < vx.length ; j++) { 
				_[vx[j]] = _vector(_[vx[j]]); 
			}
		}
		
		// Generator Operators And Vector Operators
		
		// Generators are operators that have a signature of F(R) => R,
		// taking a given rule and returning another rule, such as 
		// ignore, which parses a given rule and throws away the result.
		
		// Vector operators are those that have a signature of F(R1,R2,...) => R,
		// take a list of rules and returning a new rule, such as each.
		
		// Generator operators are converted (via the following _generator
		// function) into functions that can also take a list or array of rules
		// and return an array of new rules as though the function had been
		// called on each rule in turn (which is what actually happens).
		
		// This allows generators to be used with vector operators more easily.
		// Example:
		// each(ignore(foo, bar)) instead of each(ignore(foo), ignore(bar))
		
		// This also turns generators into vector operators, which allows
		// constructs like:
		// not(cache(foo, bar))
		
		private function _generator(op:Function):Function {
			return function():Array {
				var args:Array = null;
				var rx:Array = [];
				if (arguments.length > 1) {
					args = Array(arguments);
				} else if (arguments[0] is Array) {
					args = arguments[0];
				}
				if (args) { 
					for (var i = 0, px = args.shift() ; i < px.length ; i++) {
						args.unshift(px[i]); 
						rx.push(op.apply(null, args)); 
						args.shift();
						return rx;
					} 
				} else { 
					return op.apply(null, arguments); 
				}
			};
		};
		
		private function _vector(op:Function):Function {
			return function():* {
				if (arguments[0] is Array) { 
					return op.apply(null, arguments[0]); 
				} else { 
					return op.apply(null, arguments); 
				}
			};
		};
		
		public function flattenAndCompact(ax:Array):Array { 
			var rx:Array = []; 
			for (var i:int = 0; i < ax.length; i++) {
				if (ax[i] is Array) {
					rx = rx.concat(flattenAndCompact(ax[i]));
				} else { 
					if (ax[i]) { 
						rx.push(ax[i]); 
					}
				}
			}
			return rx;
		};
		
		//public function _parse = parse;
		
		/**
		 * Converts the specified string value into its JavaScript Date equivalent using CultureInfo specific format information.
		 * 
		 * Example
		<pre><code>
		///////////
		// Dates //
		///////////

		// 15-Oct-2004
		var d1 = Date.parse("10/15/2004");

		// 15-Oct-2004
		var d1 = Date.parse("15-Oct-2004");

		// 15-Oct-2004
		var d1 = Date.parse("2004.10.15");

		//Fri Oct 15, 2004
		var d1 = Date.parse("Fri Oct 15, 2004");

		///////////
		// Times //
		///////////

		// Today at 10 PM.
		var d1 = Date.parse("10 PM");

		// Today at 10:30 PM.
		var d1 = Date.parse("10:30 P.M.");

		// Today at 6 AM.
		var d1 = Date.parse("06am");

		/////////////////////
		// Dates and Times //
		/////////////////////

		// 8-July-2004 @ 10:30 PM
		var d1 = Date.parse("July 8th, 2004, 10:30 PM");

		// 1-July-2004 @ 10:30 PM
		var d1 = Date.parse("2004-07-01T22:30:00");

		////////////////////
		// Relative Dates //
		////////////////////

		// Returns today's date. The string "today" is culture specific.
		var d1 = Date.parse("today");

		// Returns yesterday's date. The string "yesterday" is culture specific.
		var d1 = Date.parse("yesterday");

		// Returns the date of the next thursday.
		var d1 = Date.parse("Next thursday");

		// Returns the date of the most previous monday.
		var d1 = Date.parse("last monday");

		// Returns today's day + one year.
		var d1 = Date.parse("next year");

		///////////////
		// Date Math //
		///////////////

		// Today + 2 days
		var d1 = Date.parse("t+2");

		// Today + 2 days
		var d1 = Date.parse("today + 2 days");

		// Today + 3 months
		var d1 = Date.parse("t+3m");

		// Today - 1 year
		var d1 = Date.parse("today - 1 year");

		// Today - 1 year
		var d1 = Date.parse("t-1y"); 


		/////////////////////////////
		// Partial Dates and Times //
		/////////////////////////////

		// July 15th of this year.
		var d1 = Date.parse("July 15");

		// 15th day of current day and year.
		var d1 = Date.parse("15");

		// July 1st of current year at 10pm.
		var d1 = Date.parse("7/1 10pm");
		</code></pre>
		 *
		 * @param {String}   The string value to convert into a Date object [Required]
		 * @return {Date}    A Date object or null if the string cannot be converted into a Date.
		 */
		public function parse(s:String):Date { 
			if (!s) return null;
			
			try {
				var r:Array = Grammar.start.call({}, s);
			} catch (e) {
				return null;
			}
			return ((r[1].length === 0) ? r[0] : null);
		};

		public function getParseFunction(fx:*) {
			var fn:Function = Grammar.formats(fx);
			return function(s:String):Function {
				try { 
					var r:Array = fn.call({}, s); 
				} catch (e) { 
					return null; 
				}
				return ((r[1].length === 0) ? r[0] : null);
			};
		};

		/**
		 * Converts the specified string value into its JavaScript Date equivalent using the specified format {String} or formats {Array} and the CultureInfo specific format information.
		 * The format of the string value must match one of the supplied formats exactly.
		 * 
		 * Example
		<pre><code>
		// 15-Oct-2004
		var d1 = Date.parseExact("10/15/2004", "M/d/yyyy");

		// 15-Oct-2004
		var d1 = Date.parse("15-Oct-2004", "M-ddd-yyyy");

		// 15-Oct-2004
		var d1 = Date.parse("2004.10.15", "yyyy.MM.dd");

		// Multiple formats
		var d1 = Date.parseExact("10/15/2004", [ "M/d/yyyy" , "MMMM d, yyyy" ]);
		</code></pre>
		 *
		 * @param {String}   The string value to convert into a Date object [Required].
		 * @param {Object}   The expected format {String} or an array of expected formats {Array} of the date string [Required].
		 * @return {Date}    A Date object or null if the string cannot be converted into a Date.
		 */
		public function parseExact(s:String, fx:Object) {
			return getParseFunction(fx)(s);
		};
	}
}