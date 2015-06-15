## Overview
| **Availability** | **Platforms**|
|---|---|
|Starter, Basic, Pro, Enterprise|Android, iOS, Amazon|


The Chartboost plugin lets you utilize Chartboost's advertisement SDK within a Corona project.

### SDK

When you build using the Corona Simulator, the server automatically takes care of integrating the plugin into your project. 

All you need to do is add a few entries into the `plugins` table of your `build.settings`. Please note that the Chartboost SDK requires Google Play Services on Android to function properly.  
  
The following is an example of a minimal `build.settings` file:

``````
settings =
{
	plugins =
	{
		["plugin.chartboost"] =
		{
			publisherId = "com.swipeware"
		},
		
		["plugin.google.play.services"] =
        {
            publisherId = "com.coronalabs",
            supportedPlatforms = { android = true }
        }
	}	
}
``````


### Platform specific notes  
**Android:**  
The following permissions will be added automatically:  
android.permission.INTERNET  
android.permission.ACCESS_NETWORK_STATE  
android.permission.WRITE_EXTERNAL_STORAGE  
  
Optional (recommended) permissions you can add:    
android.permission.ACCESS_WIFI_STATE

## Syntax

	local chartboost = require "plugin.chartboost"
	
## Sample Code

You can access sample code [here](https://github.com/swipeware/CoronaChartboostSample).

## Support

More support is available from the Swipeware team:

* [Corona Forums](http://forums.coronalabs.com/forum/645-chartboost-3rd-party/)