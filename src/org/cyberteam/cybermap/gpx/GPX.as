package org.cyberteam.cybermap.gpx
{
	import com.umapper.umap.overlays.Polyline;
	import com.umapper.umap.types.LatLng;
	import com.umapper.umap.types.LatLngBounds;
	import com.umapper.umap.utils.GPX;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	default xml namespace = new Namespace("http://www.topografix.com/GPX/1/1");

	public class GPX
	{
		public var name:String;
		public var points:Array = [];
		public var line:Polyline = new Polyline();
		public var distance:Number = 0.0;
		private var elevation:Object = null; 
		
		public function GPX(o:Object)
		{
			var xml:XML = new XML(o);
			name = xml.metadata.name;

			for(var i:uint = 0; i < xml.trk.trkseg.trkpt.@lat.length(); ++i) {
				var point:LatLng = new LatLng(xml.trk.trkseg.trkpt.@lat[i], xml.trk.trkseg.trkpt.@lon[i]);
				points.push(point);
				line.addVertex(point);
			}
			
			calculateDistance();
		}
		
		private function calculateDistance():void {
			for(var j:uint = 0; j < points.length-2; j++) {
				distance += haversine(points[j], points[j+1]);
			}
		}
		
		private function randomRange(minNum:Number, maxNum:Number):Number 
		{
			return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
		
		public function getElevation(statusUpdate:Function, onFinished:Function):void {
			var i:uint = 0;
			var thiz:GPX = this;
			
			// return cache
			if(elevation!=null) {
				onFinished(thiz, elevation);
				return;
			}
			
			elevation = {
				data:[],
				min:null,
				max:null
			};
			
			function onCompleted(e:Event):void{
				if(e!=null) {
					var val:uint = e.target.data;
					elevation.data[i++] = val;
					
					if(elevation.max==null || val>elevation.max)
						elevation.max = val;
					if(elevation.min==null || val<elevation.min)
						elevation.min = val;
				}
				
				if(elevation.data.length==points.length)
					onFinished(thiz, elevation);
				else {
					statusUpdate(thiz, i);
					
					// build variables
					var requestVars:URLVariables = new URLVariables();
					requestVars.lat = points[i].lat;
					requestVars.lng = points[i].lng;
					requestVars.username = "demo"; // this way we can use this (NON_PRODUCTION APP!!) without a API key
					
					// build request
					var request:URLRequest = new URLRequest();
					request.url = "http://api.geonames.org/astergdem";
					request.method = URLRequestMethod.GET;
					request.data = requestVars;
					
					// send request
					loader.load(request);
				}
			}
			
			// create loader
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onCompleted);
			loader.addEventListener(IOErrorEvent.IO_ERROR, function():void{
				onFinished(thiz, null);
			});

			// start
			onCompleted(null);
		}
		
		/**
		 * function to calculate the distance of two points
		 */
		private static function haversine(from:LatLng, to:LatLng):Number
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
	}
}