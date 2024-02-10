package cv.date {
	
	import cv.date.Operators;
	import flash.utils.Dictionary;
	import cv.Date2;

	public class Grammar {
		
		public var _:Operators = new Operators();
		public var _t:Translator = new Translator();
		public var _C:Object = new Object();
		private var hms;
		private var ss;
		private var s;
		private var mm;
		private var m;
		private var HH;
		private var H;
		private var hh;
		private var h;
		private var generalDelimiter;
		private var timePartDelimiter;
		private var datePartDelimiter;
		private var whiteSpace;
		private var t;
		private var tt;
		private var z;
		private var zz;
		private var zzz;
		private var timeSuffix;
		private var time;
		private var yyyy;
		private var yyy;
		private var yy;
		private var y;
		private var MMM;
		private var MMMM;
		private var MM;
		private var M;
		private var ddd;
		private var dd;
		private var d;
		private var dddd;
		private var day;
		private var month;
		private var year;
		private var orientation;
		private var operator;
		private var rday;
		private var unit;
		private var value;
		private var expression;
		private var _fn:Function;
		private var mdy;
		private var ymd;
		private var dmy;
		private var format:Function;
		private var _start;
		private var _formats;
		private var _F:Dictionary = new Dictionary();
		
		public function Grammer(opRef:Operators, tRef:Translator) {
			_ = opRef;
			_t = tRef;
			
			datePartDelimiter = _.rtoken(/^([\s\-\.\,\/\x27]+)/);
			timePartDelimiter = _.stoken(":");
			whiteSpace = _.rtoken(/^\s*/);
			generalDelimiter = _.rtoken(/^(([\s\,]|at|on)+)/);
			
			// hour, minute, second, meridian, timezone
			h = _.cache(_.process(_.rtoken(/^(0[0-9]|1[0-2]|[1-9])/), _t.hour));
			hh = _.cache(_.process(_.rtoken(/^(0[0-9]|1[0-2])/), _t.hour));
			H = _.cache(_.process(_.rtoken(/^([0-1][0-9]|2[0-3]|[0-9])/), _t.hour));
			HH = _.cache(_.process(_.rtoken(/^([0-1][0-9]|2[0-3])/), _t.hour));
			m = _.cache(_.process(_.rtoken(/^([0-5][0-9]|[0-9])/), _t.minute));
			mm = _.cache(_.process(_.rtoken(/^[0-5][0-9]/), _t.minute));
			s = _.cache(_.process(_.rtoken(/^([0-5][0-9]|[0-9])/), _t.second));
			ss = _.cache(_.process(_.rtoken(/^[0-5][0-9]/), _t.second));
			hms = _.cache(_.sequence([H, mm, ss], timePartDelimiter));
			
			// _.min(1, _.set([ H, m, s ], _t));
			t = _.cache(_.process(ctoken2("shortMeridian"), _t.meridian));
			tt = _.cache(_.process(ctoken2("longMeridian"), _t.meridian));
			z = _.cache(_.process(_.rtoken(/^(\+|\-)?\s*\d\d\d\d?/), _t.timezone));
			zz = _.cache(_.process(_.rtoken(/^(\+|\-)\s*\d\d\d\d/), _t.timezone));
			zzz = _.cache(_.process(ctoken2("timezone"), _t.timezone));
			timeSuffix = _.each(_.ignore(whiteSpace), _.set([ tt, zzz ]));
			time = _.each(_.optional(_.ignore(_.stoken("T"))), hms, timeSuffix);
			
			// days, months, years
			d = _.cache(_.process(_.each(_.rtoken(/^([0-2]\d|3[0-1]|\d)/), _.optional(ctoken2("ordinalSuffix"))), _t.day));
			dd = _.cache(_.process(_.each(_.rtoken(/^([0-2]\d|3[0-1])/), _.optional(ctoken2("ordinalSuffix"))), _t.day));
			ddd = dddd = _.cache(_.process(ctoken("sun mon tue wed thu fri sat"), 
				function(s:String):Function { 
					return function():void { 
						this.weekday = s; 
					}; 
				}
			));
			M = _.cache(_.process(_.rtoken(/^(1[0-2]|0\d|\d)/), _t.month));
			MM = _.cache(_.process(_.rtoken(/^(1[0-2]|0\d)/), _t.month));
			MMM = MMMM = _.cache(_.process(ctoken("jan feb mar apr may jun jul aug sep oct nov dec"), _t.month));
			y = _.cache(_.process(_.rtoken(/^(\d\d?)/), _t.year));
			yy = _.cache(_.process(_.rtoken(/^(\d\d)/), _t.year));
			yyy = _.cache(_.process(_.rtoken(/^(\d\d?\d?\d?)/), _t.year));
			yyyy = _.cache(_.process(_.rtoken(/^(\d\d\d\d)/), _t.year));
			
			// rolling these up into general purpose rules
			_fn = function() { 
				return _.each(_.any.apply(null, arguments), _.not(ctoken2("timeContext")));
			};
			
			day = _fn(d, dd); 
			month = _fn(M, MMM); 
			year = _fn(yyyy, yy);
			
			// relative date / time expressions
			orientation = _.process(ctoken("past future"), 
				function(s:String):Function { 
					return function():void { 
						this.orient = s; 
					}; 
				}
			);
			
			operator = _.process(ctoken("add subtract"), 
				function(s:String):Function { 
					return function():void { 
						this.operator = s; 
					}; 
				}
			); 
			
			rday = _.process(ctoken("yesterday tomorrow today now"), _t.rday);
			unit = _.process(ctoken("minute hour day week month year"), 
				function(s:String):Function { 
					return function():void { 
						this.unit = s; 
					}; 
				}
			);
			
			value = _.process(_.rtoken(/^\d\d?(st|nd|rd|th)?/), 
				function(s:String):Function { 
					return function():void { 
						this.value = s.replace(/\D/g, ""); 
					}; 
				}
			);
			
			expression = _.set([ rday, operator, value, unit, orientation, ddd, MMM ]);
			
			// pre-loaded rules for different date part order preferences
			_fn = function() { 
				return  _.set(arguments, datePartDelimiter); 
			};
			
			mdy = _fn(ddd, month, day, year);
			ymd = _fn(ddd, year, month, day);
			dmy = _fn(ddd, day, month, year);
			
			// parsing date format specifiers - ex: "h:m:s tt" 
			// this little guy will generate a custom parser based
			// on the format string, ex: format("h:m:s tt")
			format = _.process(_.many(
									_.any(
										// translate format specifiers into grammar rules
										_.process(
												_.rtoken(/^(dd?d?d?|MM?M?M?|yy?y?y?|hh?|HH?|mm?|ss?|tt?|zz?z?)/), 
												function(fmt:String) { 
													if (this[fmt]) { 
														return this[fmt]; 
													} else { 
														throw new Exception(fmt); 
													}
												}
										),
										// translate separator tokens into token rules
										_.process(
												_.rtoken(/^[^dMyhHmstz]+/), // all legal separators 
												function(s:String) { 
													return _.ignore(_.stoken(s)); 
												}
										)
									)), 
									// construct the parser ...
									function (rules) { 
										return _.process(_.each.apply(null, rules), _t.finishExact); 
									}
							);
			
			// check for these formats first
			_formats = formats([
								"yyyy-MM-ddTHH:mm:ss",
								"ddd, MMM dd, yyyy H:mm:ss tt",
								"ddd MMM d yyyy HH:mm:ss zzz",
								"d"
								]);
			
			_F= {
				//"M/d/yyyy": function (s) { 
				//	var m = s.match(/^([0-2]\d|3[0-1]|\d)\/(1[0-2]|0\d|\d)\/(\d\d\d\d)/);
				//	if (m!=null) { 
				//		var r =  [ _t.month.call(this,m[1]), _t.day.call(this,m[2]), _t.year.call(this,m[3]) ];
				//		r = _t.finishExac_t.call(this,r);
				//		return [ r, "" ];
				//	} else {
				//		throw new Date.Parsing.Exception(s);
				//	}
				//}
				//"M/d/yyyy": function (s) { return [ new Date(Date._parse(s)), ""]; }
			}; 
			
			// starting rule for general purpose grammar
			_start = _.process(_.set([ date, time, expression ], generalDelimiter, whiteSpace), _t.finish);
		}
		
		// real starting rule: tries selected formats first, 
		// then general purpose rule
		public function start(s) {
			try { 
				var r = _formats.call({}, s); 
				if (r[1].length === 0) {
					return r; 
				}
			} catch (e) {}
			return _start.call({}, s);
		};
		
		public function _get(f:String):Function { 
			return _F[f] = (_F[f] || format(f)[0]);
		};
		
		public function formats(fx:*):Function {
			if (fx is Array) {
				var rx:Array = []; 
				for (var i:int = 0 ; i < fx.length ; i++) {
					rx.push(_get(fx[i])); 
				}
				return _.any.apply(null, rx);
			} else { 
				return _get(fx); 
			}
		};
		
		public function date(s:String):Boolean {
			return ((this[Date2.dateElementOrder] || mdy).call(this, s));
		}
		
		public function ctoken(keys:String):Function {
			var fn:Function = _C[keys];
			if (!fn) {
				var c:Object = Date2.regexPatterns;
				var kx:Array = keys.split(/\s+/);
				var px:Array = []; 
				for (var i:int = 0; i < kx.length ; i++) {
					px.push(_.replace(_.rtoken(c[kx[i]]), kx[i]));
				}
				fn = _C[keys] = _.any.apply(null, px);
			}
			return fn;
		};
		
		public function ctoken2(key:String):Function { 
			return _.rtoken(Date2.regexPatterns[key]);
		};
	}
}