package org.cyberteam.cybermap.gpx
{
	import com.umapper.umap.types.LatLng;
	import com.umapper.umap.utils.GPX;
	
	default xml namespace = new Namespace("http://www.topografix.com/GPX/1/1");

	public class GPX
	{
		public var name:String;
		public var points:Array = new Array();
		public var distance:Number = 0.0;
		
		public function GPX(o:Object)
		{
			var xml:XML = new XML(o);
			name = xml.metadata.name;

			for(var i:uint = 0; i < xml.trk.trkseg.trkpt.@lat.length(); ++i) {
				points.push(new LatLng(xml.trk.trkseg.trkpt.@lat[i], xml.trk.trkseg.trkpt.@lon[i]));
			}
			
			calculateDistance();
		}
		
		private function calculateDistance():void {
			for(var j:uint = 0; j < points.length-2; j++) {
				distance += haversine(points[j], points[j+1]);
			}
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