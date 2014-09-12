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
            -- sent before an ad is displayed
            event.location: namedLocation    
            
        event.phase: "didDisplay"
            -- sent when an ad is displayed
            event.location: namedLocation    
            
        event.phase: "closed"
            -- sent when an ad is closed
            event.location: namedLocation    
            
        event.phase: "clicked"
            -- sent when an ad is clicked
            event.location: namedLocation                
            
        event.phase: "cached"
            -- sent when an ad is cached
            event.location: namedLocation    
            
        event.phase: "load"                    
            -- sent when an ad has failed to load
            event.location: namedLocation    
            event.result: "failed"

    event.type: "rewardedVideo"
        event.phase: "willDisplay"            
            -- sent before an ad is displayed
            event.location: namedLocation    
            
        event.phase: "didDisplay"
            -- sent when an ad is displayed
            event.location: namedLocation    
            
        event.phase: "closed"
            -- sent when an ad is closed
            event.location: namedLocation    
            
        event.phase: "clicked"
            -- sent when an ad is clicked
            event.location: namedLocation                
            
        event.phase: "cached"
            -- sent when an ad is cached
            event.location: namedLocation    
            
        event.phase: "load"
            -- sent when an ad has failed to load
            event.location: namedLocation    
            event.result: "failed"
            
        event.phase: "reward" 
            -- Sent when a video has been viewed, and a reward should be given
            event.location: namedLocation    

    event.type: "moreApps"
        event.phase: "willDisplay"
            -- sent before More Apps is displayed
            event.location: namedLocation    
            
        event.phase: "didDisplay"
            -- sent when More Apps is displayed
            event.location: namedLocation    
            
        event.phase: "closed"
            -- sent when More Apps is closed
            event.location: namedLocation    
            
        event.phase: "clicked"
            -- sent when an app in More Apps is clicked
            event.location: namedLocation    
            
        event.phase: "cached"
            -- sent when More Apps is cached
            event.location: namedLocation    
            
        event.phase: "load"
            -- sent when More Apps has failed to load
            event.location: namedLocation    
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