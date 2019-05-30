//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.conf {

import mx.controls.Alert;
import mx.messaging.Channel;
import mx.messaging.ChannelSet;
import mx.messaging.channels.AMFChannel;
import mx.messaging.channels.SecureAMFChannel;

public class ServerConfig {

	private static var _instance:ServerConfig;

	private var _host:String = "apps.fulltime.uy";

	private var _port:String = "8180";

	private var secure:Boolean = false;

	public function ServerConfig(caller:Function = null) {
		if (caller != ServerConfig.getInstance) {
			throw new Error("ServerConfig is a singleton class, use getInstance() instead");
		}
	}

	public function get port():String {
		return _port;
	}

	public function set port(value:String):void {
		_port = value;
	}

	public function get host():String {
		return _host;
	}

	public function set host(value:String):void {
		_host = value;
	}

	public function get channelSet():ChannelSet {
		var amf_url:String;
		var customChannel:Channel;
		if (secure) {
			amf_url = "https://" + host + ":" + port + "/facturator/messagebroker/amfsecure";
			customChannel = new SecureAMFChannel("my-secure-amf", amf_url);
		} else {
			amf_url = "http://" + host + ":" + port + "/facturator/messagebroker/amf";
			customChannel = new AMFChannel("my-amf", amf_url);
		}
		var cs:ChannelSet = new ChannelSet();
		cs.addChannel(customChannel);

		return cs;

	}

	public static function getInstance():ServerConfig {
		if (_instance == null) {
			_instance = new ServerConfig(arguments.callee);
		}
		return _instance;
	}
	
	public function getBasePath(secure:Boolean = false):String {
		if (secure) {
			return "https://" + host + ":" + port;
		} else {
			return "http://" + host + ":" + port;
		}
	}
	
	/*public function getFullPath(path:String, secure:Boolean = false):String {
		return getBasePath(secure) + "/facturador" + path;
	}*/
}
}
