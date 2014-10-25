## Overview

Enable or disable the auto cache feature (Enabled by default).  

If set to true the Chartboost SDK will automatically attempt to cache an impression
once one has been consumed via a "show" call.  If set to false, it is the responsibility of the developer to manage the caching behavior of Chartboost impressions.

## Syntax

`````
chartboost.autoCacheAds( [shouldCache] )
`````

This function takes one argument:

##### shouldCache - (optional)

*Boolean.*   (true | false) Default is true.


## Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Turn off auto caching
chartboost.autoCacheAds( false )

```
