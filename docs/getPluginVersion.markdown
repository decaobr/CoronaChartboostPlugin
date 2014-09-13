#### Overview

Get the version of this plugin.


## Syntax

```
chartboost.getPluginVersion()
```

This function takes no arguments.  
Returns a string with the plugin version.

#### Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

print("Chartboost Plugin version "..chartboost.getPluginVersion())
```