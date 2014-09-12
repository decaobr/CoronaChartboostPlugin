#### Overview

Shows a Chartboost static interstitial, video interstitial or More Apps screen.  

**Note:** Video interstitials are shown by passing `"interstitial"` to this function.  
For video interstitials to show you must set up a Video campaign and assign it to your apps in your Chartboost dashboard.

## Syntax

`````
chartboost.show( adType, namedLocation )
`````

This function takes two arguments:

##### adType - (required)

*String.* The type of advertisement to show. Valid values are `"interstitial"` or  `"moreApps"`.

##### namedLocation - (optional)

*String.* The name of the cached advertisement location. See chartboost.cache() for more information.

#### Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Show an interstitial
chartboost.show( "interstitial" )

-- Show a more apps screen
chartboost.show( "moreApps" )
```
