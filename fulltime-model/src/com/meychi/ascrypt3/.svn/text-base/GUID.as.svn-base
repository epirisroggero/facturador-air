/**
* Generates a GUID identifier.
* modified by Jeff Houser, DotComIt 11/1/06
* http://www.jeffryhouser.com
* Converted from ActionSCript 2.0 code to ActionScript 3.0 code for use in a Flex 2 Application
* @Version 3.0
* Released under the same license as the previous code-bases
* That means there is no license, use it as you see fit for whatever reason you want
* 
* Creates a new genuine unique identifier string.
* @authors Mika Palmu
* @version 1.0
*/


// JH DotComIt 11/1/06 added package definition 
package com.meychi.ascrypt3{

	public class GUID {

		import com.meychi.ascrypt3.SHA1;
		// JH DotComIt 11/1/06 added import of flash system capabilities
		import flash.system.Capabilities;

	
		/**
		* Variables
		* @exclude
		*/
		private static var counter:Number = 0;
	
		/**
		* Creates a new Genuine Unique IDentifier. :)
		*/
		// JH DotComIt 11/1/06 removed static
		public function create():String {
			var SHA1_var:SHA1 = new SHA1();

			var id1:Number = new Date().getTime();
			var id2:Number = Math.random()*Number.MAX_VALUE;
			// JH DotComIt 11/1/06 changed casing on system.capabilities
//			var id3:String = System.capabilities.serverString;
			var id3:String = Capabilities.serverString;
			return SHA1_var.calculate(id1+id3+id2+counter++);
		}
	}
}