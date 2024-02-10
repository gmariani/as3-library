/* 
	AMF3 parsers, reads AMF3 encoded data
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
	import flash.utils.Dictionary;
	import flash.utils.IExternalizable;
	import flash.xml.XMLDocument;
	import flash.utils.describeType;
	
	/*
	uint8 - BYTE - readUnsignedByte - U8
	int8 - CHAR - readByte
	uint16 - USHORT - readUnsignedShort - U16
	int16 - SHORT - readShort
	uint32 - ULONG - readUnsignedInt - U32
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
	
	public class AMF3 {
		
		/**
		 * The maximum number of cached objects
		 */
		protected const MAX_STORED_OBJECTS:int = 1024;
		
		/**
		 * The raw binary data
		 */
		protected var _rawData:ByteArray;
		
		/**
		 * The decoded data
		 */
		protected var _data:*;
		
		protected var objWriteCache:Dictionary = new Dictionary();
		protected var objWriteCacheLen:int = 0;
		protected var objReadCache:Array = new Array();
		
		protected var strWriteCache:Object = new Object();
		protected var strWriteCacheLen:int = 0;
		protected var strReadCache:Array = new Array();
		
		protected var defCache:Array = new Array();
		
		public function AMF3():void { }
		
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
			objWriteCache = new Dictionary();
			objWriteCacheLen = 0;
			objReadCache = new Array();
			
			strWriteCache = new Object();
			strWriteCacheLen = 0;
			strReadCache = new Array();
			
			defCache = new Array();
		}
		
		public function readData(ba:ByteArray):* {
			var type:int = ba.readByte();
			switch(type) {
				case 0x00 : return undefined;  			// Undefined
				case 0x01 : return null;				// Null
				case 0x02 : return false;				// Boolean false
				case 0x03 : return true;				// Boolean true
				case 0x04 : return readInt(ba);			// Integer
				case 0x05 : return readDouble(ba);		// Double
				case 0x06 : return readString(ba);		// String
				case 0x07 : return readXMLDoc(ba);		// XML Doc
				case 0x08 : return readDate(ba);		// Date
				case 0x09 : return readArray(ba);		// Array
				case 0x0A : return readObject(ba);		// Object
				case 0x0B : return readXML(ba); 		// XML
				case 0x0C : return readByteArray(ba); 	// Byte Array
				default: throw Error("AMF3::readData - Error : Undefined AMF3 type encountered '" + type + "'");
			}
		}
		
		/**
		 * Read and deserialize an integer
		 *
		 * AMF 3 represents smaller integers with fewer bytes using the most
		 * significant bit of each byte. The worst case uses 32-bits
		 * to represent a 29-bit number, which is what we would have
		 * done with no compression.
		 * - 0x00000000 - 0x0000007F : 0xxxxxxx
		 * - 0x00000080 - 0x00003FFF : 1xxxxxxx 0xxxxxxx
		 * - 0x00004000 - 0x001FFFFF : 1xxxxxxx 1xxxxxxx 0xxxxxxx
		 * - 0x00200000 - 0x3FFFFFFF : 1xxxxxxx 1xxxxxxx 1xxxxxxx xxxxxxxx
		 * - 0x40000000 - 0xFFFFFFFF : throw range exception
		 *
		 *
		 * 0x04 -> integer type code, followed by up to 4 bytes of data.
		 *
		 * @see:   Parsing integers on OSFlash {http://osflash.org/amf3/parsing_integers>} for the AMF3 integer data format.
		 * @return int|float
		 */
		protected function readInt(ba:ByteArray):int {
			var count:int = 0;
			var intRef:int = ba.readUnsignedByte();
			var result:int = 0;
			
			while ((intRef & 0x80) != 0 && count < 3) {
				result <<= 7;
				result |= (intRef & 0x7f);
				intRef = ba.readUnsignedByte();
				count++;
			}
			
			if (count < 3) {
				result <<= 7;
				result |= intRef;
			} else {
				// Use all 8 bits from the 4th byte
				result <<= 8;
				result |= intRef;
				
				// Check if the integer should be negative
				if ((result & 0x10000000) != 0) {
					// and extend the sign bit
					result |= 0xe0000000;
				}
			}
			
			return result;
		}
		
		protected function readDouble(ba:ByteArray):Number {
			return ba.readDouble();
		}
		
		public function readString(ba:ByteArray):String {
			var handle:int = readInt(ba);
			var str:String = "";
			
			// Is this referring to a previous string?
			if ((handle & 0x01) == 0) {
				handle = handle >> 1;
				if (handle >= strReadCache.length) {
					throw Error("AMF3::readString - Error : Undefined string reference '" + handle + "'");
					return null;
				}
				return strReadCache[handle];
			}
			
			var len:int = handle >> 1; 
			if (len > 0) {
				str = ba.readUTFBytes(len);
				strReadCache.push(str);
			}
			
			return str;
		}
		
		protected function readXMLDoc(ba:ByteArray):XMLDocument {
			var handle:int = readInt(ba);
			var xmldoc:XMLDocument = new XMLDocument();
			var inline:Boolean = ((handle & 1)  != 0 );
			handle = handle >> 1;
			
			if(inline) {
				xmldoc = new XMLDocument(ba.readUTFBytes(handle));
				objReadCache.push(xmldoc);
			} else {
				xmldoc = objReadCache[handle];
			}
			
			return xmldoc;
		}
		
		protected function readDate(ba:ByteArray):Date {
			var handle:int = readInt(ba);
			var inline:Boolean = ((handle & 1)  != 0 );
			handle >>= 1;
			
			// Is this referring to a previous date?
			if (inline) {
				var varVal:Date = new Date();
				varVal.setTime(ba.readDouble());
				objReadCache.push(varVal);
				return varVal;
	        } else {
	            if (handle >= objReadCache.length) {
					throw Error("AMF3::readDate - Error : Undefined date reference '" + handle + "'");
	                return null;
	            }
	            return objReadCache[handle];
			}
		}
		
		protected function readArray(ba:ByteArray):Array {
			var handle:int = readInt(ba);
			var inline:Boolean = ((handle & 1)  != 0 );
			handle = handle >> 1;
			
			if (inline) {
				var arr:Array = new Array();
				var strKey:String = readString(ba);
				
				while(strKey != "") {
					arr[strKey] = readData(ba);
					strKey = readString(ba);
				}
				
				for(var i:int = 0; i < handle; i++) {
					arr[i] = readData(ba);
				}
				objReadCache.push(arr);
				return arr;
			} else {
				// return previously reference array
				return objReadCache[handle];
			}
		}
		
		/**
		 * A single AMF 3 type handles ActionScript Objects and custom user classes. The term 'traits' 
		 * is used to describe the defining characteristics of a class. In addition to 'anonymous' objects 
		 * and 'typed' objects, ActionScript 3.0 introduces two further traits to describe how objects are 
		 * serialized, namely 'dynamic' and 'externalizable'.
		 * 
		 * Anonymous : an instance of the actual ActionScript Object type or an instance of a Class without 
		 * a registered alias (that will be treated like an Object on deserialization)
		 * 
		 * Typed : an instance of a Class with a registered alias
		 * 
		 * Dynamic : an instance of a Class definition with the dynamic trait declared; public variable members 
		 * can be added and removed from instances dynamically at runtime
		 * 
		 * Externalizable : an instance of a Class that implements flash.utils.IExternalizable and completely 
		 * controls the serialization of its members (no property names are included in the trait information).
		 * 
		 * @param	ba
		 * @return
		 */
		public function readObject(ba:ByteArray):Object {
			var handle:int = readInt(ba);
			var inline:Boolean = (handle & 0x01) != 0;
			handle = handle >> 1;
			var classDefinition:Object;
			var classMemberDefinitions:Array;
			
			if(inline) {
				// An inline object
				var inlineClassDef:Boolean = (handle & 0x01) != 0;
				handle = handle >> 1;
				if (inlineClassDef) {
					// Inline class-def
					var typeIdentifier:String = readString(ba);
					
					// Flags that identify the way the object is serialized/deserialized
					var externalizable:Boolean = (handle & 0x01) != 0;
					handle = handle >> 1;
					
					var isDynamic:Boolean = (handle & 0x01) != 0;
					handle = handle >> 1;
					
					var classMemberCount:int = handle;
					classMemberDefinitions = new Array();
					for(var i:int = 0; i < classMemberCount; i++) {
						classMemberDefinitions.push(readString(ba));
					}
					
					classDefinition = { type:typeIdentifier, members:classMemberDefinitions, externalizable:externalizable, dynamic:isDynamic };
					defCache.push(classDefinition);
				} else {
					// A reference to a previously passed class-def
					if (!defCache[handle]) throw new Error("AMF3::readObject - Error : Unknown Definition reference: '" + handle + "'");
					classDefinition = defCache[handle];
				}
			} else {
				// An object reference
				if (!objReadCache[handle]) throw new Error("AMF3::readObject - Error : Unknown Object reference: '" + handle + "'");
				return objReadCache[handle];
			}
			
			//Add to references as circular references may search for this object
			objReadCache.push(obj);
			
			var obj:Object = new Object();
			if (classDefinition.externalizable) {
				
				// Try to type it to the class def
				try {
					var classDef:Class = getClassByAlias(classDefinition.type);
					obj = new classDef();
					obj.readExternal(ba);
				} catch (e:Error) {
					if(classDefinition.type == 'flex.messaging.io.ArrayCollection') {
						obj = readData(ba);
					} else if(classDefinition.type == 'flex.messaging.io.ObjectProxy') {
						obj = readData(ba);
					} else {
						throw Error("AMF3::readObject - Error : Unable to read externalizable data type '" + classDefinition.type + "'");
					}
				}
			} else {
				var l:int = classDefinition.members.length;
				var key:String;
				
				for(var j:int = 0; j < l; j++) {
					var val:* = readData(ba);
					key = classDefinition.members[j];
					obj[key] = val;
				}
				
				if(classDefinition.dynamic/* && obj is ASObject*/) {
					key = readString(ba);
					while( key != "" ) {
						var value:* = readData(ba);
						obj[key] = value;
						key = readString(ba);
					}
				}
			}
			
			return obj;
		}
		
		protected function readXML(ba:ByteArray):XML {
			var handle:int = readInt(ba);
			var xml:XML = new XML();
			var inline:Boolean = ((handle & 1)  != 0 );
			handle = handle >> 1;
			
			if(inline) {
				xml = new XML(ba.readUTFBytes(handle));
				objReadCache.push(xml);
			} else {
				xml = objReadCache[handle];
			}
			
			return xml;
		}
		
		protected function readByteArray(ba:ByteArray):ByteArray {
			var handle:int = readInt(ba);
			var inline:Boolean = ((handle & 1) != 0 );
			var ba2:ByteArray;
			handle = handle >> 1;
			
			if(inline) {
				ba2 = new ByteArray();
				ba.readBytes(ba2, 0, handle);
				objReadCache.push(ba2);
			} else {
				ba2 = objReadCache[handle];
			}
			
			return ba2;
		}
		
		public function writeData(ba:ByteArray, value:*):void {
			// Undefined
			if (value == undefined) {
				writeUndefined(ba);
				return;
			}
			
			// Null
			if (value == null) {
				writeNull(ba);
				return;
			}
			
			// Boolean
			if (value is Boolean) {
				writeBoolean(ba, value);
				return;
			}
			
			// Number
			if (value is Number) {
				// Check valid range for 29bits
				if (value >= -268435456 && value <= 268435455) { 
					// int/uint
					ba.writeByte(0x04);
					writeInt(ba, value);
				} else {
					// Number
					writeDouble(ba, value);
				}
				return;
			}
			
			// String
			if (value is String) {
				ba.writeByte(0x06);
				writeString(ba, value);
				return;
			}
			
			// XML Document
			if (value is XMLDocument) {
				writeXMLDoc(ba, value);
				return;
			}
			
			// Date
			if (value is Date) {
				writeDate(ba, value);
				return;
			}
			
			// Array
			if (value is Array) {
				writeArray(ba, value);
				return;
			}
			
			// Object moved to bottom so it can be a catch-all for custom classes
			
			// XML
			if (value is XML) {
				writeXML(ba, value);
				return;
			}
			
			// Byte Array
			if (value is ByteArray) {
				writeByteArray(ba, value);
				return;
			}
			
			// Object
			if (value is Object) {
				writeObject(ba, value);
				return;
			}
		}
		
		/**
		 * The undefined type is represented by the undefined type marker. No further information is encoded for 
		 * this value.
		 * 
		 * undefined-type = undefined-marker
		 * 
		 * Note that endpoints other than the AVM may not have the concept of undefined and may choose to represent 
		 * undefined as null.
		 * 
		 * @param	ba
		 */
		protected function writeUndefined(ba:ByteArray):void {
			ba.writeByte(0x00);
		}
		
		/**
		 * The null type is represented by the null type marker. No further information is encoded for this value.
		 * 
		 * null-type = null-marker
		 * 
		 * @param	ba
		 */
		protected function writeNull(ba:ByteArray):void {
			ba.writeByte(0x01);
		}
		
		/**
		 * The false type is represented by the false type marker and is used to encode a Boolean value of false. 
		 * Note that in ActionScript 3.0 the concept of a primitive and Object form of Boolean does not exist. 
		 * No further information is encoded for this value.
		 * 
		 * false-type = false-marker
		 * 
		 * The true type is represented by the true type marker and is used to encode a Boolean value of true. 
		 * Note that in ActionScript 3.0 the concept of a primitive and Object form of Boolean does not exist. 
		 * No further information is encoded for this value.
		 * 
		 * true-type = true-marker
		 * 
		 * @param	ba
		 * @param	value
		 */
		protected function writeBoolean(ba:ByteArray, value:Boolean):void {
			ba.writeByte(value ? 0x03 : 0x02);
		}
		
		/**
		 * In AMF 3 integers are serialized using a variable length unsigned 29-bit integer. The ActionScript 3.0 
		 * integer types - a signed 'int' type and an unsigned 'uint' type - are also represented using 29-bits in 
		 * AVM+. If the value of an unsigned integer (uint) is greater or equal to 2^29 or if the value of a signed 
		 * integer (int) is greater than or equal to 2^28 then it will be represented by AVM+ as a double and thus 
		 * serialized in using the AMF 3 double type.
		 * 
		 * integer-type = integer-marker U29
		 * 
		 * @param	ba
		 * @param	value
		 */
		protected function writeInt(ba:ByteArray, value:int):void {
			// Sign contraction - the high order bit of the resulting value must match every bit removed from the number
			
			value &= 0x1FFFFFFF; // Clear 3 bits 
			
			if (value < 0x80) { // Less than 128
				ba.writeByte(value);
			} else if (value < 0x4000) { // Less than 16,384
				ba.writeByte(value >> 7 & 0x7f | 0x80);
				ba.writeByte(value & 0x7f);
			} else if (value < 0x200000) { // Less than 2,097,152
				ba.writeByte(value >> 14 & 0x7f | 0x80);
				ba.writeByte(value >> 7 & 0x7f | 0x80);
				ba.writeByte(value & 0x7f);
			} else {
				ba.writeByte(value >> 22 & 0x7f | 0x80);
				ba.writeByte(value >> 15 & 0x7f | 0x80);
				ba.writeByte(value >> 8 & 0x7f | 0x80);
				ba.writeByte(value & 0xff);
			}
		}
		
		/**
		 * The AMF 3 double type is encoded in the same manner as the AMF 0 Number type. This type is used to 
		 * encode an ActionScript Number or an ActionScript int of value greater than or equal to 2^28 or an 
		 * ActionScript uint of value greater than or equal to 2^29. The encoded value is is always an 8 byte 
		 * IEEE-754 double precision floating point value in network byte order (sign bit in low memory).
		 * 
		 * double-type = double-marker DOUBLE
		 * 
		 * @param	ba
		 * @param	value
		 */
		protected function writeDouble(ba:ByteArray, value:Number):void {
			ba.writeByte(0x05);
			ba.writeDouble(value);
		}
		
		/**
		 * ActionScript String values are represented using a single string type in AMF 3 - the concept of string 
		 * and long string types from AMF 0 is not used.
		 * 
		 * Strings can be sent as a reference to a previously occurring String by using an index to the implicit 
		 * string reference table.
		 * 
		 * Strings are encoding using UTF-8 - however the header may either describe a string literal or a string 
		 * reference.
		 * 
		 * The empty String is never sent by reference.
		 * 
		 * string-type = string-marker UTF-8-vr
		 * 
		 * @param	ba
		 * @param	value
		 */
		// TODO: Test references
		public function writeString(ba:ByteArray, value:String):void {
			// Note: Type is not encoded here becuase writeString is used for multiple types
			
			var handle:int;
			var key:int;
			
			if(value == "") {
				//Write 0x01 to specify the empty string
				ba.writeByte(0x01);
			} else {
				if (!strWriteCache[value]) {
					handle = value.length;
					if(handle < 64) strWriteCache[value] = strWriteCacheLen;
					
					writeInt(ba, handle * 2 + 1);
					ba.writeUTFBytes(value);
					strWriteCacheLen++;
				} else {
					key = strWriteCache[value];
					handle = key << 1;
					writeInt(ba, handle);
				}
			}
		}
		
		/**
		 * ActionScript 3.0 introduced a new XML type however the legacy XMLDocument type is retained in 
		 * the language as flash.xml.XMLDocument. Similar to AMF 0, the structure of an XMLDocument needs to be 
		 * flattened into a string representation for serialization. As with other strings in AMF, the content is 
		 * encoded in UTF-8.
		 * 
		 * XMLDocuments can be sent as a reference to a previously occurring XMLDocument instance by using an index 
		 * to the implicit object reference table.
		 * 
		 * U29X-value = U29. The first (low) bit is a flag with value 1. The remaining 1 to 28 significant bits are 
		 * used to encode the byte-length of the UTF-8 encoded representation of the XML or XMLDocument.
		 * 
		 * xml-doc-type = xml-doc-marker (U29O-ref | (U29X-value *(UTF8-char)))
		 * 
		 * Note that this encoding imposes some theoretical limits on the use of XMLDocument. The byte-length of each 
		 * UTF-8 encoded XMLDocument instance is limited to 2^28 - 1 bytes (approx 256 MB).
		 * 
		 * @param	ba
		 * @param	value
		 */
		protected function writeXMLDoc(ba:ByteArray, value:XMLDocument):void {
			var strXML:String = value.toString();
			strXML = strXML.replace(/^\s+|\s+$/g, ''); // Trim
			strXML = strXML.replace(/\>(\n|\r|\r\n| |\t)*\</g, "><"); // Strip whitespaces
			ba.writeByte(0x07);
			writeString(ba, strXML);
		}
		
		/**
		 * In AMF 3 an ActionScript Date is serialized simply as the number of milliseconds elapsed since the epoch 
		 * of midnight, 1st Jan 1970 in the UTC time zone. Local time zone information is not sent.
		 * 
		 * Dates can be sent as a reference to a previously occurring Date instance by using an index to the implicit 
		 * object reference table.
		 * 
		 * U29D-value = U29 ; The first (low) bit is a flag with value 1. The remaining bits are not used.
		 * 
		 * date-time = DOUBLE ; A 64-bit integer value transported as a double.
		 * 
		 * date-type = date-marker (U29O-ref | (U29D-value date-time))
		 * 
		 * @param	ba
		 * @param	value
		 */
		// TODO: Test references
		protected function writeDate(ba:ByteArray, value:Date):void {
			ba.writeByte(0x08);
			
			ba.writeByte(0x01); // Flag
			
			if (!objWriteCache[value]) {
				ba.writeDouble(value.time);
				objWriteCache[value] = objWriteCacheLen;
				objWriteCacheLen++;
			} else {
				var handle:uint = uint(objWriteCache[value]) << 1;
				writeInt(ba, handle);
			}
		}
		
		/**
		 * ActionScript Arrays are described based on the nature of their indices, i.e. their type and how they are 
		 * positioned in the Array. The following table outlines the terms and their meaning:
		 * 
		 * strict - contains only ordinal (numeric) indices 
		 * dense - ordinal indices start at 0 and do not contain gaps between successive indices (that is, every index is defined from 0 for the length of the array)
		 * sparse - contains at least one gap between two indices
		 * associative - contains at least one non-ordinal (string) index (sometimes referred to as an ECMA Array)
		 * 
		 * AMF considers Arrays in two parts, the dense portion and the associative portion. The binary representation 
		 * of the associative portion consists of name/value pairs (potentially none) terminated by an empty string. 
		 * The binary representation of the dense portion is the size of the dense portion (potentially zero) followed 
		 * by an ordered list of values (potentially none). The order these are written in AMF is first the size of 
		 * the dense portion, a empty string terminated list of name/value pairs, followed by size values.
		 * 
		 * Arrays can be sent as a reference to a previously occurring Array by using an index to the implicit object 
		 * reference table.
		 * 
		 * U29A-value = U29 ; The first (low) bit is a flag with value 1. The remaining 1 to 28 significant bits are 
		 * used to encode the count of the dense portion of the Array
		 * 
		 * assoc-value = UTF-8-vr value-type
		 * 
		 * array-type = array-marker (U29O-ref | (U29A-value (UTF-8-empty | *(assoc-value) UTF-8-empty) *(value-type)))
		 * 
		 * @param	ba
		 * @param	value
		 */
		protected function writeArray(ba:ByteArray, value:Array):void {
			//Circular referencing is disabled in arrays
			//Because if the array contains only primitive values,
			//Then === will say that the two arrays are strictly equal
			//if they contain the same values, even if they are really distinct
			//if(($key = patched_array_search($d, $this->storedObjects, TRUE)) === FALSE )
			//{
				/*if(count($this->storedObjects) < MAX_STORED_OBJECTS)
				{
					$this->storedObjects[] = & $d;
				}*/
				
				var arrNumeric:Array = new Array(); // holder to store the numeric keys
				var objString:Object = new Object(); // holder to store the string keys
				var l:uint = value.length; // get the total number of entries for the array
				var numElements:int = 0;
				var key:*;
				var i:int;
				var isSparse:Boolean = false;
				var isAssociative:Boolean = false;
				
				// Find the numeric and string key values
				var strLen:uint = 0;
				for (key in value) {
					numElements++;
					if (key is Number && key >= 0) { // make sure the keys are numeric
						arrNumeric[key] = value[key]; // The key is an index in an array
					} else {
						objString[key] = value[key]; // The key is a property of an object
						strLen++;
					}
				}
				
				// Spare arrays will have a different number of actual items but length reports different
				isSparse = Boolean(numElements < l);
				isAssociative = Boolean(strLen > 0);
				
				// Array tag
				ba.writeByte(0x09); 
				
				// This is a mixed array
				if (isAssociative || isSparse) {
					// Dynamic object, no classname to write
					ba.writeByte(0x01);
					
					for (key in value) {
						writeString(ba, key);
						writeData(ba, value[key]);
					}
					
					// Since this is a dynamic object, add closing tag
					ba.writeByte(0x01);
				}
				
				// This is just an array
				else {
					var numLen:uint = arrNumeric.length; 
					writeInt(ba, numLen * 2 + 1);
					
					for (key in objString) {
						writeString(ba, key);
						writeData(ba, objString[key]);
					}
					writeString(ba, ""); // End start hash
					
					for (i = 0; i < numLen; i++) {
						writeData(ba, arrNumeric[i]);
					}
				}
			//}
			//else
			//{
			//	$handle = $key << 1;
			//	$this->outBuffer .= "\11";
			//	$this->writeAmf3Int($handle);
			//}
		}
		
		/**
		 * A single AMF 3 type handles ActionScript Objects and custom user classes. The term 'traits' is used to describe 
		 * the defining characteristics of a class. In addition to 'anonymous' objects and 'typed' objects, ActionScript 3.0 
		 * introduces two further traits to describe how objects are serialized, namely 'dynamic' and 'externalizable'. The 
		 * following table outlines the terms and their meanings:
		 * 
		 * Anonymous - an instance of the actual ActionScript Object type or an instance of a Class without a registered alias 
		 * 				(that will be treated like an Object on deserialization)
		 * 
		 * Typed - an instance of a Class with a registered alias
		 * 
		 * Dynamic - an instance of a Class definition with the dynamic trait declared; public variable members can be added 
		 * 			 and removed from instances dynamically at runtime
		 * 
		 * Externalizable - an instance of a Class that implements flash.utils.IExternalizable and completely controls the 
		 * 					serialization of its members (no property names are included in the trait information).
		 * 
		 * In addition to these characteristics, an object's traits information may also include a set of public variable and 
		 * public read-writeable property names defined on a Class (i.e. public members that are not Functions). The order of 
		 * the member names is important as the member values that follow the traits information will be in the exact same order. 
		 * These members are considered sealed members as they are explicitly defined by the type.
		 * 
		 * If the type is dynamic, a further section may be included after the sealed members that lists dynamic members as 
		 * name / value pairs. One continues to read in dynamic members until a name that is the empty string is encountered.
		 * 
		 * Objects can be sent as a reference to a previously occurring Object by using an index to the implicit object reference 
		 * table. Further more, trait information can also be sent as a reference to a previously occurring set of traits by using 
		 * an index to the implicit traits reference table.
		 * 
		 * U29O-ref = U29 ; The first (low) bit is a flag (representing whether an instance follows) with value 0 to imply that 
		 * 					this is not an instance but a reference. The remaining 1 to 28 significant bits are used to encode 
		 * 					an object reference index (an integer).
		 * 
		 * U29O-traits-ref = U29 ; The first (low) bit is a flag with value 1. The second bit is a flag (representing whether a 
		 * 					trait reference follows) with value 0 to imply that this objects traits are being sent by reference. The remaining 1 
		 * 					to 27 significant bits are used to encode a trait reference index (an integer).
		 * 
		 * U29O-traits-ext = U29 ; The first (low) bit is a flag with value 1. The second bit is a flag with value 1. The third bit 
		 * 					is a flag with value 1. The remaining 1 to 26 significant bits are not significant (the traits member count would always be 0).
		 * 
		 * U29O-traits = U29 ; The first (low) bit is a flag with value 1. The second bit is a flag with value 1. The third bit is a 
		 * 					flag with value 0. The fourth bit is a flag specifying whether the type is dynamic. A value of 0 implies not dynamic, a value 
		 * 					of 1 implies dynamic. Dynamic types may have a set of name value pairs for dynamic members after the sealed member section. 
		 * 					The remaining 1 to 25 significant bits are used to encode the number of sealed traits member names that follow after the class 
		 * 					name (an integer).
		 * 
		 * class-name = UTF-8-vr ; use the empty string for anonymous classes
		 * 
		 * dynamic-member = UTF-8-vr value-type ; Another dynamic member follows until the string-type is the empty string
		 * 
		 * object-type = object-marker (U29O-ref | (U29O-traits-ext class-name *(U8)) | U29O-traits-ref | (U29O-traits class-name *(UTF-8-vr))) *(value-type) *(dynamic-member)))
		 * 
		 * @param	ba
		 * @param	value
		 */
		// TODO: Test references
		// See if object exists in our object cache, in PHP storedObjects is an array
		protected function writeObject(ba:ByteArray, value:Object):void {
			var key:int = search(objWriteCache, value);
			var isRef:Boolean = (key != -1);
			var desc:XML = describeType(value);
			
			// Write the object tag
			ba.writeByte(0x0A); 
			
			// Write Trait/Ref tag, 29 bits total of 32?
			var isTraitRef:Boolean = false;
			var traitRef:uint = 0;
			// First Bit is a flag to determine if this is a reference
			if (!isRef) {
				//trace("Is not a reference");
				traitRef |= 0x01; // 1
				
				if (isTraitRef) {
					//trace("Is a trait reference");
					traitRef &= ~0x02; // 0
					traitRef |= key << 2; // Encode trait reference index integer with remaining 1-27 bits
				} else {
					//trace("Is not a trait reference");
					traitRef |= 0x02; // 1
					
					if (isExternal(desc)) {
						//trace("Is external");
						traitRef |= 0x04; // 1
						// Leave remaining 1-26 bits alone
					} else {
						//trace("Is not external");
						traitRef &= ~0x04; // 0
						
						if (isDynamic(desc)) {
							//trace("Is dynamic");
							traitRef |= 0x08; // 1
						} else {
							//trace("Is not dynamic");
							traitRef &= ~0x08; // 0
						}
						
						// Dynamic types may have a set of name value pairs for dynamic members after the sealed member section. 
						// The remaining 1 to 25 significant bits are used to encode the number of sealed traits member names that follow after the class 
						// name (an integer).
						var numSealed:uint = desc.variable.length();// example number
						traitRef |= numSealed << 4;
					}
				}
			} else {
				trace("Is a reference");
				traitRef &= ~0x01; // 0
				traitRef |= key << 1; // Encode object reference index integer with remaining 1-28 bits
			}
			
			//writeInt(ba, traitRef); // Should use this since i'm only writing with 29bits?
			ba.writeByte(traitRef); 
			
			// Write data if not a reference
			var className:String = getClassName(desc);
			if(!isRef) {
				if(className != "Object" && isExternal(desc)) {
					writeString(ba, className);
				} else {
					writeString(ba, "");
				}
				
				if (isExternal(desc)) {
					value.writeExternal(ba);
				} else {
					// For some reason AS3 can't for..in loop over a class
					if(className != "Object") {
						for each (var v:XML in desc.variable) {
							writeString(ba, v.@name);
							writeData(ba, value[v.@name]);
						}
					} else {
						for (var v2:String in value) {
							writeString(ba, v2);
							writeData(ba, value[v2]);
						}
					}
				}
				
				// getters
				/*for each (v in desc.accessor){
				trace(v.@name, value[v.@name]);
				}*/
			}
			
			// Write closing object tag
			if(isDynamic(desc)) ba.writeByte(0x01); 
		}
		
		/**
		 * ActionScript 3.0 introduces a new XML type that supports E4X syntax. For serialization purposes 
		 * the XML type needs to be flattened into a string representation. As with other strings in AMF, 
		 * the content is encoded using UTF-8.
		 * 
		 * XML instances can be sent as a reference to a previously occurring XML instance by using an index 
		 * to the implicit object reference table.
		 * 
		 * xml-type = xml-marker (U29O-ref | (U29X-value *(UTF8-char)))
		 * 
		 * Note that this encoding imposes some theoretical limits on the use of XML. The byte-length of each 
		 * UTF-8 encoded XML instance is limited to 2^28 - 1 bytes (approx 256 MB).
		 * 
		 * @param	ba
		 * @param	value
		 */
		protected function writeXML(ba:ByteArray, value:XML):void {
			var strXML:String = value.toXMLString();
			strXML = strXML.replace(/^\s+|\s+$/g, ''); // Trim
			//strXML = strXML.replace(/\>(\n|\r|\r\n| |\t)*\</g, "><"); // Strip whitespaces, not done by native encoder
			ba.writeByte(0x0B);
			writeString(ba, strXML);
		}
		
		/**
		 * ActionScript 3.0 introduces a new type to hold an Array of bytes, namely ByteArray. AMF 3 serializes 
		 * this type using a variable length encoding 29-bit integer for the byte-length prefix followed by the 
		 * raw bytes of the ByteArray.
		 * 
		 * ByteArray instances can be sent as a reference to a previously occurring ByteArray instance by using 
		 * an index to the implicit object reference table.
		 * 
		 * U29B-value = U29 ; The first (low) bit is a flag with value 1. The remaining 1 to 28 significant bits 
		 * are used to encode the byte-length of the ByteArray.
		 * 
		 * bytearray-type = bytearray-marker (U29O-ref | U29B-value *(U8))
		 * 
		 * Note that this encoding imposes some theoretical limits on the use of ByteArray. The maximum byte-length 
		 * of each ByteArray instance is limited to 2^28 - 1 bytes (approx 256 MB).
		 * 
		 * @param	ba
		 * @param	value
		 */
		// TODO: Test references
		protected function writeByteArray(ba:ByteArray, value:ByteArray):void {
			ba.writeByte(0x0C);
			
			if (!objWriteCache[value]) {
				writeInt(ba, value.length * 2 + 1);
				ba.writeBytes(value);
				objWriteCache[value] = objWriteCacheLen;
				objWriteCacheLen++;
			} else {
				var handle:uint = uint(objWriteCache[value]) << 1;
				writeInt(ba, handle);
			}
		}
		
		/*private function writeReferenceIfExists(ba:ByteArray, value:*):Boolean {
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
		
		protected function writeReference(ba:ByteArray, value:int):void {
			ba.writeByte(0x07);
			writeUnsignedShort(ba, value);
		}*/
		
		private function getClassName(desc:XML):String {
			return desc.@name;
		}
		
		private function isDynamic(desc:XML):Boolean {
			return desc.@isDynamic.toString() == "true";
		}
		
		private function isExternal(desc:XML):Boolean {
			var l:int = desc.implementsInterface.length();
			while (l--) {
				if (desc.implementsInterface[l].@type == "flash.utils::IExternalizable") {
					return true;
				}
			}
			return false;
		}
		
		private function search(dict:Dictionary, item:*):int {
			var i:int = 0;
			for each(var key:* in dict) {
				if (key === item) return i;
				i++;
			}
			return -1;
		}
		
		/*private function search(array:Array, item:*):int {
			var i:uint = array.length;
			while (i--) {
				if(array[i] === item) return i;
			}
			return -1;
		}*/
	}
	
}