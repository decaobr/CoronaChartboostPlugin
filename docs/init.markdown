## Overview

Initializes the Chartboost library. This function is required and must be executed before making other Chartboost calls such as `chartboost.show()`.

IMPORTNANT! Please note that you must also implement [chartboost.startSession](https://github.com/swipeware/CoronaChartboostPlugin/tree/modernized/docs/startSession.markdown).

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

## Listener events


```
event.name: "chartboost"
    event.type: "interstitial"
        event.response: "willDisplay"
            -- sent before an ad is displayed
            event.location: namedLocation (string)
            
        event.response: "didDisplay"
            -- sent when an ad is displayed
            event.location: namedLocation (string)
            
        event.response: "closed"
            -- sent when an ad is closed
            event.location: namedLocation (string)
            
        event.response: "clicked"
            -- sent when an ad is clicked
            event.location: namedLocation (string)       
            
        event.response: "cached"
            -- sent when an ad is cached
            event.location: namedLocation (string)
            
        event.response: "failed"                    
            -- sent when an ad has failed to load
            event.location: namedLocation (string)
            event.info: detailed error info (string)

    event.type: "rewardedVideo"
        event.response: "willDisplay"            
            -- sent before an ad is displayed
            event.location: namedLocation (string)
            
        event.response: "didDisplay"
            -- sent when an ad is displayed
            event.location: namedLocation (string)
            
        event.response: "closed"
            -- sent when an ad is closed
            event.location: namedLocation (string)
            
        event.response: "clicked"
            -- sent when an ad is clicked
            event.location: namedLocation (string)
            
        event.response: "cached"
            -- sent when an ad is cached
            event.location: namedLocation (string)
            
        event.response: "failed"
            -- sent when an ad has failed to load
            event.location: namedLocation (string)
            event.info: detailed error info (string)
            
        event.response: "reward" 
            -- Sent when a video has been viewed, and a reward should be given
            event.location: namedLocation (string)
            event.info: reward amount (number in string)
            (Reward amount is specified in the Chartboost dashboard)

    event.type: "moreApps"
        event.response: "willDisplay"
            -- sent before More Apps is displayed
            event.location: namedLocation (string)
            
        event.response: "didDisplay"
            -- sent when More Apps is displayed
            event.location: namedLocation (string)
            
        event.response: "closed"
            -- sent when More Apps is closed
            event.location: namedLocation (string)
            
        event.response: "clicked"
            -- sent when an app in More Apps is clicked
            event.location: namedLocation (string)
            
        event.response: "cached"
            -- sent when More Apps is cached
            event.location: namedLocation (string)
            
        event.response: "failed"
            -- sent when More Apps has failed to load
            event.location: namedLocation (string)
            event.info: detailed error info (string)

```
  
#### Error codes (given in event.info)

```
0    Unknown internal error
1    Network is currently unavailable
2    Too many requests are pending for that location
3    Interstitial loaded with wrong orientation
4    Interstitial disabled, first session
5    Network request failed
6    No ad received (no inventory / no campaigns)
7    Session not started
8    User manually cancelled the impression
9    No location detected
10   Video prefetching did not complete

```
  
## Example

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