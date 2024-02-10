/**
		 * Uploads a file using a given URLLoader object.
		 * 
		 * @param loader The URLLoader object to use
		 * @param url The location of the script recieving the upload
		 * @param file The file to upload
		 * @param fileName The name of the file
		 * @param contentType The content-type of the file
		 */	
		private function uploadFile(loader:URLLoader, url:String, file:ByteArray, fileName:String, contentType:String = 'application/octet-stream'):void	{
			var i:int;
			var boundary:String = '--';
			var request:URLRequest = new URLRequest();
			var postData:ByteArray = new ByteArray();
			var bytes:String;
			
			for (i = 0; i < 0x10; i++) {
				boundary += String.fromCharCode(int(97 + Math.random() * 25));
			}
			
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			
			request.url = url;
			request.contentType = 'multipart/form-data; boundary=' + boundary;
			request.method = URLRequestMethod.POST;
			
			postData.endian = Endian.BIG_ENDIAN;
			
			// -- + boundary
			postData.writeShort( 0x2d2d );
			for (i = 0; i < boundary.length; i++) {
				postData.writeByte(boundary.charCodeAt(i));
			}
			
			// line break
			postData.writeShort(0x0d0a);
			
			// content disposition
			bytes = 'Content-Disposition: form-data; name="Filename"';
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// 2 line breaks
			postData.writeInt(0x0d0a0d0a);
			
			// file name
			postData.writeUTFBytes(fileName);
			
			// line break
			postData.writeShort(0x0d0a);
			
			// -- + boundary
			postData.writeShort(0x2d2d);
			for (i = 0; i < boundary.length; i++) {
				postData.writeByte( boundary.charCodeAt(i));
			}
			
			// line break
			postData.writeShort(0x0d0a);
			
			// content disposition
			bytes = 'Content-Disposition: form-data; name="Filedata"; filename="';
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// file name
			postData.writeUTFBytes(fileName);
			
			// missing "
			postData.writeByte(0x22);
			
			// line break
			postData.writeShort(0x0d0a);
			
			// content type
			bytes = 'Content-Type: ' + contentType;
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// 2 line breaks
			postData.writeInt(0x0d0a0d0a);
			
			// file data
			postData.writeBytes(file, 0, file.length);
			
			// line break
			postData.writeShort(0x0d0a);
			
			//	Write paramaters //
			///////////////////////
			
			// -- + boundary
			postData.writeShort(0x2d2d);
			for (i = 0; i < boundary.length; i++) {
				postData.writeByte(boundary.charCodeAt(i));
			}
			
			// line break			
			postData.writeShort(0x0d0a);
			
			// upload field
			bytes = 'Content-Disposition: form-data; name="Upload"';
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// 2 line breaks
			postData.writeInt(0x0d0a0d0a);
			
			// submit
			bytes = 'Submit Query';
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// line break
			postData.writeShort(0x0d0a);
			
			///////////////////////////////
			
			// -- + boundary
			postData.writeShort(0x2d2d);
			for (i = 0; i < boundary.length; i++) {
				postData.writeByte(boundary.charCodeAt(i));
			}
			
			// line break			
			postData.writeShort(0x0d0a);
			
			// upload field
			bytes = 'Content-Disposition: form-data; name="imageid"';
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// 2 line breaks
			postData.writeInt(0x0d0a0d0a);
			
			// submit
			bytes = tempID;
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// line break
			postData.writeShort(0x0d0a);
			
			///////////////////////////////
			
			// -- + boundary
			postData.writeShort(0x2d2d);
			for (i = 0; i < boundary.length; i++) {
				postData.writeByte(boundary.charCodeAt(i));
			}
			
			// line break			
			postData.writeShort(0x0d0a);
			
			// upload field
			bytes = 'Content-Disposition: form-data; name="contenttype"';
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// 2 line breaks
			postData.writeInt(0x0d0a0d0a);
			
			// submit
			bytes = "jpg";
			for (i = 0; i < bytes.length; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}
			
			// line break
			postData.writeShort(0x0d0a);
			
			// End Params //
			////////////////
			
			// -- + boundary + --
			postData.writeShort(0x2d2d);
			for (i = 0; i < boundary.length; i++) {
				postData.writeByte(boundary.charCodeAt(i));
			}
			postData.writeShort(0x2d2d);
			
			request.data = postData;
			request.requestHeaders.push(new URLRequestHeader('Cache-Control', 'no-cache'));
			loader.load(request);
			//navigateToURL(request, "_blank");
		}