## Overview

Force close an active impression.  
(Only available on Android. On iOS it does nothing.)

## Syntax

```
chartboost.closeImpression()
```

## Example
```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- close the active ad
chartboost.closeImpression()
```