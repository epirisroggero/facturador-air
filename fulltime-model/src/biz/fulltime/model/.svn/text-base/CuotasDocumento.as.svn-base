//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package biz.fulltime.model {

import mx.charts.chartClasses.DateRangeUtilities;
import mx.collections.ArrayCollection;

import util.ArrayIterator;
import util.DateUtil;

[Bindable]
[RemoteClass(alias = "uy.com.tmwc.facturator.entity.CuotasDocumento")]
public class CuotasDocumento {

	public var cuotas:ArrayCollection = new ArrayCollection();

	public var documento:Documento;

	public function CuotasDocumento() {
	}

	public function addDaysToDate(date:Date, days:int):Date {
		date.setDate(date.getDate() + days);
		return date;
	}

	public function addMonthsToDate(date:Date, months:int):Date {
		if (months != 0) {
			var month:int = date.getMonth();
			var year:int = date.getFullYear();

			var resultMonthCount:int = year * 12 + month + months;
			var resultYear:int = resultMonthCount / 12;
			var resultMonth:int = resultMonthCount - resultYear * 12;

			date.setMonth(resultMonth);
			date.setFullYear(resultYear);

		}
		return date;
	}


	public function inicializarCuotas():void {
		if (this.cuotas) {
			this.cuotas.removeAll();
		}
		var plan:PlanPagos = this.documento.planPagos;
		if (plan == null) {
			return;
		}

		var total:BigDecimal = new BigDecimal(documento.total);
		var acumCuotas:BigDecimal = BigDecimal.ZERO;
		var redondeoMinValue:BigDecimal;
		if (plan.acumularDecimales) {
			redondeoMinValue = new BigDecimal(Math.pow(10, -1 * this.documento.moneda.getRedondeo())).setScale(this.documento.moneda.getRedondeo());
		} else {
			redondeoMinValue = new BigDecimal("0.01");
		}

		var vencimiento:Date = new Date();//DateUtil.clone(/*documento.fecha*/).date;

		if (plan.cuotasIguales) {
			vencimiento = addMonthsToDate(vencimiento, plan.primerMes);
			vencimiento = addDaysToDate(vencimiento, plan.primerDia);
			var importeCuota:BigDecimal;

			if (plan.acumularDecimales) {
				importeCuota = total.divide(new BigDecimal(plan.cantidadCuotas)).setScale(this.documento.moneda.getRedondeo(), MathContext.ROUND_HALF_UP);
			} else {
				importeCuota = total.divide(new BigDecimal(plan.cantidadCuotas)).setScale(2, MathContext.ROUND_HALF_UP);
			}

			for (var i:int = 0; i < plan.cantidadCuotas; i++) {
				var importe:BigDecimal = importeCuota;

				var cuotaDoc:CuotaDocumento = new CuotaDocumento();
				cuotaDoc.documento = documento;
				cuotaDoc.numero = i + 1;
				cuotaDoc.fecha = vencimiento;
				cuotaDoc.importe = importe.toString();

				this.cuotas.addItem(cuotaDoc);

				acumCuotas = acumCuotas.add(importe);
				vencimiento = DateUtil.clone(vencimiento).date;
				addMonthsToDate(vencimiento, plan.separacionMes);
				addDaysToDate(vencimiento, plan.separacionDia);
			}
		} else {
			var numeroFact:int = 1;
			var decimales:int = plan.acumularDecimales ? this.documento.moneda.getRedondeo() : 2;
			for each (var ppc:PlanPagosCuota in plan.planPagosCuotas) {
				addMonthsToDate(vencimiento, plan.separacionMes);
				addDaysToDate(vencimiento, plan.separacionDia);
				vencimiento = DateUtil.clone(vencimiento).date;

				var importe2:BigDecimal = total.multiply(new BigDecimal(ppc.porcentaje)).divide(new BigDecimal(100)).setScale(decimales, MathContext.ROUND_HALF_UP); //, decimales, 4);

				var cuota:CuotaDocumento = new CuotaDocumento()
				cuota.documento = documento;
				cuota.numero = numeroFact++;
				cuota.fecha = vencimiento;
				cuota.importe = importe2.toString();

				this.cuotas.addItem(cuota);
				acumCuotas = acumCuotas.add(importe2);
			}
		}

		var diferencia:BigDecimal = total.subtract(acumCuotas);

		var _iterator:ArrayIterator;
		if (diferencia.signum() > 0) {
			_iterator = new ArrayIterator(cuotas.source);
		} else {
			_iterator = new ArrayIterator(cuotas.source.reverse());
		}

		var valueToAdd:BigDecimal = redondeoMinValue.multiply(new BigDecimal(diferencia.signum()));
		while ((diferencia.signum() != 0) && (_iterator.hasNext())) {
			var cuotaa:CuotaDocumento = (CuotaDocumento)(_iterator.next());
			cuotaa.importe = (new BigDecimal(cuotaa.importe).add(valueToAdd)).toString();
			diferencia = diferencia.subtract(valueToAdd);
		}
	}

