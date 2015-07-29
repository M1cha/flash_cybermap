package org.cyberteam.cybermap
{
	import com.umapper.umap.types.LatLng;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	import mx.collections.ArrayList;
	import mx.controls.List;
	
	import spark.components.Label;
	import spark.components.VGroup;

	//This class is used for the gpx file selection.
	//Opens a dialog for the user being able to choose one or more .gpx files.
	//Loads the xml and saves the xml files into an array.
	//Creates LatLng objects through the .gpx files and saves them.
	//Creates two labels which will be added to the data provider for a list (name of the route and distance).
	//The final distance is getting calculated.
	//TODO check if the file already was loaded!.
	//TODO add and implement the mouse listener to the list object.
	//TODO change implemention that it would work without having the mxml ready.
	//TODO add a function to remove loaded gpx
	
	public class FileSelection
	{
		private var m_gui:CyberMap;
		private var m_fileRef:FileReferenceList;
		private var m_xmlData:Array;
		
		
		public function FileSelection(gui:CyberMap)
		{
			m_gui = gui;
			
			//not sure where this has to be
			default xml namespace = new Namespace("http://www.topografix.com/GPX/1/1");

			m_xmlData = new Array();
			showDialog();
		}
		
		//Opens the dialog for opening multiple files.
		//Using a filter here for just seeing gxp files.
		//There will be an event called for each selected file.
		private function showDialog():void
		{
			m_fileRef = new FileReferenceList();
			var gpxFilter:FileFilter = new FileFilter(".gpx","*.gpx");
			m_fileRef.browse([gpxFilter]);
			m_fileRef.addEventListener(Event.SELECT, selectFile);
		}
		
		
		//creates a file for each selected file which is in a list included.
		//start to load each file.
		private function selectFile(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, selectFile);

			//no idea if this has to be done
			event.currentTarget.fileList as ArrayList
				
			var file:FileReference;
			
			for(var i:Number = 0; i < m_fileRef.fileList.length; i++) {
				file = m_fileRef.fileList[i];
				file.addEventListener(Event.COMPLETE,onLoaded);
				file.load();
			}
		}
		
		
		//once a file is loaded, add it to a xml collection.
		private function onLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onLoaded);
			var xml:XML = new XML(event.target.data)
			m_xmlData.push(xml);
			addListEntry(xml);
		}
		
		
		//creats a list
		//adds a label to the dataprovider which constains the name of the route.
		//calculates the difference by using LatLng objects from the api.
		//adds another label to the dataprovider which contains the max. difference of the route.
		private function addListEntry(xml:XML):void
		{
			//name of the route
			var nameLabel:Label = new Label();
			nameLabel.name = xml.trk.name;
			//m_gui.dataprover_list.addItem(nameLabel);

			//distance of the route
			var latlangs:Array = new Array();
			
			//generate all LatLangs objects and push them to an array
			for(var i:uint = 0; i < xml.trk.trkseg.trkpt.@lat.length(); ++i)
			{
				var tmp:LatLng = new LatLng(xml.trk.trkseg.trkpt.@lat[i], xml.trk.trkseg.trkpt.@lon[i]);
				latlangs.push(tmp);
			}
			
			//calculate the distance
			var distance:Number = 0.0;
			
			for(var j:uint = 0; j < latlangs.length-2; j++)
			{
				distance += haversine(latlangs[j], latlangs[j+1]);
			}
			
			//round it and finish the string
			var str:String = distance.toFixed(1) + " km";
			
			var distanceLabel:Label = new Label();
			distanceLabel.name = str;
			//m_gui.dataprover_list.addItem(distanceLabel);
			
			
			var testLabel:Label = new Label();
			testLabel.name = nameLabel + "\n" + distanceLabel;
			m_gui.dataprover_list.addItem(testLabel);
		}
				
		
		//function to calculate the distance of two points
		private static function haversine(from:LatLng,to:LatLng):Number
		{
			function degToRad(deg:Number):Number
			{
				return deg * Math.PI / 180;
			}
			
			const EARTH_RADIUS:Number = 6371;
			var dLatDiv2:Number = degToRad(to.lat - from.lat) / 2;
			var dLngDiv2:Number = degToRad(to.lng - from.lng) / 2;
			var a:Number = Math.sin(dLatDiv2) * Math.sin(dLatDiv2) + Math.cos(degToRad(from.lat)) *
				Math.cos(degToRad(to.lat)) * Math.sin(dLngDiv2) * Math.sin(dLngDiv2);
			return EARTH_RADIUS * 2 * Math.asin(Math.sqrt(a));
		}
		
		//TODO
		private function onDoubleClicked(event:MouseEvent):void
		{
			
		}
	}
}