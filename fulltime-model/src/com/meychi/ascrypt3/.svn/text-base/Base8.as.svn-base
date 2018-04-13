/**
* Encrypts and decrypts text with the Base8 algorithm.
* modified by Jeff Houser, DotComIt 10/31/06
* http://www.jeffryhouser.com
* Converted from ActionSCript 2.0 code to ActionScript 3.0 code for use in a Flex 2 Application
* @Version 3.0
* Released under the same license as the previous code-bases
* That means there is no license, use it as you see fit for whatever reason you want
* 
* Encodes and decodes a base8 (hex) string.
* @authors Mika Palmu
* @version 2.0
*/

// JH DotComIt 10/31/06 added package definition 
package com.meychi.ascrypt3{

	public class Base8 {

		/**
		* Encodes a base8 string.
		*/
		// JH DotComIt 10/31/06 removed static
		public function encode(src:String):String {
			var result:String = new String("");
			for (var i:Number = 0; i<src.length; i++) {
				result += src.charCodeAt(i).toString(16);
			}
			return result;
		}
	
		/**
		* Decodes a base8 string.
		*/
		// JH DotComIt 10/31/06 removed static
		public function decode(src:String):String {
			var result:String = new String("");
			for (var i:Number = 0; i<src.length; i+=2) {
				result += String.fromCharCode(parseInt(src.substr(i, 2), 16));
			}
			return result;
		}
	}

}