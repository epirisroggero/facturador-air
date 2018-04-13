//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package components {

import flash.events.Event;

import mx.core.IVisualElement;

import spark.components.Button;
import spark.components.Panel;
import spark.components.ToggleButton;

public class PanelShowHide extends Panel {
	//declare button var
	private var showHideButton:ToggleButton;
	
	public function PanelShowHide() {
		super();
	}
	
	public var defaultHeight:Number = 178;

	private function doCreateForm(event:Event):void {
		//create an event - just an Alert for testing here
		if (!showHideButton.selected) {
			if (defaultHeight != -1) {
				this.height = defaultHeight;	
			} else {
				this.percentHeight = 100;
			}
			
		} else {
			this.height = 30;
		}
		
		for (var i:int = 0; i < this.numChildren; i++) {
			var element:IVisualElement = this.getElementAt(i);
			if (element != showHideButton) {
				element.visible = !showHideButton.selected;
				element.includeInLayout = !showHideButton.selected;
			}
			
		}
		this.controlBarVisible = !showHideButton.selected;
	
		showHideButton.toolTip = showHideButton.selected ? "Maximizar" : "Minimizar";
	}

	//override the createChildren method with the properties I need
	protected override function createChildren():void {
		super.createChildren();
		
		//instantiate new button and assign properties
		showHideButton = new ToggleButton();
		showHideButton.toolTip = "Minimizar";
		showHideButton.styleName = "hideShowButton";
		
		//add event listener for click event and call method
		showHideButton.addEventListener("click", doCreateForm);
		showHideButton.visible = true;
		
		
		//add the button to rawChildren
		this.addElement(showHideButton);
	}

	//update the display and get panel size - dynamic since the form can be resized
	protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
		super.updateDisplayList(unscaledWidth, unscaledHeight);
		//gap between label and edges of button
		var margin:int = 5;
		//set the button size + margin
		showHideButton.setActualSize(24 + margin, 16 + margin);
		//define vars which determine distance from right and top of Panel
		var pixelsRight:int = 5;
		var pixelsTop:int = -28;
		//define var to width of button
		var buttonWidth:int = showHideButton.width;
		//set x and y properties to be used for positioning of button
		var x:Number = unscaledWidth - buttonWidth - pixelsRight;
		var y:Number = pixelsTop;
		//position the button in the panel
		showHideButton.move(x, y);
	}
}
}
