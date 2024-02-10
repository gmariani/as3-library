package cv.formats {
	
	//--------------------------------------
	//  Class description
	//--------------------------------------	
	/**
	 * The RSS class parses RSS formatted playlist files and adds the data
	 * to itself. It incorporates all changes and additions, starting with 
	 * the basic spec for RSS 0.91 (June 2000) and includes new features 
	 * introduced in RSS 0.92 (December 2000) and RSS 0.94 (August 2002). 
	 *
	 * @langversion 3.0
	 * @playerversion Flash 9.0.115.0
	 */
	public class RSS {
		
		private var objData:Object = new Object();
		
		public function RSS(sourceFile:XML):void {
			
			// The source RSS data may or may not use a namespace to define its content.
			if (sourceFile.namespace("") != undefined) {
				default xml namespace = sourceFile.namespace("");
			}
			
			// 1.0 is structured differently from 0.9x and 2.0, becuase of that, it's not fully supported.
			var version:String = sourceFile.@version;
			if (version == "1.0") trace("RSS - RSS 1.0 is not fully supported, attempting parse.");
			
			// Get Channel Header
			objData.channel = new Object();
			// Required elements
			objData.channel.title = sourceFile..title.toString();
			objData.channel.link = sourceFile..link.toString();
			objData.channel.description = sourceFile..description.toString();
			// Optional elements
			if(sourceFile..hasOwnProperty("language")) objData.channel.language = sourceFile..language.toString();
			if(sourceFile..hasOwnProperty("copyright")) objData.channel.copyright = sourceFile..copyright.toString();
			if(sourceFile..hasOwnProperty("managingEditor")) objData.channel.managingEditor = sourceFile..managingEditor.toString();
			if(sourceFile..hasOwnProperty("webMaster")) objData.channel.webMaster = sourceFile..webMaster.toString();
			if(sourceFile..hasOwnProperty("pubDate")) objData.channel.pubDate = sourceFile..pubDate.toString();
			if(sourceFile..hasOwnProperty("lastBuildDate")) objData.channel.lastBuildDate = sourceFile..lastBuildDate.toString();
			if(sourceFile..hasOwnProperty("category")) objData.channel.category = sourceFile..category.toString();
			if(sourceFile..hasOwnProperty("generator")) objData.channel.generator = sourceFile..generator.toString();
			if(sourceFile..hasOwnProperty("docs")) objData.channel.docs = sourceFile..docs.toString();
			if(sourceFile..hasOwnProperty("cloud")) objData.channel.cloud = sourceFile..cloud.toString();
			if(sourceFile..hasOwnProperty("ttl")) objData.channel.ttl = sourceFile..ttl.toString();
			if(sourceFile..hasOwnProperty("image")) objData.channel.image = sourceFile..image.toString();
			if(sourceFile..hasOwnProperty("rating")) objData.channel.rating = sourceFile..rating.toString();
			if(sourceFile..hasOwnProperty("textInput")) objData.channel.textInput = sourceFile..textInput.toString();
			if(sourceFile..hasOwnProperty("skipHours")) objData.channel.skipHours = sourceFile..skipHours.toString();
			if(sourceFile..hasOwnProperty("skipDays")) objData.channel.skipDays = sourceFile..skipDays.toString();
			
			// Get Items
			objData.items = new Array();
			for each (var item:XML in sourceFile..item) {
				var objItem:Object = new Object();
				if(item.hasOwnProperty("title")) objItem.title = item.title.toString(); // The title of the item. i.e. Venice Film Festival Tries to Quit Sinking
				if(item.hasOwnProperty("link")) objItem.link = item.link.toString(); // The URL of the item. i.e. http://nytimes.com/2004/12/07FEST.html
				if(item.hasOwnProperty("description")) objItem.description = item.description.toString(); // The item synopsis.
				if(item.hasOwnProperty("author")) objItem.author = item.author.toString(); // Email address of the author of the item. i.e. oprah\@oxygen.net
				if(item.hasOwnProperty("category")) objItem.category = item.category.toString(); // Includes the item in one or more categories.
				if(item.hasOwnProperty("comments")) objItem.comments = item.comments.toString(); // URL of a page for comments relating to the item. i.e. http://www.myblog.org/cgi-local/mt/mt-comments.cgi?entry_id=290
				if(item.hasOwnProperty("enclosure")) objItem.enclosure = item.enclosure.toString(); // Describes a media object that is attached to the item.
				if(item.hasOwnProperty("guid")) objItem.guid = item.guid.toString(); // A string that uniquely identifies the item. i.e. http://inessential.com/2002/09/01.php#a2
				if(item.hasOwnProperty("pubDate")) objItem.pubDate = item.pubDate.toString(); // Indicates when the item was published. i.e. Sun, 19 May 2002 15:21:36 GMT
				if(item.hasOwnProperty("source")) objItem.source = item.source.toString(); // The RSS channel that the item came from.
				objData.items.push(objItem);
			}
		}
		
		public function get data():Object {
			return objData;
		}
		
		public function get title():String {
			return objData.chanel.title;
		}
		
		public function get link():String {
			return objData.chanel.link;
		}
		
		public function get description():String {
			return objData.chanel.description;
		}
	}
}