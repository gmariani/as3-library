package cv.date {
	
	public class Translator {
		
		public function hour(s):Function { 
            return function():void { 
                this.hour = Number(s); 
            }; 
        }
		
		public function minute(s):Function { 
            return function():void { 
                this.minute = Number(s); 
            }; 
        }
		
		public function second(s):Function { 
           return function():void { 
                this.second = Number(s); 
            }; 
        }
		
		public function meridian(s):Function { 
            return function():void { 
                this.meridian = s.slice(0, 1).toLowerCase(); 
            }; 
        }
		
		public function timezone(s:String):Function {
           return function():void { 
                var n:String = s.replace(/[^\d\+\-]/g, "");
                if (n.length) { 
                    this.timezoneOffset = Number(n); 
                } else { 
                    this.timezone = s.toLowerCase(); 
                }
            };
        };
		
        public function day(x:Array):Function { 
            var s:String = x[0];
            return function():void { 
                this.day = Number(s.match(/\d+/)[0]); 
            };
        };
		
        public function month(s:String):Function {
            return function():void { 
                this.month = ((s.length == 3) ? Date2.getMonthNumberFromName(s) : (Number(s) - 1));
            };
        };
		
        public function year(s:String):Function {
            return function():void { 
                var n:Number = Number(s);
                this.year = ((s.length > 2) ? n : (n + (((n + 2000) < Date2.CultureInfo.twoDigitYearMax) ? 2000 : 1900))); 
            };
        };
		
        public function rday(s:String):Function { 
            return function():void { 
                switch (s) {
					case "yesterday": 
						this.days = -1;
						break;
					case "tomorrow":  
						this.days = 1;
						break;
					case "today": 
						this.days = 0;
						break;
					case "now": 
						this.days = 0; 
						this.now = true; 
						break;
                }
            };
        };
		
        public function finishExact(x:*):Date {  
            x = (x is Array) ? x : [ x ]; 
	        
            var now:Date = new Date();
			
            this.year = now.getFullYear(); 
            this.month = now.getMonth(); 
            this.day = 1; 
			
            this.hour = 0; 
            this.minute = 0; 
            this.second = 0;
			
            for (var i:int = 0 ; i < x.length ; i++) { 
                if (x[i]) { 
                    x[i].call(this); 
                }
            } 
			
            this.hour = (this.meridian == "p" && this.hour < 13) ? this.hour + 12 : this.hour;
			
            if (this.day > Date2.getDaysInMonth(this.year, this.month)) {
                throw new RangeError(this.day + " is not a valid value for days.");
            }
			
            var r:Date = new Date(this.year, this.month, this.day, this.hour, this.minute, this.second);
			
            if (this.timezone) { 
                r.set({ timezone: this.timezone }); 
            } else if (this.timezoneOffset) { 
                r.set({ timezoneOffset: this.timezoneOffset }); 
            }
            return r;
        };
		
        public function finish(x):Date {
            x = (x is Array) ? flattenAndCompact(x) : [ x ];
			
            if (x.length === 0) { 
                return null; 
            }
			
            for (var i:int = 0 ; i < x.length ; i++) { 
                if (x[i] is Function) {
                    x[i].call(this); 
                }
            }
			
            if (this.now) { 
                return new Date(); 
            }
			
            var today = Date2.today(); 
            var method = null;
			
            var expression = !!(this.days != null || this.orient || this.operator);
            if (expression) {
                var gap, mod, orient;
                orient = ((this.orient == "past" || this.operator == "subtract") ? -1 : 1);
				
                if (this.weekday) {
                    this.unit = "day";
                    gap = (Date2.getDayNumberFromName(this.weekday) - today.getDay());
                    mod = 7;
                    this.days = gap ? ((gap + (orient * mod)) % mod) : (orient * mod);
                }
                if (this.month) {
                    this.unit = "month";
                    gap = (this.month - today.getMonth());
                    mod = 12;
                    this.months = gap ? ((gap + (orient * mod)) % mod) : (orient * mod);
                    this.month = null;
                }
                if (!this.unit) { 
                    this.unit = "day"; 
                }
                if (this[this.unit + "s"] == null || this.operator != null) {
                    if (!this.value) { 
                        this.value = 1;
                    }
					
                    if (this.unit == "week") { 
                        this.unit = "day"; 
                        this.value = this.value * 7; 
                    }
					
                    this[this.unit + "s"] = this.value * orient;
                }
                return today.add(this);
            } else {
                if (this.meridian && this.hour) {
                    this.hour = (this.hour < 13 && this.meridian == "p") ? this.hour + 12 : this.hour;			
                }
                if (this.weekday && !this.day) {
                    this.day = (today.addDays((Date2.getDayNumberFromName(this.weekday) - today.getDay()))).getDate();
                }
                if (this.month && !this.day) { 
                    this.day = 1; 
                }
                return today.set(this);
            }
        }
	}
}