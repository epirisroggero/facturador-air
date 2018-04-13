/**
* Encrypts and decrypts text with the Base64 algorithm.
* modified by Jeff Houser, DotComIt 10/31/06
* http://www.jeffryhouser.com
* Converted from ActionSCript 2.0 code to ActionScript 3.0 code for use in a Flex 2 Application
* @Version 3.0
* Released under the same license as the previous code-bases
* That means there is no license, use it as you see fit for whatever reason you want
* 
* Encodes and decodes a base64 string.
* @authors Mika Palmu
* @version 2.0
*
* Original Javascript implementation:
* Aardwulf Systems, www.aardwulf.com
* See: http://www.aardwulf.com/tutor/base64/base64.html
*/
// JH DotComIt 10/31/06 added package definition 
package com.meychi.ascrypt3{

	public class Base64 {
	
		/**
		* Variables
		* @exclude
		*/
		private static var base64chars:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
		/**
		* Encodes a base64 string.
		*/
		// removed static
		public function encode(src:String):String {
			var i:Number = 0;
			var output:String = new String("");
			var chr1:Number, chr2:Number, chr3:Number;
			var enc1:Number, enc2:Number, enc3:Number, enc4:Number;
			while (i < src.length) {
				chr1 = src.charCodeAt(i++);
				chr2 = src.charCodeAt(i++);
				chr3 = src.charCodeAt(i++);
				enc1 = chr1 >> 2;
				enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
				enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
				enc4 = chr3 & 63;
				if(isNaN(chr2)) enc3 = enc4 = 64;
				else if(isNaN(chr3)) enc4 = 64;
				output += base64chars.charAt(enc1)+base64chars.charAt(enc2);
				output += base64chars.charAt(enc3)+base64chars.charAt(enc4)
			}
			return output;
		}
	
		/**
		* Decodes a base64 string.
		*/
		// removed static 
		public  function decode(src:String):String {
			var i:Number = 0;
			var output:String = new String("");
			var chr1:Number, chr2:Number, chr3:Number;
			var enc1:Number, enc2:Number, enc3:Number, enc4:Number;
			while (i < src.length) {
				enc1 = base64chars.indexOf(src.charAt(i++));
				enc2 = base64chars.indexOf(src.charAt(i++));
				enc3 = base64chars.indexOf(src.charAt(i++));
				enc4 = base64chars.indexOf(src.charAt(i++));
				chr1 = (enc1 << 2) | (enc2 >> 4);
				chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
				chr3 = ((enc3 & 3) << 6) | enc4;
				output += String.fromCharCode(chr1);
				if (enc3 != 64) output = output+String.fromCharCode(chr2);
				if (enc4 != 64) output = output+String.fromCharCode(chr3);
			}
			return output;
		}
	
	}
}