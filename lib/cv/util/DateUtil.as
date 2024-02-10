
package cv.util {
	
	import org.casalib.util.ObjectUtil;
	
	public class DateUtil {
		
		/**
		 * Returns a date into strings like "Just posted," 
		 * "6 minutes ago," "4 hours ago," or "20 days ago".
		 * 
		 * @param	d Date object to use
		 * @return The equivalent time since that date has passed in text format.
		 */
		public static function dateToTime(d:Date):String {
			var now:Date = new Date();
			var diff:Number = (now.time - d.time) / 1000; // convert to seconds
			if (diff < 60) { // just posted
				return "Just posted";
			} else if (diff < 3600) { // n minutes ago
				return (Math.round(diff / 60) + " minutes ago");
			} else if (diff < 86400) { // n hours ago
				return (Math.round(diff / 3600) + " hours ago");
			} else { // n days ago
				return (Math.round(diff / 86400) + " days ago");
			}
		}
		
		/**
			Converts milliseconds to seconds.
			
			@param milliseconds: The number of milliseconds.
			@return Returns the number of seconds.
		*/
		public static function millisecondsToSeconds(milliseconds:Number):Number {
			return milliseconds / 1000;
		}
		
		/**
			Converts milliseconds to minutes.
			
			@param milliseconds: The number of milliseconds.
			@return Returns the number of minutes.
		*/
		public static function millisecondsToMinutes(milliseconds:Number):Number {
			return DateUtil.secondsToMinutes(DateUtil.millisecondsToSeconds(milliseconds));
		}
		
		/**
			Converts milliseconds to hours.
			
			@param milliseconds: The number of milliseconds.
			@return Returns the number of hours.
		*/
		public static function millisecondsToHours(milliseconds:Number):Number {
			return DateUtil.minutesToHours(DateUtil.millisecondsToMinutes(milliseconds));
		}
		
		/**
			Converts milliseconds to days.
			
			@param milliseconds: The number of milliseconds.
			@return Returns the number of days.
		*/
		public static function millisecondsToDays(milliseconds:Number):Number {
			return DateUtil.hoursToDays(DateUtil.millisecondsToHours(milliseconds));
		}
		
		/**
			Converts seconds to milliseconds.
			
			@param seconds: The number of seconds.
			@return Returns the number of milliseconds.
		*/
		public static function secondsToMilliseconds(seconds:Number):Number {
			return seconds * 1000;
		}
		
		/**
			Converts seconds to minutes.
			
			@param seconds: The number of seconds.
			@return Returns the number of minutes.
		*/
		public static function secondsToMinutes(seconds:Number):Number {
			return seconds / 60;
		}
		
		/**
			Converts seconds to hours.
			
			@param seconds: The number of seconds.
			@return Returns the number of hours.
		*/
		public static function secondsToHours(seconds:Number):Number {
			return DateUtil.minutesToHours(DateUtil.secondsToMinutes(seconds));
		}
		
		/**
			Converts seconds to days.
			
			@param seconds: The number of seconds.
			@return Returns the number of days.
		*/
		public static function secondsToDays(seconds:Number):Number {
			return DateUtil.hoursToDays(DateUtil.secondsToHours(seconds));
		}
		
		/**
			Converts minutes to milliseconds.
			
			@param minutes: The number of minutes.
			@return Returns the number of milliseconds.
		*/
		public static function minutesToMilliseconds(minutes:Number):Number {
			return DateUtil.secondsToMilliseconds(DateUtil.minutesToSeconds(minutes));
		}
		
		/**
			Converts minutes to seconds.
			
			@param minutes: The number of minutes.
			@return Returns the number of seconds.
		*/
		public static function minutesToSeconds(minutes:Number):Number {
			return minutes * 60;
		}
		
		/**
			Converts minutes to hours.
			
			@param minutes: The number of minutes.
			@return Returns the number of hours.
		*/
		public static function minutesToHours(minutes:Number):Number {
			return minutes / 60;
		}
		
		/**
			Converts minutes to days.
			
			@param minutes: The number of minutes.
			@return Returns the number of days.
		*/
		public static function minutesToDays(minutes:Number):Number {
			return DateUtil.hoursToDays(DateUtil.minutesToHours(minutes));
		}
		
		/**
			Converts hours to milliseconds.
			
			@param hours: The number of hours.
			@return Returns the number of milliseconds.
		*/
		public static function hoursToMilliseconds(hours:Number):Number {
			return DateUtil.secondsToMilliseconds(DateUtil.hoursToSeconds(hours));
		}
		
		/**
			Converts hours to seconds.
			
			@param hours: The number of hours.
			@return Returns the number of seconds.
		*/
		public static function hoursToSeconds(hours:Number):Number {
			return DateUtil.minutesToSeconds(DateUtil.hoursToMinutes(hours));
		}
		
		/**
			Converts hours to minutes.
			
			@param hours: The number of hours.
			@return Returns the number of minutes.
		*/
		public static function hoursToMinutes(hours:Number):Number {
			return hours * 60;
		}
		
		/**
			Converts hours to days.
			
			@param hours: The number of hours.
			@return Returns the number of days.
		*/
		public static function hoursToDays(hours:Number):Number {
			return hours / 24;
		}
		
		/**
			Converts days to milliseconds.
			
			@param days: The number of days.
			@return Returns the number of milliseconds.
		*/
		public static function daysToMilliseconds(days:Number):Number {
			return DateUtil.secondsToMilliseconds(DateUtil.daysToSeconds(days));
		}
		
		/**
			Converts days to seconds.
			
			@param days: The number of days.
			@return Returns the number of seconds.
		*/
		public static function daysToSeconds(days:Number):Number {
			return DateUtil.minutesToSeconds(DateUtil.daysToMinutes(days));
		}
		
		/**
			Converts days to minutes.
			
			@param days: The number of days.
			@return Returns the number of minutes.
		*/
		public static function daysToMinutes(days:Number):Number {
			return DateUtil.hoursToMinutes(DateUtil.daysToHours(days));
		}

		/**
			Converts days to hours.
			
			@param days: The number of days.
			@return Returns the number of hours.
		*/
		public static function daysToHours(days:Number):Number {
			return days * 24;
		}
		
		/**
			Converts W3C ISO 8601 date strings into a Date object.
			
			@param iso8601: A valid ISO 8601 formatted String.
			@return Returns a Date object of the specified date and time of the ISO 8601 string in universal time.
			@see <a href="http://www.w3.org/TR/NOTE-datetime">W3C ISO 8601 specification</a>
			@example
				<code>
					trace(DateUtil.iso8601ToDate("1994-11-05T08:15:30-05:00").toString());
				</code>
		*/
		public static function iso8601ToDate(iso8601:String):Date {
			var parts:Array      = iso8601.toUpperCase().split('T');
			var date:Array       = parts[0].split('-');
			var time:Array       = parts[1].split(':');
			var year:uint        = ObjectUtil.isEmpty(date[0]) ? undefined : Number(date[0]);
			var month:uint       = ObjectUtil.isEmpty(date[1]) ? undefined : Number(date[1] - 1);
			var day:uint         = ObjectUtil.isEmpty(date[2]) ? undefined : Number(date[2]);
			var hour:uint        = ObjectUtil.isEmpty(time[0]) ? undefined : Number(time[0]);
			var minute:uint      = ObjectUtil.isEmpty(time[1]) ? undefined : Number(time[1]);
			var second:uint      = undefined;
			var millisecond:uint = undefined;
			
			if (time[2] != undefined) {
				var index:int = time[2].length;
				var temp:Number;
				if (time[2].indexOf('+') != -1) {
					index = time[2].indexOf('+');
				} else if (time[2].indexOf('-') != -1) {
					index = time[2].indexOf('-');
				} else if (time[2].indexOf('Z') != -1) {
					index = time[2].indexOf('Z');
				}
				
				if (isNaN(index)) {
					temp  = Number(time[2].slice(0, index));
					second = MathUtil.floor(temp);
					millisecond = 1000 * ((temp % 1) / 1);
				}
				
				if (index != time[2].length) {
					var offset:String = time[2].slice(index);
					var userOffset:Number = DateUtil.getDifferenceFromUTCInHours(new Date(year, month, day));
					
					switch (offset.charAt(0)) {
						case '+' :
						case '-' :
							hour -= userOffset + Number(offset.slice(0));
							break;
						case 'Z' :
							hour -= userOffset;
							break;
					}
				}
			}
			
			return new Date(year, month, day, hour, minute, second, millisecond);
		}
		
		/**
			Converts the month number into the full month name.
			
			@param month: The month number (0 for January, 1 for February, and so on).
			@return Returns a full textual representation of a month, such as January or March.
			@example
				<code>
					var myDate:Date = new Date(2000, 0, 1);
					
					trace(DateUtil.getMonthAsString(myDate.getMonth())); // Traces January
				</code>
		*/
		public static function getMonthAsString(month:Number):String {
			var monthNamesFull:Array = new Array('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
			return monthNamesFull[month];
		}
		
		/**
			Converts the month number into the month abbreviation.
			
			@param month: The month number (0 for January, 1 for February, and so on).
			@return Returns a short textual representation of a month, three letters.
			@example
				<code>
					var myDate:Date = new Date(2000, 0, 1);
					
					trace(DateUtil.getMonthAbbrAsString(myDate.getMonth())); // Traces Jan
				</code>
		*/
		public static function getMonthAbbrAsString(month:Number):String {
			return DateUtil.getMonthAsString(month).substr(0, 3);
		}
		
		/**
			Converts the day of the week number into the full day name.
			
			@param day: An integer representing the day of the week (0 for Sunday, 1 for Monday, and so on).
			@return Returns a full textual representation of the day of the week.
			@example
				<code>
					var myDate:Date = new Date(2000, 0, 1);
					
					trace(DateUtil.getDayAsString(myDate.getDay())); // Traces Saturday
				</code>
		*/
		public static function getDayAsString(day:Number):String {
			var dayNamesFull:Array = new Array('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
			return dayNamesFull[day];
		}
		
		/**
			Converts the day of the week number into the day abbreviation.
			
			@param day: An integer representing the day of the week (0 for Sunday, 1 for Monday, and so on).
			@return Returns a textual representation of a day, three letters.
			@example
				<code>
					var myDate:Date = new Date(2000, 0, 1);
					
					trace(DateUtil.getDayAbbrAsString(myDate.getDay())); // Traces Sat
				</code>
		*/
		public static function getDayAbbrAsString(day:Number):String {
			return DateUtil.getDayAsString(day).substr(0, 3);
		}
		
		/**
			Finds the number of days in the given month.
			
			@param year: The full year.
			@param month: The month number (0 for January, 1 for February, and so on).
			@return The number of days in the month; 28 through 31.
			@example
				<code>
					var myDate:Date = new Date(2000, 0, 1);
					
					trace(DateUtil.getDaysInMonth(myDate.getFullYear(), myDate.getMonth())); // Traces 31
				</code>
		*/
		public static function getDaysInMonth(year:Number, month:Number):uint {
			return (new Date(year, ++month, 0)).getDate();
		}
		
		/**
			Determines if time is Ante meridiem or Post meridiem.
			
			@param hours: The hour to find the meridiem of (an integer from 0 to 23).
			@return Returns either "AM" or "PM"
			@example
				<code>
					trace(DateUtil.getMeridiem(17)); // Traces PM
				</code>
		*/
		public static function getMeridiem(hours:Number):String {
			return (hours < 12) ? 'AM' : 'PM';
		}
		
		/**
			Determines the difference between two dates.
			
			@param startDate: The starting date.
			@param endDate: The ending date.
			@return Returns the difference in milliseconds between the two dates.
		*/
		public static function getTimeBetween(startDate:Date, endDate:Date):Number {
			return endDate.getTime() - startDate.getTime();
		}
		
		/**
			Determines the time remaining until a certain date.
			
			@param startDate: The starting date.
			@param endDate: The ending date.
			@return Returns an Object with the properties days, hours, minutes, seconds and milliseconds defined as numbers.
			@example
				<code>
					var countdown:Object = DateUtil.getCountdownUntil(new Date(2006, 11, 31, 21, 36), new Date(2007, 0, 1));
					trace("There are " + countdown.hours + " hours and " + countdown.minutes + " minutes until the new year!");
				</code>
		*/
		public static function getCountdownUntil(startDate:Date, endDate:Date):Object {
			var daysUntil:Number = DateUtil.millisecondsToDays(DateUtil.getTimeBetween(startDate, endDate));
			var hoursUntil:Number  = DateUtil.daysToHours(daysUntil % 1);
			var minsUntil:Number   = DateUtil.hoursToMinutes(hoursUntil % 1);
			var secsUntil:Number   = DateUtil.minutesToSeconds(minsUntil % 1);
			var milliUntil:Number  = DateUtil.secondsToMilliseconds(secsUntil % 1);
			
			return {
					days:         int(daysUntil),
					hours:        int(hoursUntil),
					minutes:      int(minsUntil),
					seconds:      int(secsUntil), 
					milliseconds: int(milliUntil)};
		}
		
		/**
			Determines the difference to coordinated universal time (UTC) in seconds.
			
			@param d: Date object to find the time zone offset of.
			@return Returns the difference in seconds from UTC.
		*/
		public static function getDifferenceFromUTCInSeconds(d:Date):int {
			return DateUtil.minutesToSeconds(d.getTimezoneOffset());
		}
		
		/**
			Determines the difference to coordinated universal time (UTC) in hours.
			
			@param d: Date object to find the time zone offset of.
			@return Returns the difference in hours from UTC.
		*/
		public static function getDifferenceFromUTCInHours(d:Date):int {
			return DateUtil.minutesToHours(d.getTimezoneOffset());
		}
		
		/**
			Formats the difference to coordinated undefined time (UTC).
			
			@param d: Date object to find the time zone offset of.
			@param separator: The character(s) that separates the hours from minutes.
			@return Returns the formatted time difference from UTC.
		*/
		public static function getFormattedDifferenceFromUTC(d:Date, separator:String = ""):String {
			var pre:String = (-d.getTimezoneOffset() < 0) ? '-' : '+';
			return pre + MathUtil.addLeadingZero(MathUtil.floor(DateUtil.getDifferenceFromUTCInHours(d))) + separator + MathUtil.addLeadingZero(d.getTimezoneOffset() % 60);
		}
		
		/**
			Determines the time zone of the user from a Date object.
			
			@param d: Date object to find the time zone of.
			@return Returns the time zone abbreviation.
			@example
				<code>
					trace(DateUtil.getTimezone(new Date()));
				</code>
		*/
		public static function getTimezone(d:Date):String {
			var timeZones:Array = new Array('IDLW', 'NT', 'HST', 'AKST', 'PST', 'MST', 'CST', 'EST', 'AST', 'ADT', 'AT', 'WAT', 'GMT', 'CET', 'EET', 'MSK', 'ZP4', 'ZP5', 'ZP6', 'WAST', 'WST', 'JST', 'AEST', 'AEDT', 'NZST');
			var hour:uint = Math.round(12 + -(d.getTimezoneOffset() / 60));
			if (DateUtil.isDaylightSavings(d)) hour--;
			return timeZones[hour];
		}
		
		/**
			Determines if year is a leap year or a common year.
			
			@param year: The full year.
			@return Returns true if year is a leap year; otherwise false.
			@example
				<code>
					var myDate:Date = new Date(2000, 0, 1);
					
					trace(DateUtil.isLeapYear(myDate.getFullYear())); // Traces true
				</code>
		*/
		public static function isLeapYear(year:Number):Boolean {
			return DateUtil.getDaysInMonth(year, 1) == 29;
		}
		
		/**
			Determines if or not the date is in daylight saving time.
			
			@param d: Date to find if it is during daylight savings time.
			@return Returns true if daylight savings time; otherwise false.
		*/
		public static function isDaylightSavings(d:Date):Boolean {
			var months:uint = 12;
			var offset:uint = d.getTimezoneOffset();
			var offsetCheck:Number;
			
			while (months--) {
				offsetCheck = (new Date(d.getFullYear(), months, 1)).getTimezoneOffset();
				if (offsetCheck != offset) return (offsetCheck > offset);
			}
			
			return false;
		}
		
		/**
			Gets the current day out of the total days in the year (starting from 0).
			
			@param d: Date object to find the current day of the year from.
			@return Returns the current day of the year (0-364 or 0-365 on a leap year).
		*/
		public static function getDayOfTheYear(d:Date):uint {
			var firstDay:Date = new Date(d.getFullYear(), 0, 1);
			return (d.getTime() - firstDay.getTime()) / 86400000;
		}
		
		/**
			Determines the week number of year, weeks start on Mondays.
			
			@param d: Date object to find the current week number of.
			@return Returns the the week of the year the date falls in.
		*/
		public static function getWeekOfTheYear(d:Date):uint {
			var firstDay:Date    = new Date(d.getFullYear(), 0, 1);
			var dayOffset:uint   = 9 - firstDay.getDay();
			var firstMonday:Date = new Date(d.getFullYear(), 0, (dayOffset > 7) ? dayOffset - 7 : dayOffset);
			var currentDay:Date  = new Date(d.getFullYear(), d.getMonth(), d.getDate());
			var weekNumber:uint  = (DateUtil.millisecondsToDays(currentDay.getTime() - firstMonday.getTime()) / 7) + 1;
			
			return (weekNumber == 0) ? DateUtil.getWeekOfTheYear(new Date(d.getFullYear() - 1, 11, 31)) : weekNumber;
		}
	}
}