/**
* ROT13 Encryption.
* modified by Jeff Houser, DotComIt 11/1/06
* http://www.jeffryhouser.com
* Converted from ActionSCript 2.0 code to ActionScript 3.0 code for use in a Flex 2 Application
* @Version 3.0
* Released under the same license as the previous code-bases
* That means there is no license, use it as you see fit for whatever reason you want
* 
* Encodes and decodes a ROT13 string.
* @authors Mika Palmu
* @version 2.0
*/

// JH DotComIt 11/1/06 added package definition 
package com.meychi.ascrypt3{

	public class ROT13 {

		/**
		* Variables
		* @exclude
		*/
		private static var chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZABCDEFGHIJKLMabcdefghijklmnopqrstuvwxyzabcdefghijklm";
	
		/**
		* Encodes or decodes a ROT13 string.
		*/
		// JH DotComIt 11/1/06 removed static
		public function calculate(src:String):String {
			var calculated:String = new String("");
			for (var i:Number = 0; i<src.length; i++) {
				var character:String = src.charAt(i);
				var pos:Number = chars.indexOf(character);
				if (pos > -1) character = chars.charAt(pos+13);
				calculated += character;
			}
			return calculated;
		}

	}
}