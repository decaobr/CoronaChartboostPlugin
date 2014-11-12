## Overview

Returns whether any ad is visible or not.  
(Only available on Android at the moment)

## Syntax

```
chartboost.isAnyAdVisible()
```

## Example
```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Are any ads visible?
print( "Ad visible: " .. chartboost.isAnyAdVisible() );
```