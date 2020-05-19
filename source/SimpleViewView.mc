using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Sensor;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Application;

class SimpleViewView extends WatchUi.WatchFace {
	
	var isSleeping = false;
	var myFont;
	
    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	myFont = WatchUi.loadResource(Rez.Fonts.universalFont);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
    	dc.clear();

        // Get and show the current time
        var hour = System.getClockTime().hour;
        if(!System.getDeviceSettings().is24Hour) {
        	if(hour > 12) {
        		hour = hour - 12;
        	}
        	if(hour == 0) {
        		hour = 12;
        	}
        }
        
        var timeString = Lang.format("$1$:$2$", [hour, System.getClockTime().min.format("%02d")]);

        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$",[today.day_of_week, today.day]);
        
        var font = myFont;
		var fontDimentions = dc.getTextDimensions(timeString, font);
		var leftOfText = (dc.getWidth()/2) - (fontDimentions[0]/2);
		var topOfText = (dc.getHeight()/2) - (fontDimentions[1]/2);
		
		//prints the time in white
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(dc.getWidth()/2, topOfText, font, timeString, Graphics.TEXT_JUSTIFY_CENTER);
		
		//draws battery percentage over the hours
		if(Application.getApp().getProperty("FillHoursWithBattery") == true) {
			
			var batteryStatus = System.getSystemStats().battery/100;
			var topOfFirstRect = topOfText + (fontDimentions[1]*(1-batteryStatus)) + 1;
			var specificDimentionsFirstHalf = dc.getTextDimensions("" + hour, font);

			var batteryStatusColor = Graphics.COLOR_GREEN;
			if(Application.getApp().getProperty("ChangeBatteryColorBasedOnStatus") == true) {
				if(batteryStatus < 0.5) {
					batteryStatusColor = Graphics.COLOR_YELLOW;
				}
				if(batteryStatus < 0.2) {
					batteryStatusColor = Graphics.COLOR_RED;
				}
			}
			//print the green rect over the time
			dc.setColor(batteryStatusColor, Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle(leftOfText, topOfFirstRect, specificDimentionsFirstHalf[0], fontDimentions[1]*batteryStatus - 2);
		}

		//fills the minutes
		if(Application.getApp().getProperty("MinuteFill") != 0) {
			var minuteStatus = 0;
			if(Application.getApp().getProperty("MinuteFill") == 2) {//calories
				var calorieGoal = Application.getApp().getProperty("CalorieGoal") * 1.2;
				var calories = 0;
				if(ActivityMonitor.getInfo().calories) {
					calories = ActivityMonitor.getInfo().calories;
				}
				
				if(calories <= 0)  {
					minuteStatus = 0;
				} else if(calories >= calorieGoal) {
					minuteStatus = 1;
				} else {
					minuteStatus = (calories.toFloat() / calorieGoal.toFloat());
				}
			} else if(Application.getApp().getProperty("MinuteFill") == 1) {//steps
				var stepGoal = ActivityMonitor.getInfo().stepGoal * 1.2;
				var steps = ActivityMonitor.getInfo().steps;
				if(steps <= 0) {
					minuteStatus = 0;
				} else if(steps >= stepGoal) {
					minuteStatus = 1;
				} else {
					minuteStatus = (steps.toFloat() / stepGoal.toFloat());
				}
			}
			
			var topOfSecondRect = topOfText + (fontDimentions[1]*(1-minuteStatus)) + 1;
			var specificDimentionsSecondHalf = dc.getTextDimensions(System.getClockTime().min.format("%02d"), font);
			var leftOfSecondHalf = fontDimentions[0] - specificDimentionsSecondHalf[0] + leftOfText;
			
			//print the rect over minutes
			dc.setColor(Application.getApp().getProperty("MinuteFillColor"), Graphics.COLOR_TRANSPARENT);
			dc.fillRectangle(leftOfSecondHalf, topOfSecondRect, specificDimentionsSecondHalf[0], fontDimentions[1]*minuteStatus - 2);
		}
		
        //print the new cutout time over the rect
		dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK);
		dc.drawText(dc.getWidth()/2, topOfText, font, timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
        //print the date
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()*0.73, Graphics.FONT_SYSTEM_MEDIUM, dateString.toUpper(), Graphics.TEXT_JUSTIFY_CENTER);
        
