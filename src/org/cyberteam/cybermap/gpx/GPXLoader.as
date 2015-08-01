package org.cyberteam.cybermap.gpx
{
	import flash.events.Event;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;

	public class GPXLoader
	{
		public static function fromFileDialog(onLoad:Function):void {
			// prepare dialog
			var fileRef:FileReferenceList = new FileReferenceList();
			var gpxFilter:FileFilter = new FileFilter(".gpx","*.gpx");
			
			// onselect
			fileRef.addEventListener(Event.SELECT, function():void{
				for(var i:Number = 0; i < fileRef.fileList.length; i++) {
					var fileref:FileReference = fileRef.fileList[i];
					fileref.addEventListener(Event.COMPLETE, function(event:Event):void{
						onLoad(new GPX(event.target.data));
					});
					
					// load file contents
					fileref.load();
				};
			});
			
			// show dialog
			fileRef.browse([gpxFilter]);
		}
	}
}