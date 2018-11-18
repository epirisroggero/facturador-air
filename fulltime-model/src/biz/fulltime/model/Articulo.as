//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {
import biz.fulltime.conf.ServerConfig;

import flash.events.Event;
import flash.utils.ByteArray;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.remoting.RemoteObject;

[Bindable]
[RemoteClass(alias="uy.com.tmwc.facturator.entity.Articulo")]
public class Articulo extends CodigoNombreEntity {

	public var iva:Iva;

	public var costo:String;

	public var monedaCosto:Moneda;

	public var fechaCosto:Date;

	public var proveedor:Proveedor;

	public var familia:FamiliaArticulos;
	
	public var marca:Marca;

	public var inventario:Boolean;
	
	public var artGXPortal:Boolean;

	public var activo:Boolean;
	
	public var listaPrecios:Boolean;
	
	public var lotes:Boolean;


	public var familiaId:String;

	public var blob:ByteArray;

	public var blobExt:String;

	public var notas:String;

	public var puntos:String;

	public var vence:String;

	public var web:String;

	public var categArtId:String;

	private var _ivaIdArt:Number;

	public var marcaId:String;

	public var prvIdArt:String;

	public var retencionIdArt:Number;

	public var rubIdArtCompras:String;

	public var rubIdArtProd:String;

	public var rubIdArtVentas:String;

	public var textoIdArt:String;

	public var unidadId:String;
	
	//////
	
	public var abrevia:String;
	
	public var alta:Date;
	
	public var codigoOrigen:String;
	
	public var costoUtilidad:String; //BigDecimal
	
	public var idAbrevia:String;
	
	public var partidaId:Number;
	
	public var ranking:String; //BigDecimal	
	
	public var GTCIdArt:String;
	
	public var mndIdArtCosto:Number;

	public var esNuevo:Boolean;

	public var artFichaTecnica:ByteArray;
	
	public var videoYoutube:String;
	
	public var videoYoutube2:String;
	
	public var videoYoutube3:String;

	public var peso:String;
	
	public var artNotasInt:String;
	
	private var remMerge:RemoteObject;
	
	private var remUpdatePrecios:RemoteObject;
	
	public function Articulo() {
	}

	public function getTasaIva():BigDecimal {
		return iva == null ? BigDecimal.ZERO : iva.getTasaIva();
	}

	public static function getNuevoArticulo():Articulo {
		var articulo:Articulo = new Articulo();

		articulo.iva = new Iva();
		articulo.familia = new FamiliaArticulos();
		articulo.monedaCosto = new Moneda();
		articulo.proveedor = new Proveedor();

		return articulo;
	}
	
	public function mergeArticulo():void {
		if (!remMerge) { 
			remMerge = new RemoteObject();
			remMerge.destination = "CreatingRpc";
			remMerge.channelSet = ServerConfig.getInstance().channelSet;
			remMerge.addEventListener(ResultEvent.RESULT, resultMergeArticulo);
			remMerge.addEventListener(FaultEvent.FAULT, handleFault);
		}
		prvIdArt = this.proveedor ? this.proveedor.codigo : "";
		familiaId = this.familia ? this.familia.codigo : "";
		
		remMerge.modificarArticulo(this);
	}

	public function updatePrecios(precios:ArrayCollection):void {
		if (!remUpdatePrecios) { 
			remUpdatePrecios = new RemoteObject();
			remUpdatePrecios.destination = "CreatingRpc";
			remUpdatePrecios.channelSet = ServerConfig.getInstance().channelSet;
			remUpdatePrecios.addEventListener(ResultEvent.RESULT, resultUpdatePrecios);
			remUpdatePrecios.addEventListener(FaultEvent.FAULT, handleFault);
		}
		remUpdatePrecios.updatePrecios(precios);
	}

	private function resultMergeArticulo(event:ResultEvent):void {
		var resultM:* = event.result;
		dispatchEvent(new Event("_savedArticuloOk"));
	}
	
	private function resultUpdatePrecios(event:ResultEvent):void {
		var resultM:* = event.result;
		dispatchEvent(new Event("_savedArticuloOk"));
	}

	
	private function handleFault(event:FaultEvent):void {
		Alert.show(event.fault.faultString, "Error");
	}

	public function get ivaIdArt():Number {
		if (iva) {
			return new BigDecimal(iva.codigo).numberValue();
		}		
		return 0;
	}

	public function set ivaIdArt(value:Number):void {
		_ivaIdArt = value;
	}



}

}
