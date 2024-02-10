/**
 * Version: 1.0 Alpha-1 
 * Build Date: 12-Nov-2007
 * Copyright (c) 2006-2007, Coolite Inc. (http://www.coolite.com/). All rights reserved.
 * License: Licensed under The MIT License. See license.txt and http://www.datejs.com/license/. 
 * Website: http://www.datejs.com/ or http://www.coolite.com/datejs/
 */

package cv.date {
	
	import cv.Date2;
	
	public class TimePeriod extends Date2 {
		/* 
		 * TimePeriod(startDate, endDate);
		 */
		public function TimePeriod(years, months, days, hours, minutes, seconds, milliseconds) {
			this.years = 0;
			this.months = 0;
			this.days = 0;
			this.hours = 0;
			this.minutes = 0;
			this.seconds = 0;
			this.milliseconds = 0;
			
			// startDate and endDate as arguments
			if (arguments.length == 2 && arguments[0] is Date && arguments[1] is Date) {
				
				var date1 = years.clone();
				var date2 = months.clone();
				
				var temp = date1.clone();
				var orient = (date1 > date2) ? -1 : +1;
				
				this.years = date2.getFullYear() - date1.getFullYear();
				temp.addYears(this.years);
				
				if (orient == +1) {
					if (temp > date2) {
						if (this.years !== 0) {
							this.years--;
						}
					}
				} else {
					if (temp < date2) {
						if (this.years !== 0) {
							this.years++;
						}
					}
				}
				
				date1.addYears(this.years);
				
				if (orient == +1) {
					while (date1 < date2 && date1.clone().addDays(date1.getDaysInMonth()) < date2) {
						date1.addMonths(1);
						this.months++;
					}
				} else {
					while (date1 > date2 && date1.clone().addDays(-date1.getDaysInMonth()) > date2) {
						date1.addMonths(-1);
						this.months--;
					}
				}
				
				var diff = date2 - date1;
				
				if (diff !== 0) {
					var ts = new TimeSpan(diff);
					
					this.days = ts.days;
					this.hours = ts.hours;
					this.minutes = ts.minutes;
					this.seconds = ts.seconds;
					this.milliseconds = ts.milliseconds;
				}
			}
		};
	}
};