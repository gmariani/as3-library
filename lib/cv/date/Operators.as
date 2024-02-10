package cv.date {

	// Supposed to be a subclass of Parsing
	public dynamic class Operators {
		
		public function Operators() {}
		
		//
        // Tokenizers
        //
		
		// regex token
		public function rtoken(r:RegExp):Function {
            return function(s:String):Array {
                var mx:Array = s.match(r);
                if (mx) {
                    return ([mx[0], s.substring(mx[0].length)]);
                } else {
					throw new Exception(s);
                }
            };
        }
		
		// whitespace-eating token
		public function token(s:String):Function {
            return function(s:String):Function {
                return rtoken(new RegExp("^\s*" + s + "\s*"))(s);
            };
        }
		
		// string token
		public function stoken(s:String):Function {
            return rtoken(new RegExp("^" + s));
        }
		
		//
        // Atomic Operators
        //
		
		public function until(p:Function):Function {
            return function(s:String):Array {
                var qx:Array = [];
                var rx:Array;
                while (s.length) {
                    try {
                        rx = p.call(this, s);
                    } catch(e:Error) {
                        qx.push(rx[0]);
                        s = rx[1];
                        continue;
                    }
                    break;
                }
                return [qx, s];
            };
        }
		
		public function many(p:Function):Function {
            return function(s:String):Array {
                var rx:Array = [];
                var r:Array;
                while (s.length) {
                    try {
                        r = p.call(this, s);
                    } catch(e:Array) {
                        return [rx, s];
                    }
                    rx.push(r[0]);
                    s = r[1];
                }
                return [rx, s];
            };
        }
		
		// generator operators -- see below
		public function optional(p:Function):Function {
            return function(s:String):Array {
                var r:Array;
                try {
                    r = p.call(this, s);
                } catch(e) {
                    return [null, s];
                }
                return [r[0], r[1]];
            };
        }
		
		public function not(p:Function):Function {
            return function(s:String):Array {
                try { 
                    p.call(this, s); 
                } catch (e) { 
                    return [null, s]; 
                }
				
                throw new Exception(s);
            };
        }
		
		public function ignore(p:Function):Function {
            return p ? 
            function(s:String):Array { 
                var r:Array = p.call(this, s); 
                return [null, r[1]]; 
            } : null;
        }
		
		public function product():Array {
            var px:Array = arguments[0];
            var qx:Array = Array(arguments).slice(1); 
			var rx:Array = [];
            for (var i:int = 0 ; i < px.length; i++) {
                rx.push(each(px[i], qx));
            }
            return rx;
        }
		
		public function cache(rule:Function):Function {
            var cache:Object = { };
			var r = null; // BUG: unknown type
            return function(s:String) {
                try {
                    r = cache[s] = (cache[s] || rule.call(this, s));
                } catch (e:Error) {
                    r = cache[s] = e;
                }
                if (r is Error) {
                    throw r;
                } else {
                    return r;
                }
            };
        }
		
		// vector operators -- see below
		public function any():Function {
            var px:Array = arguments;
            return function(s:String):Function {
                var r:Function = null;
                for (var i:int = 0; i < px.length; i++) {
                    if (px[i] == null) {
                        continue;
                    }
                    try {
                        r = (px[i].call(this, s));
                    } catch (e:Error) {
                        r = null;
                    }
                    if (r) return r;
                }
				
                throw new Exception(s);
            };
        }
		
		public function each():Function {
            var px:Array = arguments;
            return function(s:String):Array {
                var rx:Array = [];
				var r:Array = null;
                for (var i:int = 0; i < px.length ; i++) {
                    if (px[i] == null) { 
                        continue; 
                    }
                    try {
                        r = (px[i].call(this, s));
                    } catch (e:Error) {
                        throw new Exception(s);
                    }
                    rx.push(r[0]);
                    s = r[1];
                }
                return [rx, s]; 
            };
        }
		
		public function all():Function {
            return each(optional(arguments)); 
        }
		
		// delimited operators
		public function sequence(px:Array, d:Function = null, c:Function = null):Function {
            d = d || rtoken(/^\s*/);  
            
            if (px.length == 1) { 
                return px[0]; 
            }
			
            return function(s:String):Array {
                var r:Array;
				var q:Array;
                var rx:Array = []; 
                for (var i:int = 0; i < px.length ; i++) {
                    try { 
                        r = px[i].call(this, s); 
                    } catch (e) { 
                        break; 
                    }
                    rx.push(r[0]);
                    try { 
                        q = d.call(this, r[1]); 
                    } catch (ex) { 
                        q = null; 
                        break; 
                    }
                    s = q[1];
                }
                if (!r) { 
                    throw new Exception(s); 
                }
                if (q) { 
                    throw new Exception(q[1]); 
                }
                if (c) {
                    try { 
                        r = c.call(this, r[1]);
                    } catch (ey) { 
                        throw new Exception(r[1]); 
                    }
                }
                return [rx, (r ? r[1] : s)];
            };
        }
		
		//
	    // Composite Operators
	    //
		
		public function between(d1:Function, p:String, d2:Function = null):Function { 
            d2 = d2 || d1; 
            var _fn:Function = each(ignore(d1), p, ignore(d2));
            return function(s:String):Array { 
                var rx:Array = _fn.call(this, s); 
                return [[rx[0][0], r[0][2]], rx[1]]; 
            };
        }
		
		public function list(p:String, d:Function, c:Function):Function {
            d = d || rtoken(/^\s*/);  
            c = c || null;
            return (p is Array ? each(product(p.slice(0, -1), ignore(d)), p.slice(-1), ignore(c)) : each(many(each(p, ignore(d))), px, ignore(c)));
        }
		
		public function set(px:Array, d:Function, c:Function):Function {
            d = d || rtoken(/^\s*/);
            c = c || null;
            
            return function(s:String):Array {
                // r is the current match, best the current 'best' match
                // which means it parsed the most amount of input
                var r:Array;
				var p:Array;
				var q:Array;
				var rx:Array;
				var best:Array = [[], s];
				var last:Boolean = false;
				
                // go through the rules in the given set
                for (var i:int = 0; i < px.length ; i++) {
					
                    // last is a flag indicating whether this must be the last element
                    // if there is only 1 element, then it MUST be the last one
                    q = null; 
                    p = null; 
                    r = null; 
                    last = (px.length == 1); 
					
                    // first, we try simply to match the current pattern
                    // if not, try the next pattern
                    try { 
                        r = px[i].call(this, s);
                    } catch (e) { 
                        continue; 
                    }
					
                    // since we are matching against a set of elements, the first
                    // thing to do is to add r[0] to matched elements
                    rx = [[r[0]], r[1]];
					
                    // if we matched and there is still input to parse and 
                    // we don't already know this is the last element,
                    // we're going to next check for the delimiter ...
                    // if there's none, or if there's no input left to parse
                    // than this must be the last element after all ...
                    if (r[1].length > 0 && !last) {
                        try { 
                            q = d.call(this, r[1]); 
                        } catch (ex) { 
                            last = true; 
                        }
                    } else { 
                        last = true; 
                    }
					
				    // if we parsed the delimiter and now there's no more input,
				    // that means we shouldn't have parsed the delimiter at all
				    // so don't update r and mark this as the last element ...
                    if (!last && q[1].length === 0) { 
                        last = true; 
                    }
					
				    // so, if this isn't the last element, we're going to see if
				    // we can get any more matches from the remaining (unmatched)
				    // elements ...
                    if (!last) {
						
                        // build a list of the remaining rules we can match against,
                        // i.e., all but the one we just matched against
                        var qx:Array = []; 
                        for (var j:int = 0; j < px.length ; j++) { 
                            if (i != j) { 
                                qx.push(px[j]); 
                            }
                        }
						
                        // now invoke recursively set with the remaining input
                        // note that we don't include the closing delimiter ...
                        // we'll check for that ourselves at the end
                        p = set(qx, d).call(this, q[1]);
						
                        // if we got a non-empty set as a result ...
                        // (otw rx already contains everything we want to match)
                        if (p[0].length > 0) {
                            // update current result, which is stored in rx ...
                            // basically, pick up the remaining text from p[1]
                            // and concat the result from p[0] so that we don't
                            // get endless nesting ...
                            rx[0] = rx[0].concat(p[0]); 
                            rx[1] = p[1]; 
                        }
                    }
					
				    // at this point, rx either contains the last matched element
				    // or the entire matched set that starts with this element.
					
				    // now we just check to see if this variation is better than
				    // our best so far, in terms of how much of the input is parsed
                    if (rx[1].length < best[1].length) { 
                        best = rx; 
                    }
					
				    // if we've parsed all the input, then we're finished
                    if (best[1].length === 0) { 
                        break; 
                    }
                }
				
			    // so now we've either gone through all the patterns trying them
			    // as the initial match; or we found one that parsed the entire
			    // input string ...
				
			    // if best has no matches, just return empty set ...
                if (best[0].length === 0) { 
                    return best; 
                }
				
			    // if a closing delimiter is provided, then we have to check it also
                if (c) {
                    // we try this even if there is no remaining input because the pattern
                    // may well be optional or match empty input ...
                    try { 
                        q = c.call(this, best[1]); 
                    } catch (ey) { 
                        throw new Exception(best[1]); 
                    }
					
                    // it parsed ... be sure to update the best match remaining input
                    best[1] = q[1];
                }
				
			    // if we're here, either there was no closing delimiter or we parsed it
			    // so now we have the best match; just return it!
                return best;
            };
        }
		
		public function forward(gr:Grammar, fname:String):Function {
            return function(s:String):* { 
                return gr[fname].call(this, s); 
            };
        }
		
		//
        // Translation Operators
        //
		
		public function replace(rule:Function, repl):Function {
            return function(s:String):Array { 
                var r:Array = rule.call(this, s); 
                return [repl, r[1]]; 
            };
        }
		
		public function process(rule:Function, fn:Function):Function {
            return function(s:String):Array {  
                var r:Array = rule.call(this, s); 
                return [fn.call(this, r[0]), r[1]]; 
            };
        }
		
		public function min(min:Number, rule):Function {
            return function(s:String):Array {
                var rx:Array = rule.call(this, s); 
                if (rx[0].length < min) { 
                    throw new Exception(s); 
                }
                return rx;
            };
        }
	}
}