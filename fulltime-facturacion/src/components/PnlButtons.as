//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009 Ernesto Piris  All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF IdeaSoft Co. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code. 
// 
// $Id:$ 
//------------------------------------------------------------------------------

package components {

import biz.fulltime.conf.GeneralOptions;
import biz.fulltime.model.Usuario;

import flash.events.Event;

import mx.collections.ArrayCollection;
import mx.core.IVisualElement;

import spark.components.ButtonBar;
import spark.components.HGroup;
import spark.components.Panel;
import spark.components.ToggleButton;
import spark.events.IndexChangeEvent;

public class PnlButtons extends Panel {

	private var defButton:ToggleButton;
	
	private var advButton:ToggleButton;
	
	private var supButton:ToggleButton;

	private var hGroup:HGroup;

	public function PnlButtons() {
		super();
	}



	//override the createChildren method with the properties I need
	private var bbar:ButtonBar = new ButtonBar();

	protected override function createChildren():void {
		super.createChildren();

		//add event listener for click event and call method
		bbar.width = 270;
		bbar.height = 24;
		bbar.requireSelection = true;
		
		var dataProvider:ArrayCollection = new ArrayCollection();
		dataProvider.addItem("Normal");
		dataProvider.addItem("Avanzado");
		
		var user:Usuario = GeneralOptions.getInstance().loggedUser;
		if (user.permisoId != Usuario.USUARIO_ALIADOS_COMERCIALES) {
			dataProvider.addItem("Supervisión");
		}
		
		bbar.dataProvider = dataProvider;
		bbar.addEventListener(IndexChangeEvent.CHANGE, changeSelectedItem);
		bbar.selectedIndex = 0;
		
		addElement(bbar);
	}
	
	private function changeSelectedItem(event:IndexChangeEvent):void {
		dispatchEvent(event);
	}

	//update the display and get panel size - dynamic since the form can be resized
	protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		//gap between label and edges of button
		var margin:int = 5;
		//define vars which determine distance from right and top of Panel
		var pixelsRight:int = 5;
		var pixelsTop:int = -28;
		//define var to width of button
		var buttonWidth:int = 270;
		//set x and y properties to be used for positioning of button
		var x:Number = unscaledWidth - buttonWidth - pixelsRight;
		var y:Number = pixelsTop;

		//position the button in the panel
		bbar.move(x, y);
	}

}
}
