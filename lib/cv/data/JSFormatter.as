/**
* ...
* @author Default
* @version 0.1
*/

/*
Id: beautify.php 38 2007-12-03 07:51:42Z einars

JS Beautifier

(c) 2007, Einars "elfz" Lielmanis

http://elfz.laacz.lv/beautify/

*/

package cv.data {

	public class JSFormatter {
		
		private var strTab:String;
		private var strInput:String;
		private var strOutput:String;
		private var strTokenText:String;
		private var nTokenType:int;
		private var nLastType:int; // might be int
		private var strLastText:String;
		private var nIn:int;
		private var nIndent:int;
		private var nInputLen:int;
		private var arrIn:Array;
		private var strLastWord:String;
		private var isLastNewLine:Boolean;
		private var arrWhiteSpace:Array = ["\n", "\r", "\t", " "];
		private var arrWordChar:Array = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','0','1','2','3','4','5','6','7','8','9','_','$'];
		private var arrPunct:Array = ['+','-','*','/','%','&','++','--','=','+=','-=','*=','/=','%=','==','===','!=','!==','>','<','>=','<=','>>','<<','>>>','>>>=','<<<','>>=','<<=','&&','&=','|','||','!','!!',',',':','?','^','^=','|='];
		// words which should always start on new line. 
			// simple hack for cases when lines aren't ending with semicolon.
			// feel free to tell me about the ones that need to be added. 
		private var arrLineStarters:Array = ['continue','try','throw','return','var','if','switch','case','default','for','while','break','function'];
		private var nIdx:int;
		
		private const IN_EXPR:int = 1;
		private const IN_BLOCK:int = 2;
		private const TK_UNKNOWN:int = 3;
		private const TK_WORD:int = 4;
		private const TK_START_EXPR:int = 5;
		private const TK_END_EXPR:int = 6;
		private const TK_START_BLOCK:int = 7;
		private const TK_END_BLOCK:int = 8;
		private const TK_END_COMMAND:int = 9;
		private const TK_EOF:int = 10;
		private const TK_STRING:int = 11;
		private const TK_BLOCK_COMMENT:int = 12;
		private const TK_COMMENT:int = 13;
		private const TK_OPERATOR:int = 14;

		// internal flags
		private const PRINT_NONE:int = 15;
		private const PRINT_SPACE:int = 16;
		private const PRINT_NL:int = 17;
		
		public function JSFormatter() { }
		
		public function format(strJS:String, nTabSize:int = 4):String {
			strTab = str_repeat(' ', nTabSize); 
			strInput = strJS;
			nInputLen = strInput.length;
			
			strLastWord = '';     // last TK_WORD passed
			nLastType = TK_START_EXPR; // last token type
			strLastText = '';     // last token text
			strOutput = '';
			
			isLastNewLine = true;  // was the last character written a newline?
			
			// states showing if we are currently in expression (i.e. "if" case) - IN_EXPR, or in usual block (like, procedure), IN_BLOCK.
			// some formatting depends on that.
			nIn = IN_BLOCK;
			arrIn = [nIn];
			
			nIndent = 0;
			nIdx = 0; // parser position
			var isIn_case:Boolean = false; // flag for parser that case/default has been processed, and next colon needs special attention
			var isValid:Boolean = true;
			
			while (isValid == true) {
				var arrToken:Array = get_next_token();
				strTokenText = arrToken[0];
				nTokenType = arrToken[1];
				
				if (nTokenType == TK_EOF) isValid = false;
				
				switch(nTokenType) {
					case TK_START_EXPR:
						addIn(IN_EXPR);
						if (nLastType == TK_END_EXPR || nLastType == TK_START_EXPR) {
							// do nothing on (( and )( and ][ and ]( .. 
						} else if (nLastType != TK_WORD && nLastType != TK_OPERATOR) {
							space();
						} else if (in_array(strLastWord, arrLineStarters) && strLastWord != 'function') { 
							space();
						}
						token();
						break;
					
					case TK_END_EXPR:
						token();
						in_pop();
						break;
					
					case TK_START_BLOCK:
						addIn(IN_BLOCK);
						if (nLastType != TK_OPERATOR && nLastType != TK_START_EXPR) {
							if (nLastType == TK_START_BLOCK) {
								nl();
							} else {
								space();
							}
						}
						token();
						indent();
						break;
					
					case TK_END_BLOCK:
						if (nLastType == TK_END_EXPR) {
							unindent();
							nl(false);
						} else if (nLastType == TK_END_BLOCK) {
							unindent();
							nl(false);
						} else if (nLastType == TK_START_BLOCK) {
							// nothing
							unindent();
						} else {
							unindent();
							nl(false);
						}
						token();
						in_pop();
						break;
					
					case TK_WORD:
						if (strTokenText == 'case' || strTokenText == 'default') {
							if (strLastText == ':') {
								// switch cases following one another
								remove_indent();
							} else {
								nIndent--;
								nl();
								nIndent++;
							}
							token();
							isIn_case = true;
							break;
						}
						
						var nPrefix:int = PRINT_NONE;
						if (nLastType == TK_END_BLOCK) {
							if (!in_array(strTokenText, ['else', 'catch', 'finally'])) {
								nPrefix = PRINT_NL;
							} else {
								nPrefix = PRINT_SPACE;
								space();
							}
						} else if (nLastType == TK_END_COMMAND && nIn == IN_BLOCK) {
							nPrefix = PRINT_NL;
						} else if (nLastType == TK_END_COMMAND && nIn == IN_EXPR) {
							nPrefix = PRINT_SPACE;
						} else if (nLastType == TK_WORD) {
							if (strLastWord == 'else') {
								nPrefix = PRINT_SPACE;
							} else {
								nPrefix = PRINT_SPACE; 
							}
						} else if (nLastType == TK_START_BLOCK) {
							nPrefix = PRINT_NL;
						} else if (nLastType == TK_END_EXPR) {
							space();
						}
						
						if (in_array(strTokenText, arrLineStarters) || nPrefix == PRINT_NL) {
							
							if (strLastText == 'else') {
								// no need to force newline on else break
								// DONOTHING
								space();
							} else if ((nLastType == TK_START_EXPR || strLastText == '=') && strTokenText == 'function') {
								// no need to force newline on 'function': (function
								// DONOTHING
							} else if (nLastType == TK_WORD && (strLastText == 'return' || strLastText == 'throw')) {
								// no newline between 'return nnn'
								space();
							} else
								if (nLastType != TK_END_EXPR) {
									if ((nLastType != TK_START_EXPR || strTokenText != 'var') && strLastText != ':') { 
										// no need to force newline on 'var': for (var x = 0...)
										if (strTokenText == 'if' && nLastType == TK_WORD && strLastWord == 'else') {
											// no newline for } else if {
											space();
										} else {
											nl();
										}
									}
								}
						} else if (nPrefix == PRINT_SPACE) {
							space();
						}
						token();
						strLastWord = strTokenText;
						break;
						
					case TK_END_COMMAND:
						token();
						break;
						
					case TK_STRING:
						if (nLastType == TK_START_BLOCK || nLastType == TK_END_BLOCK) {
							nl();
						} else if (nLastType == TK_WORD) {
							space();
						}
						token();
						break;
						
					case TK_OPERATOR:
						var isStartDelim:Boolean = true;
						var isEndDelim:Boolean = true;
						
						if (strTokenText == ':' && isIn_case) {
							token(); // colon really asks for separate treatment
							nl();
							break;
						}
						
						isIn_case = false;
						
						if (strTokenText == ',') {
							if (nLastType == TK_END_BLOCK) {
								token();
								nl();
							} else {
								if (nIn == IN_BLOCK) {
									token();
									nl();
								} else {
									token();
									space();
								}
							}
							break;
						} else if (strTokenText == '--' || strTokenText == '++') { // unary operators special case
							if (strLastText == ';') {
								// space for (;; ++i)  
								isStartDelim = true;
								isEndDelim = false;
							} else {                
								isStartDelim = false;
								isEndDelim = false;
							}
						} else if (strTokenText == '!' && nLastType == TK_START_EXPR) {
							// special case handling: if (!a)
							isStartDelim = false;
							isEndDelim = false;
						} else if (nLastType == TK_OPERATOR) {
							isStartDelim = false;
							isEndDelim = false;
						} else if (nLastType == TK_END_EXPR) {
							isStartDelim = true;
							isEndDelim = true;
						} else if (strTokenText == '.') {
							// decimal digits or object.property
							isStartDelim = false;
							isEndDelim   = false;
						} else if (strTokenText == ':') {
							// zz: xx
							// can't differentiate ternary op, so for now it's a ? b: c; without space before colon
							isStartDelim = false;
						}
						
						if (isStartDelim) space();
						
						token();
						
						if (isEndDelim) space();
						break;

					case TK_BLOCK_COMMENT:
						nl();
						token();
						nl();
						break;
					
					case TK_COMMENT:
						//if (nLastType != TK_COMMENT) {
						nl();
						//}
						token();
						nl();
						break;
						
					case TK_UNKNOWN:
						token();
						break;
				}
				
				if (nTokenType != TK_COMMENT) {
					nLastType = nTokenType;
					strLastText = strTokenText;
				}
			}
			
			// clean empty lines from redundant spaces
			strOutput = strOutput.replace('/^ +$/m', '');
			
			return strOutput;
		}
		
		private function in_array(item:*, arr:Array):Boolean {
			var l:uint = arr.length;
			for(var i:int = 0; i < l; i++) {
				if(arr[i] == item) return true;
			}
			return false;
		}
		
		private function nl(isIgnoreRepeated:Boolean = true):void {
			if (strOutput == '') return; // no newline on start of file
			if (isIgnoreRepeated && isLastNewLine) return;
			isLastNewLine = true;
			strOutput += "\n" + str_repeat(strTab, nIndent);
		}
		
		// hack for correct multiple newline handling 
		private function safe_nl(nNewLines:int = 1):void {
			if (nNewLines) strOutput += str_repeat("\n", nNewLines - 1);
			nl();
		}
		
		private function space():void {
			isLastNewLine = false;
			
			// prevent occassional duplicate space
			if (strOutput && strOutput.substr(-1) != ' ') strOutput += ' ';
		}
		
		private function token():void {
			strOutput += strTokenText;
			isLastNewLine = false;
		}
		
		private function indent():void {
			nIndent++;
		}
		
		private function unindent():void {
			if (nIndent) nIndent--;
		}
		
		private function remove_indent():void {
			var nTabLen:int = strTab.length;
			if (strOutput.substr(-nTabLen) == strTab) {
				strOutput = strOutput.substr(0, -nTabLen);
			}
		}
		
		private function addIn(n:int):void {
			arrIn.push(nIn);
			nIn = n;
		}
		
		private function in_pop():void {
			nIn = arrIn.pop();
		}
		
		private function get_next_token():Array {
			var nNewLines:int = 0;
			var strChar:String;
			
			do {
				if (nIdx >= nInputLen) return ['', TK_EOF];
				strChar = strInput.charAt(nIdx);
				nIdx++;
				if (strChar == "\n") nNewLines++;
			} while (in_array(strChar, arrWhiteSpace));
			
			if (nNewLines) safe_nl(nNewLines);
			
			if (in_array(strChar, arrWordChar)) {
				if (nIdx < nInputLen) {
					while (in_array(strInput.charAt(nIdx), arrWordChar)) {
						strChar += strInput.charAt(nIdx);
						nIdx++;
						if (nIdx == nInputLen) break;
					}
				}
				
				// hack for 'in' operator
				if (strChar == 'in') return [strChar, TK_OPERATOR];
				return [strChar, TK_WORD];
			}
			
			if (strChar == '(' || strChar == '[') return [strChar, TK_START_EXPR];
			if (strChar == ')' || strChar == ']') return [strChar, TK_END_EXPR];
			if (strChar == '{') return [strChar, TK_START_BLOCK];
			if (strChar == '}') return [strChar, TK_END_BLOCK];
			if (strChar == ';') return [strChar, TK_END_COMMAND];
			
			if (strChar == '/') {
				var strComment:String = '';
				
				// peek for comment /* ... */
				if (strInput.charAt(nIdx) == '*') {
					nIdx++;
					if (nIdx < nInputLen){
						while (!(strInput.charAt(nIdx) == '*' && strInput.charAt(nIdx + 1) && strInput.charAt(nIdx + 1) == '/') && nIdx < nInputLen) {
							strComment += strInput.charAt(nIdx);
							nIdx++;
							if (nIdx >= nInputLen) break;
						}
					}
					nIdx += 2;
					
					return ["/*" + strComment + "*/", TK_BLOCK_COMMENT];
				}
				
				// peek for comment // ...
				if (strInput.charAt(nIdx) == '/') {
					strComment = strChar;
					while (strInput.charAt(nIdx) != "\x0d" && strInput.charAt(nIdx) != "\x0a") {
						strComment += strInput.charAt(nIdx);
						nIdx++;
						if (nIdx >= nInputLen) break;
					}
					nIdx++;
					
					return [strComment, TK_COMMENT];
				}
			}
			
			if (strChar == "'" || // string
				strChar == '"' || // string
				(strChar == '/' && ((nLastType == TK_WORD && strLastText == 'return') || (nLastType == TK_START_EXPR || nLastType == TK_END_BLOCK || nLastType == TK_OPERATOR || nLastType == TK_EOF || nLastType == TK_END_COMMAND)))) { // regexp
				var strSep:String = strChar;
				var isEsc:Boolean = false;
				strChar = '';
				
				if (nIdx < nInputLen) {
					while (isEsc || strInput.charAt(nIdx) != strSep) {
						strChar += strInput.charAt(nIdx);
						if (!isEsc) {
							isEsc = strInput.charAt(nIdx) == '\\';
						} else {
							isEsc = false;
						}
						nIdx++;
						if (nIdx >= nInputLen) break;
					}
				}
				
				nIdx++;
				if (nLastType == TK_END_COMMAND) nl();
				return [strSep + strChar + strSep, TK_STRING];
			}
			
			if (in_array(strChar, arrPunct)) {
				while (in_array(strChar + strInput.charAt(nIdx), arrPunct)) {
					strChar += strInput.charAt(nIdx);
					nIdx++;
					if (nIdx >= nInputLen) break;
				}
				
				return [strChar, TK_OPERATOR];
			}
			
			return [strChar, TK_UNKNOWN];
		}
		
		private function str_repeat(strInput:String, nMulti:int):String {
			var strReturn:String = '';
			for(var i:int = 0; i < nMulti; i++) {
				strReturn += strInput;
			}
			return strReturn;
		}
	}
}