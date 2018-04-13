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

public interface LeafHandler {
	function handleLeaf(leaf:AdvancedDataGridColumn):void;
}
}