	public function validate():Boolean {
		if (getSumaCuotas().compareTo(new BigDecimal(documento.total)) != 0) {
			return false;
		}
		return true;
	}

	public function getSumaCuotas():BigDecimal {
		if (this.cuotas == null) {
			return BigDecimal.ZERO;
		}
		var sum:BigDecimal = BigDecimal.ZERO;
		for each (var cuota:CuotaDocumento in this.cuotas) {
			sum = sum.add(new BigDecimal(cuota.importe));
		}
		return sum;
	}
	
	public function  getCuotasCubiertas(monto:BigDecimal):int {
		var cuotasCubiertas:int = 0;
		var sumaCuotas:BigDecimal = BigDecimal.ZERO;
		for each(var cuotaDocumento:CuotaDocumento in this.cuotas) {
			var sumaCuotasTemp:BigDecimal  = sumaCuotas.add(new BigDecimal(cuotaDocumento.importe));
			if (sumaCuotasTemp.compareTo(monto) > 0) {
				break;
			}
			sumaCuotas = sumaCuotasTemp;
			cuotasCubiertas++;
		}
		return cuotasCubiertas;
	}

	public function isEmpty():Boolean {
		return this.cuotas.length == 0;
	}
	
	public function  sumarCuotas(desde:int, hasta:int):BigDecimal {
		var suma:BigDecimal = BigDecimal.ZERO;
		for (var i:int = desde; i <= hasta; i++) {
			var importeCuota:BigDecimal = new BigDecimal(CuotaDocumento(this.cuotas.getItemAt(i)).importe);
			suma = suma.add(importeCuota);
		}
		return suma;
	}
	
	public function calcularDeuda(today:Date, cancelado:BigDecimal):BigDecimal {
		var primerCuotaSinCancelar:int = getCuotasCubiertas(cancelado);
		
		if (primerCuotaSinCancelar > this.cuotas.length) {
			return BigDecimal.ZERO;
		}
		
		var favorable:BigDecimal = cancelado.subtract(sumarCuotas(0, primerCuotaSinCancelar - 1));
		
		var deuda:BigDecimal = BigDecimal.ZERO;
		
		for (var i:int = primerCuotaSinCancelar; i < this.cuotas.length; i++) {
			var cuota:CuotaDocumento = CuotaDocumento(this.cuotas.getItemAt(i));
			var importe:BigDecimal = new BigDecimal(cuota.importe).subtract(favorable);
			var retraso:int = cuota.getRetrasoDias(today);
			var importeConDto:BigDecimal = this.documento.comprobante.aplicarDescuentoPrometido(importe, retraso);
			deuda = deuda.add(importeConDto);
			
			favorable = BigDecimal.ZERO;
		}
		
		return deuda;
	}
	
	public function calcularPorcentageDescuento(today:Date, cancelado:BigDecimal, categoriaCliente:String):BigDecimal {
		var primerCuotaSinCancelar:int = getCuotasCubiertas(cancelado);
		
		if (primerCuotaSinCancelar >= this.cuotas.length) {
			return BigDecimal.ZERO;
		}
				
		var cuota:CuotaDocumento = CuotaDocumento(this.cuotas.getItemAt(primerCuotaSinCancelar));
		var retraso:int = cuota.getRetrasoDias(today);
		var descuento:BigDecimal = cuota.documento.comprobante.getDescuentoPrometido(retraso, categoriaCliente);
		
		return descuento;
	}

}

}
