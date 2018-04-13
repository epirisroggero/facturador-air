/**
* Encrypts and decrypts text with the Goauld algorithm.
* modified by Jeff Houser, DotComIt 10/31/06
* http://www.jeffryhouser.com
* Converted from ActionSCript 2.0 code to ActionScript 3.0 code for use in a Flex 2 Application
* @Version 3.0
* Released under the same license as the previous code-bases
* That means there is no license, use it as you see fit for whatever reason you want
* 
* Encodes and decodes a Goauld string.
* @authors Mika Palmu
* @version 2.0
*/
// JH DotComIt 10/31/06 added package definition 
package com.meychi.ascrypt3{

	public class Goauld {
	
		/**
		* Variables
		* @exclude
		*/
		public static var shiftValue:Number = 6;
	
		/**
		* Encodes and decodes a Goauld string with the character code shift value.
		*/
		// JH dotComit 10/31/06 removed static
		public function calculate(src:String):String {
			var result:String = new String("");
			for (var i:Number = 0; i<src.length; i++) {
				var charCode:Number = src.substr(i, 1).charCodeAt(0);
				result += String.fromCharCode(charCode^shiftValue);
			}
			return result;
		}
	}
}