//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2013 Ernesto Piris.  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF IdeaSoft Co. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package biz.fulltime.ui.expediciones {

import mx.collections.ArrayCollection;
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

public class MenuLeafHandler implements LeafHandler {

	private var arr:ArrayCollection;

	public function MenuLeafHandler() {
		arr = new ArrayCollection();
	}

	public function handleLeaf(leaf:AdvancedDataGridColumn):void {
		var obj:Object = new Object();
		obj.label = leaf.headerText;
		obj.type = "check";
		obj.toggled = "true";
		arr.addItem(obj);
	}

	public function getArray():ArrayCollection {
		return arr;
	}
}
}
