/**
 * Version: 1.0 Alpha-1 
 * Build Date: 12-Nov-2007
 * Copyright (c) 2006-2007, Coolite Inc. (http://www.coolite.com/). All rights reserved.
 * License: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/. 
 * Website: http://www.datejs.com/ or http://www.coolite.com/datejs/
 */

package cv.date {
	
	public class TimeSpan {
		
		private var days = 0;
		private var hours = 0;
		private var minutes = 0;
		private var seconds = 0;
		private var milliseconds = 0;
		
		/* 
		 * TimeSpan(days, hours, minutes, seconds, milliseconds);
		 * TimeSpan(milliseconds);
		 */
		public function TimeSpan(days, hours, minutes, seconds, milliseconds) {
			if (arguments.length == 5) { 
				days = days; 
				hours = hours; 
				minutes = minutes; 
				seconds = seconds; 
				milliseconds = milliseconds;
			} else if (arguments.length == 1 && typeof days == "number") {
				var orient:int = (days < 0) ? -1 : +1;
				milliseconds = Math.abs(days);
				
				days = Math.floor(milliseconds / (24 * 60 * 60 * 1000)) * orient;
				milliseconds = milliseconds % (24 * 60 * 60 * 1000);
				
				hours = Math.floor(milliseconds / (60 * 60 * 1000)) * orient;
				milliseconds = milliseconds % (60 * 60 * 1000);
				
				minutes = Math.floor(milliseconds / (60 * 1000)) * orient;
				milliseconds = milliseconds % (60 * 1000);
				
				seconds = Math.floor(milliseconds / 1000) * orient;
				milliseconds = milliseconds % 1000;
				
				milliseconds = milliseconds * orient;
			}
		}
		
		public function compare(timeSpan) {
			var t1 = new Date(1970, 1, 1, this.hours(), this.minutes(), this.seconds()), t2;
			if (timeSpan === null) { 
				t2 = new Date(1970, 1, 1, 0, 0, 0); 
			} else { 
				t2 = new Date(1970, 1, 1, timeSpan.hours(), timeSpan.minutes(), timeSpan.seconds()); /* t2 = t2.addDays(timeSpan.days()); */ 
			}
			return (t1 > t2) ? 1 : (t1 < t2) ? -1 : 0;
		};
		
		public function add(timeSpan) { 
			return (timeSpan === null) ? this : this.addSeconds(timeSpan.getTotalMilliseconds() / 1000); 
		};
		
		public function subtract(timeSpan) { 
			return (timeSpan === null) ? this : this.addSeconds(-timeSpan.getTotalMilliseconds() / 1000); 
		};
		
		public function addDays(n) { 
			return new TimeSpan(this.getTotalMilliseconds() + (n * 24 * 60 * 60 * 1000)); 
		};
		
		public function addHours(n) { 
			return new TimeSpan(this.getTotalMilliseconds() + (n * 60 * 60 * 1000)); 
		};
		
		public function addMinutes(n) { 
			return new TimeSpan(this.getTotalMilliseconds() + (n * 60 * 1000)); 
		};
		
		public function addSeconds(n) {
			return new TimeSpan(this.getTotalMilliseconds() + (n * 1000)); 
		};
		
		public function addMilliseconds(n) {
			return new TimeSpan(this.getTotalMilliseconds() + n); 
		};
		
		public function getTotalMilliseconds() {
			return (this.days() * (24 * 60 * 60 * 1000)) + (this.hours() * (60 * 60 * 1000)) + (this.minutes() * (60 * 1000)) + (this.seconds() * (1000)); 
		};
		
		public function get12HourHour() {
			return ((h = this.hours() % 12) ? h : 12); 
		};
		
		public function getDesignator() { 
			return (this.hours() < 12) ? Date.CultureInfo.amDesignator : Date.CultureInfo.pmDesignator;
		};
		
		public function toString(format) {
			function _toString() {
				if (this.days() !== null && this.days() > 0) {
					return this.days() + "." + this.hours() + ":" + p(this.minutes()) + ":" + p(this.seconds());
				} else { 
					return this.hours() + ":" + p(this.minutes()) + ":" + p(this.seconds());
				}
			}
			function p(s) {
				return (s.toString().length < 2) ? "0" + s : s;
			} 
			var self = this;
			return format ? format.replace(/d|dd|HH|H|hh|h|mm|m|ss|s|tt|t/g, 
			function (format) {
				switch (format) {
				case "d":	
					return self.days();
				case "dd":	
					return p(self.days());
				case "H":	
					return self.hours();
				case "HH":	
					return p(self.hours());
				case "h":	
					return self.get12HourHour();
				case "hh":	
					return p(self.get12HourHour());
				case "m":	
					return self.minutes();
				case "mm":	
					return p(self.minutes());
				case "s":	
					return self.seconds();
				case "ss":	
					return p(self.seconds());
				case "t":	
					return ((this.hours() < 12) ? Date.CultureInfo.amDesignator : Date.CultureInfo.pmDesignator).substring(0, 1);
				case "tt":	
					return (this.hours() < 12) ? Date.CultureInfo.amDesignator : Date.CultureInfo.pmDesignator;
				}
			}
			) : this._toString();
		};
	}
};