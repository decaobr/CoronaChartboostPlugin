#### Overview

Initializes the Chartboost library. This function is required and must be executed before making other Chartboost calls such as `chartboost.show()`.

## Syntax

```
chartboost.init( options )
```

This function takes a single argument, `options`, which is a table that accepts the following parameters:

##### appID - (required)

*String.* Your Chartboost app ID. You can get your app ID from the [Chartboost website](https://www.chartboost.com).

##### appSignature - (required)

*String.* Your Chartboost app signature. You can get your app signature from the [Chartboost website](https://www.chartboost.com).

##### listener - (optional)

*Listener.* This function receives Chartboost events.

Event diagram:

```
event.name: "chartboost"
    event.type: "interstitial"
        event.phase: "willDisplay"
            event.location: namedLocation    
        event.phase: "didDisplay"
            event.location: namedLocation    
        event.phase: "closed"
            event.location: namedLocation    
        event.phase: "clicked"
            event.location: namedLocation                
        event.phase: "cached"
            event.location: namedLocation    
        event.phase: "load"
            event.location: namedLocation    
                event.result: "failed"

    event.type: "moreApps"
        event.phase: "willDisplay"
        event.phase: "didDisplay"
        event.phase: "closed"
        event.phase: "clicked"
        event.phase: "cached"
        event.phase: "load"
            event.result: "failed"

```
#### Example
```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

-- Initialize the Chartboost library
chartboost.init {
    appID = "app_ID_generated_from_chartboost_here",
    appSignature = "app_signature_generated_from_chartboost_here",  
    listener = function( event )
        -- Print the events key/pair values
        for k,v in pairs( event ) do
            print( k, ":", v )
        end
    end
}
```