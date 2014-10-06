## Overview

Starts a Chartboost session after application resume.

**Note:**  
You must call this method on every application resume event. See  "applicationResume" in the [Corona documentation](http://docs.coronalabs.com/api/event/system/type.html).

## Syntax

```
chartboost.startSession( appId, appSignature )
```

This function takes two arguments:

##### appID - (required)

*String.* Your Chartboost app ID. You can get your app ID from the [](https://www.chartboost.com)Chartboost website.

##### appSignature - (required)

*String.* Your Chartboost app signature. You can get your app signature from the [](https://www.chartboost.com)Chartboost website.

## Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )

local appID = "your_CB_app_id_here"
local appSignature = "your_CB_app_signature_here"

local function systemEvent( event )
    local phase = event.phase

    if event.type == "applicationResume" then
        -- Start a ChartBoost session
        chartboost.startSession( appID, appSignature )
    end

    return true
end

-- Add the system listener
Runtime:addEventListener( "system", systemEvent )
```