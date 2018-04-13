//------------------------------------------------------------------------------
// Copyright Notice 
// (C) Copyright 2009. All Rights Reserved 
// THIS IS UNPUBLISHED PROPRIETARY SOURCE CODE OF FullTime. 
// The copyright notice above does not evidence any actual or intended publication of such  
// source code 
//------------------------------------------------------------------------------

package util {
/**
 * DateUtil class for simple date manipulation.
 *
 * You can do simple time alterations with this calss.  Here are some samples.
 *
 * Subtract a day:
 *         DateUtil.now.subtract(DateUtil.DATE, 1).date;
 *
 * Add a month:
 *         DateUtil.now.add(DateUtil.MONTH, 1).date;
 *
 * Go to Monday:
 *         DateUtil.now.assign(DateUtil.DAY, 1).date
 *
 * @author Jeremy Pyne jeremy.pyne@gmail.com
 */
public class DateUtil {
	public static const DATE:String = "date";
	public static const DAY:String = "day";
	public static const HOURS:String = "hours";

	public static const MILLISECONDS:String = "milliseconds";
	public static const MINUTES:String = "minutes";
	public static const MONTH:String = "month";
	public static const SECONDS:String = "seconds";
	public static const YEAR:String = "fullYear";

	/**
	 * Date storage object.
	 */
	private var _date:Date;

	/**
	 * Create a new DateUtil class.
	 *
	 * @param date
	 */
	public function DateUtil(date:Date) {
		_date = date;
	}

	/**
	 * Add some value to a variable.
	 *
	 * @param variable
	 * @param value
	 * @return
	 */
	public function add(variable:String, value:Number):DateUtil {
		if (variable == DateUtil.DAY) {
			variable = DateUtil.DATE;
		}

		_date[variable] += value;
		return this;
	}

	/**
	 * Subtract some value to a variable.
	 *
	 * @param variable
	 * @param value
	 * @return
	 */
	public function subtract(variable:String, value:Number):DateUtil {
		if (variable == DateUtil.DAY) {
			variable = DateUtil.DATE;
		}

		_date[variable] -= value;
		return this;
	}

	/**
	 * Set some value to a variable.
	 *
	 * @param variable
	 * @param value
	 * @return
	 */
	public function assign(variable:String, value:Number):DateUtil {
		if (variable == DateUtil.DAY) {
			variable = DateUtil.DATE;
			value = _date.date + value - _date.day;
		}

		_date[variable] = value;
		return this;
	}

	/**
	 * Get a variable.
	 *
	 * @param variable
	 * @return
	 */
	public function fetch(variable:String):Number {
		return _date[variable];
	}

	/**
	 * Get only the current date.
	 *
	 * @return
	 */
	public function get date():Date {
		var date:Date = new Date(_date.time);
		date.hours = date.minutes = date.seconds = date.milliseconds = 0;
		return date;
	}

	/**
	 * Get only the current time.
	 *
	 * @return
	 */
	public function get time():Date {
		var date:Date = new Date(_date.time);
		date.fullYear = 1969;
		date.month = date.date = 0;
		return date;
	}

	/**
	 * Get the full date and time.
	 *
	 * @return
	 */
	public function get datetime():Date {
		var date:Date = new Date(_date.time);
		return date;
	}

	/**
	 * Create a new DateUtil for the current data and time.
	 *
	 * @return
	 */
	public static function get now():DateUtil {
		return new DateUtil(new Date);
	}

	/**
	 * Create a new DateUtil for the passed in date.  Updates will not effect the original date.
	 *
	 * @return
	 */
	public static function clone(date:Date):DateUtil {
		return new DateUtil(new Date(date.time));
	}

	/**
	 * Create a new DateUtil for the passed in date. Updates will alter the original date.
	 *
	 * @return
	 */
	public static function create(date:Date):DateUtil {
		return new DateUtil(date);
	}
	
	public static function compareDates(date1:Date, date2:Date):Number {
		var date1Timestamp:Number = date1.getTime();
		var date2Timestamp:Number = date2.getTime();
		
		var result:Number = -1;
		
		if (date1Timestamp == date2Timestamp) {
			result = 0;
		} else if (date1Timestamp > date2Timestamp) {
			result = 1;
		}
		return result;
	}

}
}
