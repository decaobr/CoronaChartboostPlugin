#### Overview

Shows a Chartboost static interstitial, video interstitial, rewarded video or More Apps screen.  

**Note:** Non-rewarded video interstitials are shown by passing `"interstitial"` to this function. For video interstitials to show you must set up a Video campaign and assign it to your apps in your Chartboost dashboard.

## Syntax

`````
chartboost.show( adType, [namedLocation] )
`````

This function can take two arguments:

##### adType - (required)

*String.* One of the following values:  
`"interstitial"`  
`"rewardedVideo"`  
`"moreApps"`

##### namedLocation - (optional)

*String.* The name of the advertisement location. 

If no location is given, a default location will be used. For static interstitals, video interstitials and rewarded videos a location of `"Game Over"` is used. For More Apps a location of `"Home Screen"` is used.

(Although you can specify any string you like, Chartboost recommends to use one of their predefined locations to help keep eCPM's as high as possible. See [chartboost.cache()](https://github.com/swipeware/CoronaChartboostPlugin/tree/modernized/docs/cache.markdown) for more info)


#### Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Show an interstitial
chartboost.show( "interstitial" )

-- Show a more apps screen
chartboost.show( "moreApps" )
```
