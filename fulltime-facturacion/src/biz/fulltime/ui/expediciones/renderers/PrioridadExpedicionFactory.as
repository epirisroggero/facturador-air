//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF Ernesto Piris. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.ui.expediciones.renderers {

public class PrioridadExpedicionFactory {
	private static var instance:PrioridadExpedicionFactory = new PrioridadExpedicionFactory();

	public static const PRIORIDAD_ALTA:String = "A";
	public static const PRIORIDAD_MEDIA:String = "M";
	public static const PRIORIDAD_BAJA:String = "B";

	[Bindable]
	[Embed("/assets/expediciones/prioridad/critical.png")]
	private static var altaIcon:Class;

	[Bindable]
	[Embed("/assets/expediciones/prioridad/major.png")]
	private static var mediaIcon:Class;

	[Bindable]
	[Embed("/assets/expediciones/prioridad/minor.png")]
	private static var bajaIcon:Class;


	public function PrioridadExpedicionFactory() {
	}

	public static function getPrioridadImage(prioridad:String):Class {
		switch (prioridad) {
			case PRIORIDAD_ALTA:
				return altaIcon;
			case PRIORIDAD_MEDIA:
				return mediaIcon;
			case PRIORIDAD_BAJA:
				return bajaIcon;
		}

		return null;
	}
	
	public static function getPrioridadTooltip(prioridad:String):String {
		switch (prioridad) {
			case PRIORIDAD_ALTA:
				return "Prioridad Alta";
			case PRIORIDAD_MEDIA:
				return "Prioridad Media";
			case PRIORIDAD_BAJA:
				return "Prioridad Baja";
		}
		
		return null;
	}



}
}