        //prints the seconds
    	if(isSleeping == false) {
        	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        	dc.setPenWidth(15);
        	var endOfArc = (90 - (6*System.getClockTime().sec));
        	dc.drawArc((dc.getWidth()/2), (dc.getHeight()/2), (dc.getHeight()/2), Graphics.ARC_CLOCKWISE, endOfArc+1, endOfArc);
        }
        
        //draws the arc
        if(Application.getApp().getProperty("ArcFill") != 0) {
        	if(Application.getApp().getProperty("ArcFill") == 1) {//steps
        		var stepGoal = ActivityMonitor.getInfo().stepGoal;
        		var steps = ActivityMonitor.getInfo().steps;
        		if(steps >= stepGoal) {
		            dc.setColor(Application.getApp().getProperty("FinishedArcColor"), Graphics.COLOR_TRANSPARENT);
		            dc.setPenWidth(1);
		            dc.drawArc((dc.getWidth()/2), (dc.getHeight()/2), (dc.getHeight()/2) - 11, Graphics.ARC_CLOCKWISE, 90, 90);
		        } else if(steps > 0){
		            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		            var endOfStepArc = (90 - ((360.toFloat())/(stepGoal.toFloat())*(steps.toFloat())));
		            dc.setPenWidth(3);
		            dc.drawArc((dc.getWidth()/2), (dc.getHeight()/2), (dc.getHeight()/2) - 10, Graphics.ARC_CLOCKWISE, 90, endOfStepArc);
		        }
        	} else if(Application.getApp().getProperty("ArcFill") == 2) {//calories
        		var calorieGoal = Application.getApp().getProperty("CalorieGoal");
        		var calories = ActivityMonitor.getInfo().calories;
        		if(calories >= calorieGoal) {
		            dc.setColor(Application.getApp().getProperty("FinishedArcColor"), Graphics.COLOR_TRANSPARENT);
		            dc.setPenWidth(1);
		            dc.drawArc((dc.getWidth()/2), (dc.getHeight()/2), (dc.getHeight()/2) - 11, Graphics.ARC_CLOCKWISE, 90, 90);
		        } else if(calories > 0){
		            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		            var endOfStepArc = (90 - ((360.toFloat())/(calorieGoal.toFloat())*(calories.toFloat())));
		            dc.setPenWidth(3);
		            dc.drawArc((dc.getWidth()/2), (dc.getHeight()/2), (dc.getHeight()/2) - 10, Graphics.ARC_CLOCKWISE, 90, endOfStepArc);
		        }
        	}
        }
        
        if(Application.getApp().getProperty("ShowNotificationStatus") != 0) {
        	dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	        dc.fillCircle((dc.getWidth()/2), (dc.getHeight()/4) -5, 13);
	        
	        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
	        var fixForRes = 0;
	        if(dc.getHeight() == 240 && System.SCREEN_SHAPE_ROUND == 1) {
	        	fixForRes = 3;
	        }
	        
	        if(Application.getApp().getProperty("ShowNotificationStatus") == 2) {
		        if(System.getDeviceSettings().notificationCount < 10) {
		            dc.drawText((dc.getWidth()/2), (dc.getHeight()/4 - 24), Graphics.FONT_LARGE, System.getDeviceSettings().notificationCount, Graphics.TEXT_JUSTIFY_CENTER);
		        } else {
		            dc.drawText((dc.getWidth()/2), (dc.getHeight()/4 - 18 - fixForRes), Graphics.FONT_SMALL, "9+", Graphics.TEXT_JUSTIFY_CENTER);
		        }
	        } else if(Application.getApp().getProperty("ShowNotificationStatus") == 1) {
	        	dc.drawText((dc.getWidth()/2), (dc.getHeight()/4 - 24), Graphics.FONT_LARGE, "!", Graphics.TEXT_JUSTIFY_CENTER);
	        }
        }
        
        if(Application.getApp().getProperty("ShowBluetoothConnection") == true) {
	        var bluetooth;
	        if(System.getDeviceSettings().phoneConnected) {
	        	bluetooth = new Rez.Drawables.bluetooth();
	        } else {
	        	bluetooth = new Rez.Drawables.bluetooth_error();
	        }
	        bluetooth.draw(dc);
        }
        
        if(Application.getApp().getProperty("ShowAlarmsSet") == true) {
	        if(System.getDeviceSettings().alarmCount > 0) {
		        var bell = new Rez.Drawables.bell();
		        bell.draw(dc);
	        }
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    	isSleeping = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    	isSleeping = true;
    }

}
