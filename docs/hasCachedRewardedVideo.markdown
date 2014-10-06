## Overview

Returns whether a Rewarded Video is cached or not.

## Syntax

```
chartboost.hasCachedRewardedVideo()
```

## Example
```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Is the Rewarded Video cached?
print( "Has cached rewarded video: " .. chartboost.hasCachedRewardedVideo() );
```