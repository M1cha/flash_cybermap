package org.cyberteam.cybermap
{
	//This class is used for the gpx file selection.
	//Opens a dialog for the user being able to choose one or more .gpx files.
	//Loads the xml and saves the xml files into an array.
	//Creates a list and fills an arraycollection, which is the data provider, with the needed entries
	//Creates LatLng objects through the .gpx files and saves them.
	//The final distance is getting calculated through a given haversine function.
	//TODO add and implement the mouse listener to the list object.
	//TODO add a function to remove loaded gpx
	
	import com.umapper.umap.types.LatLng;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.List;
	import spark.components.VGroup;
	
	default xml namespace = new Namespace("http://www.topografix.com/GPX/1/1");

	
	public class FileSelection
	{
		private var m_gui:CyberMap;
		private var m_fileRef:FileReferenceList;
		private var m_xmlData:Array;
		private var m_listData:ArrayCollection;
		
		private var m_list:List;
		
		//Constructor of the class
		//Percent high and width needed to avoid troubles within scaling the application.
		//Creates a list and adds it to the parent (which has to inherit from group)
		public function FileSelection(gui:CyberMap, parent:Group)
		{
			m_gui = gui;
			
			m_xmlData = new Array();
			
			m_listData = new ArrayCollection();
			
			m_list = new List();
			m_list.percentWidth = 100;
			m_list.percentHeight = 100;
			m_list.setStyle("borderVisible", false);
			m_list.dataProvider = m_listData;
			
			parent.addElement(m_list);
		}
		
		//Opens the dialog for opening multiple files.
		//Using a filter here for just seeing gxp files.
		//There will be an event called for each selected file.
		public function showDialog():void
		{
			m_fileRef = new FileReferenceList();
			var gpxFilter:FileFilter = new FileFilter(".gpx","*.gpx");
			m_fileRef.browse([gpxFilter]);
			m_fileRef.addEventListener(Event.SELECT, selectFile);
		}
		
		
		//Creates a file for each selected file which is in a list included.
		//Start to load each file.
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
		
		
		//If the file was not loaded so far, load it.
		//Save the name of the xml to check if it already was loaded.
		//Calls the addListEntry Method which will add the list entry
		private function onLoaded(event:Event):void
		{
			event.target.removeEventListener(Event.COMPLETE, onLoaded);
			
			var xml:XML = new XML(event.target.data)
				
			if(m_xmlData.indexOf(event.target.name) == -1)
			{
				m_xmlData.push(event.target.name);
				addListEntry(xml);
			}
			else
			{
				Alert.show("File already loaded!");
			}
		}
			
		//Adds a label to the dataprovider which constains the name of the route.
		//Calculates the difference by using LatLng objects from the api.
		//Adds another label to the dataprovider which contains the max. difference of the route.
		private function addListEntry(xml:XML):void
		{
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
								
			m_listData.addItem(xml.trk.name + "\n" + str);
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