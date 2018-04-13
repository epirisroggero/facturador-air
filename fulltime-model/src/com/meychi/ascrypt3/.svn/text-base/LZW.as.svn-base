/**
* LZW Compression.
* modified by Jeff Houser, DotComIt 11/1/06
* http://www.jeffryhouser.com
* Converted from ActionSCript 2.0 code to ActionScript 3.0 code for use in a Flex 2 Application
* @Version 3.0
* Released under the same license as the previous code-bases
* That means there is no license, use it as you see fit for whatever reason you want
* ( Does not seem to work 12/6/06 ) 
* Compresses and decompresses text with the LZW algorithm.
* @authors Mika Palmu
* @version 1.1
*
* Original Flash port by:
* Ash & Lalek & Shoebox and others.
* See: http://www.razorberry.com/blog/archives/2004/08/22/lzw-compression-methods-in-as2/
* See: http://www.lalex.com/blog/comments/200405/164-compression-lzw-actionscript-2.html
*/

// JH DotComIt 11/1/06 added package definition 
package com.meychi.ascrypt3{

	public class LZW {
		import mx.controls.*;
			
		/**
		* Compresses the specified text.
		*/

		public function compress(src:String):String {
			var chars:Number = 256;
			var original:String = src;
			var dict:Array = new Array();
			// JH DotComIt 11/1/06 added var definition for loop index variable outside of the loops
			var i:Number ;
			// JH DotComIt 11/1/06 added var definition for xstr
			var xstr:String;

			// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var i:Number
/*
			for (i = 0; i<chars; i++){ dict[String(i)] = i;}

			for (i = 0; i < dict.length; i++){
				mx.controls.Alert.show(dict[i]);
			}


			for (i = 0; i<chars; i++){ dict[i.toString()] = i;}

			for (i = 0; i < dict.length; i++){
				mx.controls.Alert.show(dict[i]);
			}
*/
			for (i = 0; i < chars; i++)
			{
				dict[String.fromCharCode(i)] = i;
			}
//			Debug.show(dict);


			var result:String = new String("");
			var splitted:Array = original.split("");
			var buffer:Array = new Array();

			// JH DotComIt 11/1/06 moved current definition out of for loop
			var current:String;
			
			// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var i:Number
			for (i= 0; i<=splitted.length-1; i++) {
				// JH DotComIt 11/1/06 moved current definition out of for loop
//				current = '';
				current = splitted[i];
				
//				mx.controls.Alert.show(current + buffer.length.toString());

				if (buffer.length == 0) { 
					// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var xstr:String 
//					xstr= String(current.charCodeAt(0));
					xstr= current.charCodeAt(0).toString(); // 
				}else {
					// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var xstr:String 
//					xstr = buffer.join("-")+"-"+String(current.charCodeAt(0));
					xstr = buffer.join("-") + "-" + current.charCodeAt(0).toString(); // 
				}

//				mx.controls.Alert.show(xstr + ' _**_ ' + dict[xstr]);

				// JH DotComIt 11/1/06 what operator is '!==' ? 
				if (dict[xstr] != undefined){

					buffer.push(current.charCodeAt(0));
				} else {
					result = result + String.fromCharCode(dict[buffer.join("-")]);
					dict[xstr] = chars;
					chars++;
					buffer = new Array();
					buffer.push(current.charCodeAt(0));
				}

								
			}

			return result;
		}


		// JH DotComIt 11/1/06 removed static static
		public function compress_old(src:String):String {
			var chars:Number = 256;
			var original:String = src;
			var dict:Array = new Array();
			// JH DotComIt 11/1/06 added var definition for loop index variable outside of the loops
			var i:Number ;
			// JH DotComIt 11/1/06 added var definition for xstr
			var xstr:String;
			
			// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var i:Number
			for (i = 0; i<chars; i++){ dict[String(i)] = i;}
			var result:String = new String("");
			var splitted:Array = original.split("");
			var buffer:Array = new Array();
			
			// JH DotComIt 11/1/06 moved current definition out of for loop
			var current:String;
			
//			mx.controls.Alert.show(splitted.length.toString());

			// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var i:Number
			for (i= 0; i<=splitted.length; i++) {
//				mx.controls.Alert.show('it got here');
//				mx.controls.Alert.show(i.toString());

				// JH DotComIt 11/1/06 moved current definition out of for loop
				current = splitted[i];				


				if (buffer.length == 0) { 
					// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var xstr:String 
					xstr= String(current.charCodeAt(0));
				}else {
					// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var xstr:String 
					xstr = buffer.join("-")+"-"+String(current.charCodeAt(0));
				}
				// JH DotComIt 11/1/06 what operator is '!==' ? 
				if (dict[xstr] !== undefined){

					buffer.push(current.charCodeAt(0));
				} else {

//					result += String.fromCharCode(dict[buffer.join("-")]);
					result = result + String.fromCharCode(dict[buffer.join("-")]);
//					mx.controls.Alert.show(String.fromCharCode(dict[buffer.join("-")]));
//					mx.controls.Alert.show(result);
					dict[xstr] = chars;
					chars++;
//					delete buffer;
					buffer = new Array();
					buffer.push(current.charCodeAt(0));
				}
//				mx.controls.Alert.show(result);

			}
//			mx.controls.Alert.show('it got here');
//			mx.controls.Alert.show(' final result ' + result);
			return result;
		}
	
		/**
		* Decompresses the specified text.
		*/
		// JH DotComIt 11/1/06 removed static static
		public function decompress(src:String):String {
			var chars:Number = 256;
			var dict:Array = new Array();
			// JH DotComIt 11/1/06 added var definition for loop counter variable 
			var i:Number;
			// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var i:Number
			for (i = 0; i<chars; i++) {
				var c:String = String.fromCharCode(i);
				dict[i] = c;
			}
			var original:String = src;
			var splitted:Array = original.split("");
			var buffer:String = new String("");
			var chain:String = new String("");
			var result:String = new String("");
			
			// JH DotComIt 11/1/06 removed dupliate var definition for loop variable var i:Number
			for (i = 0; i<splitted.length; i++) {
				var code:Number = original.charCodeAt(i);
				var current:String = dict[code];
				if (buffer == "") {
					buffer = current;
					result += current;
				} else {
					if (code<=255) {
						result += current;
						chain = buffer+current;
						dict[chars] = chain;
						chars++;
						buffer = current;
					} else {
						chain = dict[code];
						// JH DotComIt 11/1/06 changed chain check because it will never be undefined
						// check to see if it is an empty string (the default value )
						// chain == null
						if (chain == ''){ chain = buffer+buffer.slice(0,1);}
						result += chain;
						dict[chars] = buffer+chain.slice(0,1);
						chars++;
						buffer = chain;
					}
				}
			}
			return result;
		}

	}
}