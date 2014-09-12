#### Overview

Returns whether an Ad is cached or not.

## Syntax

`````
chartboost.hasCachedInterstitial( namedLocation )
`````

This function takes one or zero arguments.

##### namedLocation - (optional)

*String.* The named location of the Interstitial. If omitted, this will return whether or not the default Interstitial location is cached or not.

#### Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Is the default interstitial cached?
print( "Has cached interstitial: " .. chartboost.hasCachedInterstitial() );
```