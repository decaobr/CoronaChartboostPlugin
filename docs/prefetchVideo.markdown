## Overview

Tells the Chartboost SDK to attempt to fetch videos from the Chartboost API servers (default is true).  
Use this to tell the Chartboost SDK to control if videos should be prefetched.

## Syntax

`````
chartboost.prefetchVideo( [shouldPrefetch] )
`````

This function takes one argument:

##### shouldPrefetch - (optional)

*Boolean.*   (true | false) Default is true.


## Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Turn off prefetch
chartboost.prefetchVideo( false )

```
