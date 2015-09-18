## Overview

Returns whether a Rewarded Video is cached or not.

## Syntax

```
chartboost.hasCachedRewardedVideo( namedLocation )
```
This function takes one or zero arguments.

##### namedLocation - (optional)

*String.* The named location of the Rewarded Video. If omitted, this will return whether or not the default Rewarded Video location is cached or not.


## Example
```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Is the Rewarded Video cached?
print( "Has cached rewarded video: " .. tostring(chartboost.hasCachedRewardedVideo() ));
```
