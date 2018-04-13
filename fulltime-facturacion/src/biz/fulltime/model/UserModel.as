//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

public class UserModel {

	private static var _instance:UserModel;

	private var _user:Usuario;

	public function UserModel(caller:Function = null) {
		if (caller != UserModel.getInstance) {
			throw new Error("UserModel is a singleton class, use getInstance() instead");
		}
	}

	public function get user():Usuario {
		return _user;
	}

	public function set user(value:Usuario):void {
		_user = value;
	}

	public static function getInstance():UserModel {
		if (_instance == null) {
			_instance = new UserModel(arguments.callee);
		}
		return _instance;
	}
}
}
