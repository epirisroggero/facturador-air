//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.event {

import flash.events.Event;

public class MenuEventFT extends Event {

	public static const FACTURACION_EVENT:String = "_billing";
	public static const EXIT:String = "_exit";
	public static const MENU_CHANGE:String = "_menuchange";
	public static const REFRESCAR_CATALOGOS_EVENT:String = "_refrescar_Catalogos";
	public static const REPORTE_STOCK_PRECIO_EVENT:String = "_reporteStockPrecio";
	
	
	public static const REPORTE_COBRANZA:String = "_reporteCobranza";
	public static const REPORTE_COMISIONES:String = "_reporteComisiones";
	public static const REPORTE_CONTROL_MAS:String = "_reporteControlMas";
	public static const REPORTE_LIQUIDACION:String = "_reporteLiquidacion";
	public static const REPORTE_LIQUIDACION_VENDEDORES:String = "_reporteLiquidacionVendedores";

	public static const SOLICITUDES_EVENT:String = "_solicitudes";
	public static const RECIBOS_EVENT:String = "_recibos";
	public static const GASTOS_EVENT:String = "_gastos";
	
	/*
	public static const SOLICITUD_GASTO:String = "_solicitudGasto";
	public static const SOLICITUD_COMPRA:String = "_solicitudCompra";
	public static const SOLICITUD_IMPORTACION:String = "_solicitudImportacion";
	*/
	public static const COTIZACIONES:String = "_cotizaciones";
	public static const COMPRA_MERCADERIA_PLAZA:String = "_compraMercaderiaPlaza";
	
	public static const REPORTE_RENTAS_EVENT:String = "_reporteRentas";
	public static const REPORTE_DEUDORES_EVENT:String = "_reporteDeudores";
	public static const EXPEDICIONES_EVENT:String = "_expediciones";
	public static const CONFIGURAR_IMPRESORAS_EVENT:String = "_configurarImpresoras";
	
	public static const CRUD_TIPOS_ENTREGA_EVENT:String = "_tiposEntrega";
	
	public static const CRUD_FANFOLD:String = "_fanfold";

	public static const DESCUENTOS_PROMETIDOS_EVENT:String = "_descuentosPrometidos";
	
	public static const RUTINA_COSTOS_EVENT:String = "_rutinaCostos";
	
	public static const MOSTRAR_CLIENTES_EVENT:String = "_mostrarClientes";

	public static const MOSTRAR_CONTACTOS_EVENT:String = "_mostrarContactos";
	
	public static const MOSTRAR_ARTICULOS_EVENT:String = "_mostrarArticulos";
	
	public static const MOSTRAR_PROVEEDORES_EVENT:String = "_mostrarProveedores";
	
	public static const MOSTRAR_USUARIOS_EVENT:String = "_usuarios";
	
	public static const REPORTE_VENDEDORES_EVENT:String = "_reporteVendedores";
	
	public static const REPORTE_AFILADOS_EVENT:String = "_reporteAfilados";
	
	public static const EFACTURA_EVENT:String = "_eFactura";


	public var navigate:String;

	public function MenuEventFT(type:String, navigate:String) {
		super(type);

		this.navigate = navigate;
	}
}
}
