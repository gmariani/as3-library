/**
 * Version: 1.0 Alpha-1 
 * Build Date: 13-Nov-2007
 * Copyright (c) 2006-2007, Coolite Inc. (http://www.coolite.com/). All rights reserved.
 * License: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/. 
 * Website: http://www.datejs.com/ or http://www.coolite.com/datejs/
 */

package cv {
	
	import cv.date.Grammar;
	import cv.date.Operators;
	import cv.date.TimeSpan;
	import cv.date.TimePeriod;
	import cv.date.Exception;
	import cv.date.Translator;
	
	public class Date2 {
		
		// en-US.js //
		//////////////
		
		/* Culture Name */
		public static var name:String = "en-US";
		public static var englishName:String = "English (United States)";
		public static var nativeName:String = "English (United States)";
		
		/* Day Name Strings */
		public static var dayNames:Array = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
		public static var abbreviatedDayNames:Array = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
		public static var shortestDayNames:Array = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
		public static var firstLetterDayNames:Array = ["S", "M", "T", "W", "T", "F", "S"];
		
		/* Month Name Strings */
		public static var monthNames:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
		public static var abbreviatedMonthNames:Array = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
		
		/* AM/PM Designators */
		public static var amDesignator:String = "AM";
		public static var pmDesignator:String = "PM";
		
		public static var firstDayOfWeek:uint = 0;
		public static var twoDigitYearMax:uint = 2029;
		
		/**
		 * The dateElementOrder is based on the order of the 
		 * format specifiers in the formatPatterns.DatePattern. 
		 *
		 * Example:
		 <pre>
		 shortDatePattern    dateElementOrder
		 ------------------  ---------------- 
		 "M/d/yyyy"          "mdy"
		 "dd/MM/yyyy"        "dmy"
		 "yyyy-MM-dd"        "ymd"
		 </pre>
		 * The correct dateElementOrder is required by the parser to
		 * determine the expected order of the date elements in the
		 * string being parsed.
		 * 
		 * NOTE: It is VERY important this value be correct for each Culture.
		 */
		public static var dateElementOrder:String = "mdy";
		
		/* Standard date and time format patterns */
		public static var formatPatterns:Object = {
			shortDate: "M/d/yyyy",
			longDate: "dddd, MMMM dd, yyyy",
			shortTime: "h:mm tt",
			longTime: "h:mm:ss tt",
			fullDateTime: "dddd, MMMM dd, yyyy h:mm:ss tt",
			sortableDateTime: "yyyy-MM-ddTHH:mm:ss",
			universalSortableDateTime: "yyyy-MM-dd HH:mm:ssZ",
			rfc1123: "ddd, dd MMM yyyy HH:mm:ss GMT",
			monthDay: "MMMM dd",
			yearMonth: "MMMM, yyyy"
		};
		
		/**
		 * NOTE: If a string format is not parsing correctly, but
		 * you would expect it parse, the problem likely lies below. 
		 * 
		 * The following regex patterns control most of the string matching
		 * within the parser.
		 * 
		 * The Month name and Day name patterns were automatically generated
		 * and in general should be (mostly) correct. 
		 *
		 * Beyond the month and day name patterns are natural language strings.
		 * Example: "next", "today", "months"
		 *
		 * These natural language string may NOT be correct for this culture. 
		 * If they are not correct, please translate and edit this file
		 * providing the correct regular expression pattern. 
		 *
		 * If you modify this file, please post your revised CultureInfo file
		 * to the Datejs Discussions located at
		 *     http://groups.google.com/group/date-js
		 *
		 * Please mark the subject with [CultureInfo]. Example:
		 *    Subject: [CultureInfo] Translated "da-DK" Danish(Denmark)
		 * 
		 * We will add the modified patterns to the master source files.
		 *
		 * As well, please review the list of "Future Strings" section below. 
		 */
		public static var regexPatterns:Object = {
			jan: /^jan(uary)?/i,
			feb: /^feb(ruary)?/i,
			mar: /^mar(ch)?/i,
			apr: /^apr(il)?/i,
			may: /^may/i,
			jun: /^jun(e)?/i,
			jul: /^jul(y)?/i,
			aug: /^aug(ust)?/i,
			sep: /^sep(t(ember)?)?/i,
			oct: /^oct(ober)?/i,
			nov: /^nov(ember)?/i,
			dec: /^dec(ember)?/i,

			sun: /^su(n(day)?)?/i,
			mon: /^mo(n(day)?)?/i,
			tue: /^tu(e(s(day)?)?)?/i,
			wed: /^we(d(nesday)?)?/i,
			thu: /^th(u(r(s(day)?)?)?)?/i,
			fri: /^fr(i(day)?)?/i,
			sat: /^sa(t(urday)?)?/i,

			future: /^next/i,
			past: /^last|past|prev(ious)?/i,
			add: /^(\+|after|from)/i,
			subtract: /^(\-|before|ago)/i,
			
			yesterday: /^yesterday/i,
			today: /^t(oday)?/i,
			tomorrow: /^tomorrow/i,
			now: /^n(ow)?/i,
			
			millisecond: /^ms|milli(second)?s?/i,
			second: /^sec(ond)?s?/i,
			minute: /^min(ute)?s?/i,
			hour: /^h(ou)?rs?/i,
			week: /^w(ee)?k/i,
			month: /^m(o(nth)?s?)?/i,
			day: /^d(ays?)?/i,
			year: /^y((ea)?rs?)?/i,
			
			shortMeridian: /^(a|p)/i,
			longMeridian: /^(a\.?m?\.?|p\.?m?\.?)/i,
			timezone: /^((e(s|d)t|c(s|d)t|m(s|d)t|p(s|d)t)|((gmt)?\s*(\+|\-)\s*\d\d\d\d?)|gmt)/i,
			ordinalSuffix: /^\s*(st|nd|rd|th)/i,
			timeContext: /^\s*(\:|a|p)/i
		};
		
		public static var abbreviatedTimeZoneStandard:Object = { GMT: "-000", EST: "-0400", CST: "-0500", MST: "-0600", PST: "-0700" };
		public static var abbreviatedTimeZoneDST:Object = { GMT: "-000", EDT: "-0500", CDT: "-0600", MDT: "-0700", PDT: "-0800" };
		
		// Parser //
		////////////
		
		public var _:Operators = new Operators();
		public var g:Grammar;
		public var t:Translator = new Translator();
		
		// End Parser //
		////////////////
		
		// Sugarpak //
		//////////////
		
		private var _orient:int = 1;
		private var __is:Boolean = false;
		private var _dateElement = "day";
		
		// End Sugarpak //
		//////////////////
		
		public function Date2(yearOrTimevalue:Object, month:Number, date:Number = 1, hour:Number = 0, minute:Number = 0, second:Number = 0, millisecond:Number = 0) {
			super(yearOrTimevalue, month, date, hour, minute, second, millisecond);
			
			g = new Grammar(_, t);
			
			// Parser
			var gx:Array = String("optional not ignore cache").split(/\s/);
			for (var i = 0 ; i < gx.length; i++) { 
				_[gx[i]] = _generator(_[gx[i]]); 
			}
			
			var vx:Array = String("each any all").split(/\s/);
			for (var j = 0 ; j < vx.length ; j++) { 
				_[vx[j]] = _vector(_[vx[j]]); 
			}
			
			// Sugarpak
			
			/* Do NOT modify the following string tokens. These tokens are used to build dynamic functions. */
			var dx:Array = String("sunday monday tuesday wednesday thursday friday saturday").split(/\s/);
			var mx:Array = String("january february march april may june july august september october november december").split(/\s/);
			var px:Array = String("Millisecond Second Minute Hour Day Week Month Year").split(/\s/);
			
			for (var i:uint = 0 ; i < dx.length ; i++) { 
				this[dx[i]] = this[dx[i].substring(0, 3)] = df(i);
			}
			
			for (var j:uint = 0 ; j < mx.length ; j++) { 
				this[mx[j]] = this[mx[j].substring(0, 3)] = mf(j);
			}
			
			for (var k:uint = 0 ; k < px.length ; k++) {
				var de:String = px[k].toLowerCase();
				this[de] = this[de + "s"] = ef(px[k]);
				//Number.prototype[de] = Number.prototype[de + "s"] = nf(de);
			}
		}
		
		/**
		 * Gets the month number (0-11) if given a Culture Info specific string which is a valid monthName or abbreviatedMonthName.
		 * @param {String}   The name of the month (eg. "February, "Feb", "october", "oct").
		 * @return {Number}  The day number
		 */
		public function getMonthNumberFromName(name:String):Number {
			var s:String = name.toLowerCase();
			for (var i:int = 0; i < monthNames.length; i++) {
				if (monthNames[i].toLowerCase() == s || abbreviatedMonthNames[i].toLowerCase() == s) {
					return i;
				}
			}
			return -1;
		};
		
		/**
		 * Gets the day number (0-6) if given a CultureInfo specific string which is a valid dayName, abbreviatedDayName or shortestDayName (two char).
		 * @param {String}   The name of the day (eg. "Monday, "Mon", "tuesday", "tue", "We", "we").
		 * @return {Number}  The day number
		 */
		public function getDayNumberFromName(name:String):Number {
			var s:String = name.toLowerCase();
			for (var i:int = 0; i < dayNames.length; i++) {
				if (dayNames[i].toLowerCase() == s || abbreviatedDayNames[i].toLowerCase() == s) {
					return i;
				}
			}
			return -1;
		};
		
		/**
		 * Determines if the current date instance is within a LeapYear.
		 * @param {Number}   The year (0-9999).
		 * @return {Boolean} true if date is within a LeapYear, otherwise false.
		 */
		public function isLeapYear(year:Number):Boolean {
			return (((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0));
		};
		
		/**
		 * Gets the number of days in the month, given a year and month value. Automatically corrects for LeapYear.
		 * @param {Number}   The year (0-9999).
		 * @param {Number}   The month (0-11).
		 * @return {Number}  The number of days in the month.
		 */
		public function getDaysInMonth(year:Number, month:Number):uint {
			if (!year) year = getFullYear();
			if (!month) month = getMonth();
			return [31, (isLeapYear(year) ? 29: 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
		};
		
		public function getTimezoneOffset(s:String = "", dst:Boolean = false):String {
			return (dst) ? abbreviatedTimeZoneDST[s.toUpperCase()] : abbreviatedTimeZoneStandard[s.toUpperCase()];
		};
		
		public function getTimezoneAbbreviation(offset:String, dst:Boolean = false):String {
			var n:Object = (dst) ? abbreviatedTimeZoneDST : abbreviatedTimeZoneStandard;
			for (var p:String in n) {
				if (n[p] === offset) {
					return p;
				}
			}
			return null;
		};
		
		/**
		 * Returns a new Date object that is an exact date and time copy of the original instance.
		 * @return {Date}    A new Date instance
		 */
		public function clone():Date2 {
			return new Date2(getTime());
		};
		
		/**
		 * Compares this instance to a Date object and return an number indication of their relative values.  
		 * @param {Date}     Date object to compare [Required]
		 * @return {Number}  1 = this is greaterthan date. -1 = this is lessthan date. 0 = values are equal
		 */
		public function compareTo(date:Date):int {
			return (this > date) ? 1 : (this < date) ? -1 : 0;
		};
		
		/**
		 * Compares this instance to another Date object and returns true if they are equal.  
		 * @param {Date}     Date object to compare [Required]
		 * @return {Boolean} true if dates are equal. false if they are not equal.
		 */
		public function equals(date:Date):Boolean {
			return (compareTo(date) === 0);
		};
		
		/**
		 * Determines is this instance is between a range of two dates or equal to either the start or end dates.
		 * @param {Date}     Start of range [Required]
		 * @param {Date}     End of range [Required]
		 * @return {Boolean} true is this is between or equal to the start and end dates, else false
		 */
		public function between(start:Date, end:Date):Boolean {
			var t:Number = getTime();
			return t >= start.getTime() && t <= end.getTime();
		};
		
		/**
		 * Adds the specified number of milliseconds to this instance. 
		 * @param {Number}   The number of milliseconds to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addMilliseconds(value:Number):Date {
			setMilliseconds(getMilliseconds() + value);
			return this;
		};
		
		/**
		 * Adds the specified number of seconds to this instance. 
		 * @param {Number}   The number of seconds to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addSeconds(value:Number):Date {
			return addMilliseconds(value * 1000);
		};
		
		/**
		 * Adds the specified number of seconds to this instance. 
		 * @param {Number}   The number of seconds to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addMinutes(value:Number):Date {
			return addMilliseconds(value * 60000);
		};
		
		/**
		 * Adds the specified number of hours to this instance. 
		 * @param {Number}   The number of hours to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addHours(value:Number):Date {
			return addMilliseconds(value * 3600000);
		};
		
		/**
		 * Adds the specified number of days to this instance. 
		 * @param {Number}   The number of days to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addDays(value:Number):Date {
			return addMilliseconds(value * 86400000);
		};
		
		/**
		 * Adds the specified number of weeks to this instance. 
		 * @param {Number}   The number of weeks to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addWeeks(value:Number):Date {
			return addMilliseconds(value * 604800000);
		};
		
		/**
		 * Adds the specified number of months to this instance. 
		 * @param {Number}   The number of months to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addMonths(value:Number):Date {
			var n:Number = getDate();
			setDate(1);
			setMonth(getMonth() + value);
			setDate(Math.min(n, getDaysInMonth()));
			return this;
		};
		
		/**
		 * Adds the specified number of years to this instance. 
		 * @param {Number}   The number of years to add. The number can be positive or negative [Required]
		 * @return {Date}    this
		 */
		public function addYears(value:Number):Date {
			return addMonths(value * 12);
		};
		
		/**
		 * Adds (or subtracts) to the value of the year, month, day, hour, minute, second, millisecond of the date instance using given configuration object. Positive and Negative values allowed.
		 * Example
		<pre><code>
		Date.today().add( { day: 1, month: 1 } )
		 
		new Date().add( { year: -1 } )
		</code></pre> 
		 * @param {Object}   Configuration object containing attributes (month, day, etc.)
		 * @return {Date}    this
		 */
		public function add(config:*):Date {
			if (config is Number) {
				_orient = config;
				return this;
			}
			
			var x:Object = config;
			if (x.millisecond || x.milliseconds) {
				addMilliseconds(x.millisecond || x.milliseconds);
			}
			
			if (x.second || x.seconds) {
				addSeconds(x.second || x.seconds);
			}
			
			if (x.minute || x.minutes) {
				addMinutes(x.minute || x.minutes);
			}
			
			if (x.hour || x.hours) {
				addHours(x.hour || x.hours);
			}
			
			if (x.month || x.months) {
				addMonths(x.month || x.months);
			}
			
			if (x.year || x.years) {
				addYears(x.year || x.years);
			}
			
			if (x.day || x.days) {
				addDays(x.day || x.days);
			}
			
			return this;
		};
		
		private function _validate(value:Number, min:Number, max:Number, name:String):Boolean {
			if (value < min || value > max) {
				throw new RangeError(value + " is not a valid value for " + name + ".");
			}
			return true;
		};
		
		/**
		 * Validates the number is within an acceptable range for milliseconds [0-999].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateMillisecond(n:Number):Boolean {
			return _validate(n, 0, 999, "milliseconds");
		};
		
		/**
		 * Validates the number is within an acceptable range for seconds [0-59].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateSecond(n:Number):Boolean {
			return _validate(n, 0, 59, "seconds");
		};
		
		/**
		 * Validates the number is within an acceptable range for minutes [0-59].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateMinute(n:Number):Boolean {
			return _validate(n, 0, 59, "minutes");
		};
		
		/**
		 * Validates the number is within an acceptable range for hours [0-23].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateHour(n:Number):Boolean {
			return _validate(n, 0, 23, "hours");
		};
		
		/**
		 * Validates the number is within an acceptable range for the days in a month [0-MaxDaysInMonth].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateDay(n:Number, year:Number, month:Number):Boolean {
			return _validate(n, 1, getDaysInMonth(year, month), "days");
		};
		
		/**
		 * Validates the number is within an acceptable range for months [0-11].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateMonth(n:Number):Boolean {
			return _validate(n, 0, 11, "months");
		};
		
		/**
		 * Validates the number is within an acceptable range for years [0-9999].
		 * @param {Number}   The number to check if within range.
		 * @return {Boolean} true if within range, otherwise false.
		 */
		public function validateYear(n:Number):Boolean {
			return _validate(n, 1, 9999, "seconds");
		};
		
		// Prototypes in addition to Date
		
		/**
		 * Set the value of year, month, day, hour, minute, second, millisecond of date instance using given configuration object.
		 * Example
		<pre><code>
		Date.today().set( { day: 20, month: 1 } )

		new Date().set( { millisecond: 0 } )
		</code></pre>
		 * 
		 * @param {Object}   Configuration object containing attributes (month, day, etc.)
		 * @return {Date}    this
		 */
		public function set(config:Object):Date2 {
			var x:Object = config;
			
			if (!x.millisecond && x.millisecond !== 0) {
				x.millisecond = -1;
			}
			
			if (!x.second && x.second !== 0) {
				x.second = -1;
			}
			
			if (!x.minute && x.minute !== 0) {
				x.minute = -1;
			}
			
			if (!x.hour && x.hour !== 0) {
				x.hour = -1;
			}
			
			if (!x.day && x.day !== 0) {
				x.day = -1;
			}
			
			if (!x.month && x.month !== 0) {
				x.month = -1;
			}
			
			if (!x.year && x.year !== 0) {
				x.year = -1;
			}
			
			if (x.millisecond != -1 && validateMillisecond(x.millisecond)) {
				addMilliseconds(x.millisecond - getMilliseconds());
			}
			
			if (x.second != -1 && validateSecond(x.second)) {
				addSeconds(x.second - getSeconds());
			}
			
			if (x.minute != -1 && validateMinute(x.minute)) {
				addMinutes(x.minute - getMinutes());
			}
			
			if (x.hour != -1 && validateHour(x.hour)) {
				addHours(x.hour - getHours());
			}
			
			if (x.month !== -1 && validateMonth(x.month)) {
				addMonths(x.month - getMonth());
			}
			
			if (x.year != -1 && validateYear(x.year)) {
				addYears(x.year - getFullYear());
			}
			
			/* day has to go last because you can't validate the day without first knowing the month */
			if (x.day != -1 && validateDay(x.day, getFullYear(), getMonth())) {
				addDays(x.day - getDate());
			}
			
			if (x.timezone) {
				setTimezone(x.timezone);
			}
			
			if (x.timezoneOffset) {
				setTimezoneOffset(x.timezoneOffset);
			}
			
			return this;
		};
		
		/**
		 * Resets the time of this Date object to 12:00 AM (00:00), which is the start of the day.
		 * @return {Date}    this
		 */
		public function clearTime():Date {
			setHours(0);
			setMinutes(0);
			setSeconds(0);
			setMilliseconds(0);
			return this;
		};
		
		/**
		 * Determines whether or not this instance is in a leap year.
		 * @return {Boolean} true if this instance is in a leap year, else false
		 */
		/*public function isLeapYear():Boolean {
			var y:Number = getFullYear();
			return (((y % 4 === 0) && (y % 100 !== 0)) || (y % 400 === 0));
		};*/
		
		/**
		 * Determines whether or not this instance is a weekday.
		 * @return {Boolean} true if this instance is a weekday
		 */
		public function isWeekday():Boolean {
			return !(_is().sat() || _is().sun());
		};
		
		/**
		 * Get the number of days in the current month, adjusted for leap year.
		 * @return {Number}  The number of days in the month
		 */
		/*public function getDaysInMonth():uint {
			return getDaysInMonth(getFullYear(), getMonth());
		};*/
		
		/**
		 * Moves the date to the first day of the month.
		 * @return {Date}    this
		 */
		public function moveToFirstDayOfMonth():Date {
			return set({day: 1});
		};
		
		/**
		 * Moves the date to the last day of the month.
		 * @return {Date}    this
		 */
		public function moveToLastDayOfMonth():Date {
			return set({day: getDaysInMonth()});
		};
		
		/**
		 * Move to the next or last dayOfWeek based on the orient value.
		 * @param {Number}   The dayOfWeek to move to.
		 * @param {Number}   Forward (+1) or Back (-1). Defaults to +1. [Optional]
		 * @return {Date}    this
		 */
		public function moveToDayOfWeek(day:Number, orient:Number):Date {
			var diff:Number = (day - getDay() + 7 * (orient || +1)) % 7;
			return addDays((diff === 0) ? diff += 7 * (orient || +1) : diff);
		};
		
		/**
		 * Move to the next or last month based on the orient value.
		 * @param {Number}   The month to move to. 0 = January, 11 = December.
		 * @param {Number}   Forward (+1) or Back (-1). Defaults to +1. [Optional]
		 * @return {Date}    this
		 */
		public function moveToMonth(month:Number, orient:Number):Date {
			var diff:Number = (month - getMonth() + 12 * (orient || +1)) % 12;
			return addMonths((diff === 0) ? diff += 12 * (orient || +1) : diff);
		};
		
		/**
		 * Get the numeric day number of the year, adjusted for leap year.
		 * @return {Number} 0 through 364 (365 in leap years)
		 */
		public function getDayOfYear():Number {
			return Math.floor((this - new Date(getFullYear(), 0, 1)) / 86400000);
		};
		
		/**
		 * Get the week of the year for the current date instance.
		 * @param {Number}   A Number that represents the first day of the week (0-6) [Optional]
		 * @return {Number}  0 through 53
		 */
		public function getWeekOfYear(firstDayOfWeek:Number):Number {
			var y:Number = getFullYear();
			var m:Number = getMonth();
			var d:Number = getDate();
			var dow:Number = firstDayOfWeek || firstDayOfWeek;
			var offset:Number = 7 + 1 - new Date(y, 0, 1).getDay();
			if (offset == 8) offset = 1;
			var daynum:Number = ((UTC(y, m, d, 0, 0, 0) - UTC(y, 0, 1, 0, 0, 0)) / 86400000) + 1;
			var w:Number = Math.floor((daynum - offset + 7) / 7);
			if (w === dow) {
				y--;
				var prevOffset:Number = 7 + 1 - new Date(y, 0, 1).getDay();
				if (prevOffset == 2 || prevOffset == 8) {
					w = 53;
				} else {
					w = 52;
				}
			}
			return w;
		};
		
		/**
		 * Determine whether Daylight Saving Time (DST) is in effect
		 * @return {Boolean} True if DST is in effect.
		 */
		public function isDST():Boolean {
			 /* TODO: not sure if this is portable ... get from Date.CultureInfo? */
			return toString().match(/(E|C|M|P)(S|D)T/)[2] == "D";
		};
		
		/**
		 * Get the timezone abbreviation of the current date.
		 * @return {String} The abbreviated timezone name (e.g. "EST")
		 */
		public function getTimezone():String {
			return getTimezoneAbbreviation(getUTCOffset, isDST());
		};
		
		public function setTimezoneOffset(s:String):Date2 {
			var here:String = getTimezoneOffset();
			var there:Number = Number(s) * -6 / 10;
			addMinutes(there - Number(here));
			return this;
		};
		
		public function setTimezone(s:String):Date2 {
			return setTimezoneOffset(getTimezoneOffset(s));
		};
		
		/**
		 * Get the offset from UTC of the current date.
		 * @return {String} The 4-character offset string prefixed with + or - (e.g. "-0500")
		 */
		public function getUTCOffset():String {
			var n:Number = Number(getTimezoneOffset()) * -10 / 6;
			var r:String;
			if (n < 0) {
				r = (n - 10000).toString();
				return r[0] + r.substr(2);
			} else {
				r = (n + 10000).toString();
				return "+" + r.substr(1);
			}
		};
		
		/**
		 * Gets the name of the day of the week.
		 * @param {Boolean}  true to return the abbreviated name of the day of the week
		 * @return {String}  The name of the day
		 */
		public function getDayName(abbrev:Boolean):String {
			return abbrev ? abbreviatedDayNames[getDay()] : dayNames[getDay()];
		};
		
		/**
		 * Gets the month name.
		 * @param {Boolean}  true to return the abbreviated name of the month
		 * @return {String}  The name of the month
		 */
		public function getMonthName(abbrev:Boolean):String {
			return abbrev ? abbreviatedMonthNames[getMonth()] : monthNames[getMonth()];
		};
		
		/**
		 * Converts the value of the current Date object to its equivalent string representation.
		 * Format Specifiers
		<pre>
		Format  Description                                                                  Example
		------  ---------------------------------------------------------------------------  -----------------------
		 s      The seconds of the minute between 1-59.                                      "1" to "59"
		 ss     The seconds of the minute with leading zero if required.                     "01" to "59"
		 
		 m      The minute of the hour between 0-59.                                         "1"  or "59"
		 mm     The minute of the hour with leading zero if required.                        "01" or "59"
		 
		 h      The hour of the day between 1-12.                                            "1"  to "12"
		 hh     The hour of the day with leading zero if required.                           "01" to "12"
		 
		 H      The hour of the day between 1-23.                                            "1"  to "23"
		 HH     The hour of the day with leading zero if required.                           "01" to "23"
		 
		 d      The day of the month between 1 and 31.                                       "1"  to "31"
		 dd     The day of the month with leading zero if required.                          "01" to "31"
		 ddd    Abbreviated day name. Date.CultureInfo.abbreviatedDayNames.                  "Mon" to "Sun" 
		 dddd   The full day name. Date.CultureInfo.dayNames.                                "Monday" to "Sunday"
		 
		 M      The month of the year between 1-12.                                          "1" to "12"
		 MM     The month of the year with leading zero if required.                         "01" to "12"
		 MMM    Abbreviated month name. Date.CultureInfo.abbreviatedMonthNames.              "Jan" to "Dec"
		 MMMM   The full month name. Date.CultureInfo.monthNames.                            "January" to "December"

		 yy     Displays the year as a maximum two-digit number.                             "99" or "07"
		 yyyy   Displays the full four digit year.                                           "1999" or "2007"
		 
		 t      Displays the first character of the A.M./P.M. designator.                    "A" or "P"
				Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator
		 tt     Displays the A.M./P.M. designator.                                           "AM" or "PM"
				Date.CultureInfo.amDesignator or Date.CultureInfo.pmDesignator
		</pre>
		 * @param {String}   A format string consisting of one or more format spcifiers [Optional].
		 * @return {String}  A string representation of the current Date object.
		 */
		public function toString(format:String):String {
			var self:Date2 = this;
			var p:Function = function(s:String):String {
				return (s.toString().length == 1) ? "0" + s : s;
			};
			
			return format ? format.replace(/dd?d?d?|MM?M?M?|yy?y?y?|hh?|HH?|mm?|ss?|tt?|zz?z?/g, 
			function(format:String) {
				switch (format) {
					case "hh":
						return p(self.getHours() < 13 ? self.getHours() : (self.getHours() - 12));
					case "h":
						return self.getHours() < 13 ? self.getHours() : (self.getHours() - 12);
					case "HH":
						return p(self.getHours());
					case "H":
						return self.getHours();
					case "mm":
						return p(self.getMinutes());
					case "m":
						return self.getMinutes();
					case "ss":
						return p(self.getSeconds());
					case "s":
						return self.getSeconds();
					case "yyyy":
						return self.getFullYear();
					case "yy":
						return self.getFullYear().toString().substring(2, 4);
					case "dddd":
						return self.getDayName();
					case "ddd":
						return self.getDayName(true);
					case "dd":
						return p(self.getDate());
					case "d":
						return self.getDate().toString();
					case "MMMM":
						return self.getMonthName();
					case "MMM":
						return self.getMonthName(true);
					case "MM":
						return p((self.getMonth() + 1));
					case "M":
						return self.getMonth() + 1;
					case "t":
						return self.getHours() < 12 ? amDesignator.substring(0, 1) : pmDesignator.substring(0, 1);
					case "tt":
						return self.getHours() < 12 ? amDesignator: pmDesignator;
					case "zzz":
					case "zz":
					case "z":
						return "";
				}
			}) : super.toString();
		};
		
		// Parser //
		////////////
		
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
				var r:Array = g.start.call({}, s);
			} catch (e) {
				return null;
			}
			return ((r[1].length === 0) ? r[0] : null);
		};
		
		public function getParseFunction(fx:*) {
			var fn:Function = g.formats(fx);
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
		
		// End Parser //
		////////////////
		
		// Sugarpak //
		//////////////
		
		// Create day name functions and abbreviated day name functions (eg. monday(), friday(), fri()).
		private function df(n) { 
			return function () { 
				if (this.__is) { 
					this.__is = false; 
					return this.getDay() == n; 
				}
				return this.moveToDayOfWeek(n, this._orient);
			};
		};
		
		// Create month name functions and abbreviated month name functions (eg. january(), march(), mar()).
		private function mf(n) { 
			return function () {
				if (this.__is) { 
					this.__is = false; 
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
		public function last():Date2 { return previous() };
		public function prev():Date2 { return previous() };
		public function previous():Date2 {
			_orient = -1;
			return this;
		};
		
		/** 
		 * Performs a equality check when followed by either a month name or day name function.
		 * Example
		<pre><code>
		Date.today()._is().friday(); // true|false
		Date.today()._is().fri();
		Date.today()._is().march();
		Date.today()._is().mar();
		</code></pre>
		 *  
		 * @return {bool}    true|false
		 */
		public function _is() { 
			__is = true; 
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
};