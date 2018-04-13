//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package components {

import spark.components.Button;

//icons
[Style(name = "iconUp", type = "*")]
[Style(name = "iconOver", type = "*")]
[Style(name = "iconDown", type = "*")]
[Style(name = "iconDisabled", type = "*")]
[Style(name = "iconWidth", type = "Number")]
[Style(name = "iconHeight", type = "Number")]
//paddings
[Style(name = "paddingLeft", type = "Number")]
[Style(name = "paddingRight", type = "Number")]
[Style(name = "paddingTop", type = "Number")]
[Style(name = "paddingBottom", type = "Number")]

public class IconButton extends Button {
	public function IconButton() {
		super();
	}
}

}
