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
import mx.controls.advancedDataGridClasses.AdvancedDataGridColumnGroup;

public class Traversal {
	private var handler:LeafHandler;

	public function Traversal(handler:LeafHandler) {
		this.handler = handler;
	}

	public function traverseAndGetHandler(clms:Array):LeafHandler {
		traverse(clms);
		return handler;
	}

	private function traverse(clms:Array):void {
		for (var i:int = 0; i < clms.length; i++) {
			if (clms[i] is AdvancedDataGridColumnGroup) {
				traverse(AdvancedDataGridColumnGroup(clms[i]).children);
			} else {
				handler.handleLeaf(AdvancedDataGridColumn(clms[i]));
			}
		}
	}
}

}
