/* 
	AMF0 parser, reads and writes AMF0 encoded data
    Copyright (C) 2009  Gabriel Mariani

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package cv.formats {
	
	import flash.net.getClassByAlias;
	import flash.utils.ByteArray;
	
	/*
	uint8 - BYTE - readUnsignedByte
	int8 - CHAR - readByte
	uint16 - USHORT - readUnsignedShort
	int16 - SHORT - readShort
	uint32 - ULONG - readUnsignedInt
	int32 - LONG - readInt

	readBoolean : moves position by 1
	readByte : moves position by 1
	readDouble : moves position by 8
	readFloat : moves position by 4
	readInt : moves position by 4
	readMultiByte : Reads a multibyte string of specified length from the file stream, byte stream
	readShort : moves position by 2
	readUnsignedByte : moves position by 1
	readUnsignedInt : moves position by 4
	readUnsignedShort : moves position by 2
	readUTF : reads based on assumed prefix of string length
	readUTFBytes : moves specified amount
	*/
	
	public class AMF0 {
		
		/**
		 * The maximum number of cached objects
		 */
		protected const MAX_STORED_OBJECTS:int = 1024;
		
		/**
		 * The actual object cache used to store references
		 */
		protected var objCache:Array = new Array();
		
		/**
		 * The raw binary data
		 */
		protected var _rawData:ByteArray;
		
		/**
		 * The decoded data
		 */
		protected var _data:*;
		
		protected var _amf3:AMF3 = new AMF3();
		
		public function AMF0():void { }
		
		public function get data():* { return _data; }
		
		public function get rawData():ByteArray { return _rawData; }
		
		public function get amf3():AMF3 { return _amf3; }
		
		public function deserialize(data:ByteArray):void {
			clearCache();
			_rawData = data;
			_data = readData(_rawData);
		}
		
		public function serialize(data:*):void {
			clearCache();
			_data = data;
			_rawData = new ByteArray();
			writeData(_rawData, data);
		}
		
		public function clearCache():void {
			objCache = new Array();
		}
		
		public function readData(ba:ByteArray):* {
			var type:int = ba.readByte();
			switch(type) {
				case 0x00 : return readNumber(ba); 		// Number
				case 0x01 : return readBoolean(ba); 	// Boolean
				case 0x02 : return readString(ba); 		// String
				case 0x03 : return readObject(ba); 		// Object
				case 0x04 : return null; 				// MovieClip; reserved, not supported
				case 0x05 : return null; 				// Null
				case 0x06 : return readUndefined(ba); 	// Undefined
				case 0x07 : return readReference(ba); 	// Reference
				case 0x08 : return readMixedArray(ba); 	// ECMA Array (associative)
				//case 0x09 : 							// Object End Marker
				case 0x0A : return readArray(ba); 		// Strict Array
				case 0x0B : return readDate(ba); 		// Date
				case 0x0C : return readLongString(ba); 	// Long String, string.length > 2^16
				case 0x0D : return null; 				// Unsupported
				case 0x0E : return null;				// Recordset; reserved, not supported
				case 0x0F : return readXML(ba); 		// XML Document
				case 0x10 : return readCustomClass(ba); // Typed Object (Custom Class)
				case 0x11 : return amf3.readData(ba);	// AMF3 Switch
				/*
				With the introduction of AMF 3 in Flash Player 9 to support ActionScript 3.0 and the 
				new AVM+, the AMF 0 format was extended to allow an AMF 0 encoding context to be 
				switched to AMF 3. To achieve this, a new type marker was added to AMF 0, the 
				avmplus-object-marker. The presence of this marker signifies that the following Object is 
				formatted in AMF 3.
				*/
				default: throw Error("AMF0::readData - Error : Undefined AMF0 type encountered '" + type + "'");
			}
		}
		
		protected function readNumber(ba:ByteArray):Number {
			return ba.readDouble();
		}
		
		protected function readBoolean(ba:ByteArray):Boolean {
			return ba.readBoolean();
		}
		
		protected function readString(ba:ByteArray):String {
			return ba.readUTF();
		}
		
		/**
		 * readObject reads the name/value properties of the amf message
		 */
		protected function readObject(ba:ByteArray):Object {
			var obj:Object = new Object();
			var varName:String = ba.readUTF();
			var type:int = ba.readByte();
			
			while(type != 0x09) {
				// Since readData checks type again
				ba.position--;
				
				obj[varName] = readData(ba);
				
				varName = ba.readUTF();
				type = ba.readByte();
			}
			
			objCache.push(obj);
			return obj;
		}
		
		protected function readUndefined(ba:ByteArray):* {
			return undefined;
		}
		
		/**
		 * readReference replaces the old readFlushedSO. It treats where there
		 * are references to other objects. Currently it does not resolve the
		 * object as this would involve a serious amount of overhead, unless
		 * you have a genius idea 
		 */
		protected function readReference(ba:ByteArray):Object {
			var ref:uint = ba.readUnsignedShort();
			return objCache[ref];
		}
		
		/**
		 * An ECMA Array or 'associative' Array is used when an ActionScript Array contains 
		 * non-ordinal indices. This type is considered a complex type and thus reoccurring 
		 * instances can be sent by reference. All indices, ordinal or otherwise, are treated 
		 * as string 'keys' instead of integers. For the purposes of serialization this type 
		 * is very similar to an anonymous Object.
		 */
		protected function readMixedArray(ba:ByteArray):Array {
			var arr:Array = new Array();
			
			var l:uint = ba.readUnsignedInt();
			for(var i:int = 0; i < l; i++) {
				var key:String = ba.readUTF();
				var value:* = readData(ba);
				
				arr[key] = value;
			}
			
			objCache.push(arr);
			
			// End tag 00 00 09
			ba.position += 3;
			return arr;
		}
		
		/**
		 * readArray turns an all numeric keyed actionscript array
		 */
		protected function readArray(ba:ByteArray):Array {
			var arr:Array = new Array();
			var l:uint = ba.readUnsignedInt();
			for (var i:int = 0; i < l; i++) {
				arr.push(readData(ba));
			}
			
			objCache.push(arr);
			return arr;
		}
		
		/**
		 * readDate reads a date from the amf message
		 */
		protected function readDate(ba:ByteArray):Date {
			var ms:Number = ba.readDouble();
			var timezone:int = ba.readShort(); // reserved, not supported. should be set to 0x0000
			//if (timezone > 720) timezone = -(65536 - timezone);
			//timezone *= -60;
			
			var varVal:Date = new Date();
			varVal.setTime(ms);
			
			return varVal;
		}
		
		protected function readLongString(ba:ByteArray):String {
			return ba.readUTFBytes(ba.readUnsignedInt());
		}
		
		protected function readXML(ba:ByteArray):XML {
			var strXML:String = ba.readUTFBytes(ba.readUnsignedInt());
			return new XML(strXML);
		}
		
		/**
		 * If a strongly typed object has an alias registered for its class then the type name 
		 * will also be serialized. Typed objects are considered complex types and reoccurring 
		 * instances can be sent by reference.
		 */
		protected function readCustomClass(ba:ByteArray):* {
			var classID:String = ba.readUTF();
			try {
				var obj:Object = readObject(ba);
			} catch (e:Error) {
				throw new Error("AMF0::readCustomClass - Error : Cannot parse custom class");
			}
			
			// Try to type it to the class def
			try {
				var classDef:Class = getClassByAlias(classID);
				obj = new classDef();
				obj.readExternal(ba);
			} catch (e:Error) {
				obj = readData(ba);
			}
			
			return obj;
		}
		
		/**
		 * writeData checks to see if the type was declared and then either
		 * auto negotiates the type or relies on the user defined type to
		 * serialize the data into amf
		 *
		 * Note that autoNegotiateType was eliminated in order to tame the 
		 * call stack which was getting huge and was causing leaks
		 *
		 * manualType allows the developer to explicitly set the type of
		 * the returned data.  The returned data is validated for most of the
		 * cases when possible.  Some datatypes like xml and date have to
		 * be returned this way in order for the Flash client to correctly serialize them
		 * 
		 * recordsets appears top on the list because that will probably be the most
		 * common hit in this method.  Followed by the
		 * datatypes that have to be manually set.  Then the auto negotiatable types last.
		 * The order may be changed for optimization.
		 */
		public function writeData(ba:ByteArray, value:*):void {
			// Number
			if (value is Number) {
				writeNumber(ba, value);
				return;
			}
			
			// Boolean
			if (value is Boolean) {
				writeBoolean(ba, value);
				return;
			}
			
			// String
			if (value is String) {
				writeString(ba, value);
				return;
			}
			
			// Object
			if (value is Object && getClassName(value) == "Object") {
				writeObject(ba, value);
				return;
			}
			
			// MovieClip; reserved, not supported
			
			// Null
			if (value == null) {
				writeNull(ba);
				return;
			}
			
			// Undefined
			if (value == undefined) {
				writeUndefined(ba);
				return;
			}
			
			// Reference
			// Handled by writeObject, writeArray, writeMixedArray
			
			// ECMA Array (associative)
			// Being written as an object
			
			// Object End Marker
			
			// Strict Array
			if (value is Array) {
				writeArray(ba, value);
				return;
			}
			
			// Date
			if (value is Date) {
				writeDate(ba, value);
				return;
			}
			
			// Long String, string.length > 2^16
			// Handled by writeString
			
			// Unsupported
			
			// Recordset; reserved, not supported
			
			// XML Document
			if (value is XML) {
				writeXML(ba, value);
				return;
			}
			
			// Typed Object (Custom Class)
			if (value is Object && getClassName(value) != "Object") {
				writeCustomclass(ba, value);
				return;
			}
		}
		
		/**
		 * writeNumber writes the number code (0x00) and the numeric data to the output stream
		 * All numbers passed through remoting are floats.
		 */
		protected function writeNumber(ba:ByteArray, value:Number):void {
			ba.writeByte(0); // write the number code
			ba.writeDouble(value); // write the number as a double
		}
		
		/**
		 * writeBoolean writes the boolean code (0x01) and the data to the output stream
		 */
		protected function writeBoolean(ba:ByteArray, value:Boolean):void {
			ba.writeByte(1); // write the boolean flag
			ba.writeBoolean(value); // write the boolean byte
		}
		
		/**
		 * writeString writes the string code (0x02) and the UTF8 encoded
		 * string to the output stream.
		 * Note: strings are truncated to 64k max length. Use XML as type 
		 * to send longer strings
		 */
		protected function writeString(ba:ByteArray, value:String):void {
			if (value.length < 65536) {
				ba.writeByte(0x02);
				ba.writeUTF(value);
			} else {
				writeLongString(ba, value);
			}
		}
		
		protected function writeObject(ba:ByteArray, value:Object):void {
			if (writeReferenceIfExists(ba, value)) return;
			
			ba.writeByte(0x03);
			
			for (var key:String in value) {
				ba.writeUTF(key);
				writeData(ba, value[key]);
			}
			
			ba.writeByte(0x09); // Ending marker
		}
		
		/**
		 * writeNull writes the null code (0x05) to the output stream
		 */
		protected function writeNull(ba:ByteArray):void {
			ba.writeByte(0x05); // null is only a 0x05 flag
		}
		
		/**
		 * writeNull writes the undefined code (0x06) to the output stream
		 */
		protected function writeUndefined(ba:ByteArray):void {
			ba.writeByte(0x06); // undefined is only a 0x06 flag
		}
		
		protected function writeReference(ba:ByteArray, value:int):void {
			ba.writeByte(0x07);
			writeUnsignedShort(ba, value);
		}
		
		protected function writeMixedArray(ba:ByteArray, value:Array):void {
			if (!writeReferenceIfExists(ba, value)) {
				var l:uint = value.length;
				ba.writeByte(0x08);
				ba.writeUnsignedInt(l);
				
				for (var key:String in value) {
					ba.writeUTF(key);
					writeData(ba, value[key]);
				}
				
				// End tag 00 00 09
				ba.writeByte(0x00);
				ba.writeByte(0x00);
				ba.writeByte(0x09);
			}
		}
		
		/**
		 * Write a plain numeric array without anything fancy
		 */
		protected function writeArray(ba:ByteArray, value:Array):void {
			if (!writeReferenceIfExists(ba, value)) {
				var l:uint = value.length;
				ba.writeByte(0x0A); // write the plain array code
				ba.writeInt(l); // write the count of items in the array
				for (var i:int = 0; i < l; i++) {
					writeData(ba, value[i]);
				}
			}
		}
		
		/**
		 * writeData writes the date code (0x0B) and the date value to the output stream
		 */
		protected function writeDate(ba:ByteArray, value:Date):void {
			ba.writeByte(0x0B); // write date code
			ba.writeDouble(value.time); // write date (milliseconds from 1970)
			ba.writeShort(0);// timezone reserved, not supported. should be set to 0x0000
		}
		
		protected function writeLongString(ba:ByteArray, value:String):void {
			if (value.length < 65536) {
				writeString(ba, value);
			} else {
				ba.writeByte(0x0C);
				ba.writeUTFBytes(value);
			}
		}
		
		/**
		 * writeXML writes the xml code (0x0F) and the XML string to the output stream
		 * Note: strips whitespace
		 * @param string $d The XML string
		 */
		protected function writeXML(ba:ByteArray, value:XML):void {
			if (!writeReferenceIfExists(ba, value)) {
				ba.writeByte(0x0F);
				var strXML:String = value.toXMLString();
				strXML = strXML.replace(/^\s+|\s+$/g, ''); // Trim
				//strXML = strXML.replace(/\>(\n|\r|\r\n| |\t)*\</g, "><"); // Strip whitespaces, not done by native encoder
				ba.writeUTFBytes(strXML);
			}
		}
		
		/**
		 * writePHPObject takes an instance of a class and writes the variables defined
		 * in it to the output stream.
		 * To accomplish this we just blanket grab all of the object vars with get_object_vars
		 */
		protected function writeCustomclass(ba:ByteArray, value:Object):void {
			if (writeReferenceIfExists(ba, value)) return;
			
			ba.writeByte(0x10); // write the custom class code
			
			ba.writeUTF(getClassName(value)); // write the class name
			
			writeObject(ba, value);
		}
		
		private function writeReferenceIfExists(ba:ByteArray, value:*):Boolean {
			if(objCache.length >= MAX_STORED_OBJECTS) return false;
			
			if (value is Array) {
				objCache.push("");
				return false;
			}
			
			var key:int = search(objCache, value);
			if(key != -1) {
				writeReference(ba, key);
				return true;
			} else {
				objCache.push(value);
				return false;
			}
		}
		
		/**
		 * Grab class name [class ClassName]
		 * 
		 * @param	obj
		 * @return
		 */
		private function getClassName(obj:Object):String {
			var regex:RegExp = /\[class ([^\]]+)\]/g;
			var o:Object = regex.exec(String(obj.constructor));
			return o[1]; 
		}
		
		private function writeUnsignedShort(ba:ByteArray, value:int):void {
			var b1:int = (value / 256);
			var b0:int = (value % 256);
			ba.writeByte(b0);
			ba.writeByte(b1);
		}
		
		private function search(array:Array, item:*):int {
			var i:uint = array.length;
			while (i--) {
				if(array[i] === item) return i;
			}
			return -1;
		}
	}
}