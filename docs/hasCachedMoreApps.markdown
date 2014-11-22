## Overview

Returns whether a more apps page is cached or not.

## Syntax

```
chartboost.hasCachedMoreApps( namedLocation )
```

This function takes one or zero arguments.

##### namedLocation - (optional)

*String.* The named location of the More Apps screen. If omitted, this will return whether or not the default more apps location is cached or not.


## Example
```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Is the More Apps page cached?
print( "Has cached interstitial: " .. chartboost.hasCachedMoreApps() );
```