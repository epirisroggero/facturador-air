//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {
import biz.fulltime.conf.ServerConfig;

import flash.events.TimerEvent;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.formatters.DateFormatter;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

import util.DateUtil;

public class CotizacionesModel {

	private static var _instance:CotizacionesModel;
	
	private var _cotizaciones:XML =
		<cotizaciones>
			<fecha />
			<dolarCompra value="18.25"/>
			<dolarVenta value="19.25"/>
			<euroCompra value="25.78"/>
			<euroVenta value="28.32"/>
			<euroCompraXDolar value="0.71"/>
			<euroVentaXDolar value="0.68"/>
		</cotizaciones>
		;

	public function CotizacionesModel(caller:Function = null) {
		if (caller != CotizacionesModel.getInstance) {
			throw new Error("CotizacionesModel is a singleton class, use getInstance() instead");
		}
		
		var timer:Timer = new Timer(3600000);
		timer.addEventListener(TimerEvent.TIMER, function(evt:TimerEvent):void {
			loadCotizacionesMonedas();
		});
		timer.start();
	}
	
	public function loadCotizacionesMonedas():void {
		var remObjCotizaciones:RemoteObject = new RemoteObject();
		remObjCotizaciones.destination = "CreatingRpc";
		remObjCotizaciones.channelSet = ServerConfig.getInstance().channelSet;
		remObjCotizaciones.addEventListener(ResultEvent.RESULT, function(evt:ResultEvent):void {
			var cotizacion:CotizacionesMonedas = evt.result as CotizacionesMonedas;
			
			var dolarCompra:BigDecimal = new BigDecimal(cotizacion.dolarCompra);
			var dolarVenta:BigDecimal = new BigDecimal(cotizacion.dolarVenta);
			var euroCompra:BigDecimal = new BigDecimal(cotizacion.euroCompra);
			var euroVenta:BigDecimal = new BigDecimal(cotizacion.euroVenta);
			
			var formatter:DateFormatter = new DateFormatter();
			formatter.formatString = 'DD-MM-YYYY';
			
			_cotizaciones.fecha.@value = formatter.format(cotizacion.dia);
			
			_cotizaciones.dolarCompra.@value = dolarCompra.setScale(2, MathContext.ROUND_DOWN).toString();
			_cotizaciones.dolarVenta.@value = dolarVenta.setScale(2, MathContext.ROUND_UP).toString();
			_cotizaciones.euroCompra.@value = euroCompra.setScale(2, MathContext.ROUND_DOWN).toString();
			_cotizaciones.euroVenta.@value = euroVenta.setScale(2, MathContext.ROUND_UP).toString();
			_cotizaciones.euroCompraXDolar.@value = euroCompra.divide(dolarCompra).setScale(2, MathContext.ROUND_DOWN).toString();
			_cotizaciones.euroVentaXDolar.@value = euroVenta.divide(dolarVenta).setScale(2, MathContext.ROUND_UP).toString();

		});
		remObjCotizaciones.addEventListener(FaultEvent.FAULT, function(evt:FaultEvent):void {
			Alert.show(evt.fault.faultString, "Advertencia"); 
		});
		
		remObjCotizaciones.getCotizacionHoy();

	}

	[Bindable]
	public function get cotizaciones():XML {
		return _cotizaciones;
	}

	public function set cotizaciones(value:XML):void {
		_cotizaciones = value;
	}

	public static function getInstance():CotizacionesModel {
		if (_instance == null) {
			_instance = new CotizacionesModel(arguments.callee);
		}
		return _instance;
	}
}

}
