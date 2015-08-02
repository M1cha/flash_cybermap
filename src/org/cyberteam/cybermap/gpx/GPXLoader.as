package org.cyberteam.cybermap.gpx
{
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	public class GPXLoader
	{	
		
		public static function fromFileDialog(callbacks:Object):void {
			// prepare dialog
			var fileRefList:FileReferenceList = new FileReferenceList();
			var gpxFilter:FileFilter = new FileFilter(".gpx","*.gpx");
			
			// onselect
			fileRefList.addEventListener(Event.SELECT, function():void{
				for(var i:Number = 0; i < fileRefList.fileList.length; i++) {
					new GPXFileLoader(callbacks, fileRefList.fileList[i]);
				};
			});
			
			// show dialog
			fileRefList.browse([gpxFilter]);
		}
	}
}

import flash.events.Event;
import flash.net.FileReference;
import org.cyberteam.cybermap.gpx.GPX;

class GPXFileLoader {
	public function GPXFileLoader(callbacks:Object, fileref:FileReference){
		var callbackArg:Object = null;
		
		if(callbacks.onFileSelected!=null)
			callbackArg = callbacks.onFileSelected(fileref);
		
		fileref.addEventListener(Event.COMPLETE, function(event:Event):void{
			if(callbacks.onFileLoaded!=null)
				callbacks.onFileLoaded(new GPX(event.target.data), callbackArg);
		});
		
		// load file contents
		fileref.load();
	}
}