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

import mx.controls.advancedDataGridClasses.AdvancedDataGridColumn;

public class HideShowHandler implements LeafHandler {
	private var item:AdvancedDataGridColumn = null;
	private var headerToLookFor:String;

	public function HideShowHandler(headerToLookFor:String) {
		this.headerToLookFor = headerToLookFor;
	}

	public function handleLeaf(leaf:AdvancedDataGridColumn):void {
		if (item != null) {
			return;
		}
		if (leaf.headerText == headerToLookFor) {
			item = leaf;
		}
	}

	public function getLeaf():AdvancedDataGridColumn {
		return item;
	}
}
}
