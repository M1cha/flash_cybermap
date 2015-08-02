package org.cyberteam.cybermap.gpx
{
	import com.umapper.umap.overlays.Polyline;
	import com.umapper.umap.types.LatLng;
	import com.umapper.umap.types.LatLngBounds;
	import com.umapper.umap.utils.GPX;
	
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
		
		public function getElevation():Object {
			if(elevation!=null)
				return elevation;
			
			elevation = {
				data:[],
				min:null,
				max:null
			};
			
			for(var i:uint = 0; i<points.length; i++) {
				var val:Number = randomRange(10, 800);
				elevation.data[i] = val;
				
				if(elevation.max==null || val>elevation.max)
					elevation.max = val;
				if(elevation.min==null || val<elevation.min)
					elevation.min = val;
			}
			
			return elevation;
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