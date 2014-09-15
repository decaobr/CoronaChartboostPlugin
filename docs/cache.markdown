#### Overview

Caches a Chartboost interstitial, Rewarded Video or More Apps screen for instant loading of future display.

## Syntax

```
chartboost.cache( adType, [namedLocation] )
```

This function can take two argument.

##### adType - (required)

*String.* One of the following values:  
`"interstitial"`  
`"rewardedVideo"`  
`"moreApps"`

##### namedLocation - (optional)

*String.* The name of the cached location.  
  
If no location is given, the legacy default location will be used.  

Although you can specify any string you like, Chartboost recommends to use one of their predefined locations to help keep eCPM's as high as possible.  
For a list of predefined locations, see below.

#### Example

```
-- Require the Chartboost library
local chartboost = require( "plugin.chartboost" )
    
-- Cache an interstitial
chartboost.cache( "Startup" )

-- Cache the more apps screen
chartboost.cache( "moreApps" )
```

#### Predefined locations
| Location | Description|
|:---|:---|
|"Default"|Legacy default location| 
|"Startup"|Initial startup of game| 
|"Home Screen"| Home screen the player first sees|
|"Main Menu" | Menu that provides game options|
|"Game Screen" | Game screen where all the magic happens|
|"Achievements" | Screen with list of achievements in the game|
|"Quests" | Quest, missions or goals screen describing  things for a player to do|
|"Pause" | Pause screen|
|"Level Start" | Start of the level|
|"Level Complete" | Completion of the level|
|"Turn Complete" | Finishing a turn in a game|   
|"IAP Store" | The store where the player pays real money for currency|
|"Item Store" | The store where a player buys virtual goods|
|"Game Over" | The game over screen after a player is finished playing|
|"Leaderboard" | List of leaders in the game|
|"Settings" | Screen where player can change settings such as sound|
|"Quit" | Screen displayed right before the player exits a game|
