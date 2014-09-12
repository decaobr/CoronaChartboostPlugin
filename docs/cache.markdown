#### Overview

Caches a Chartboost interstitial or More Apps screen for instant loading of future display.

## Syntax

```
chartboost.cache( namedLocation )
```

This function takes a single argument.

##### namedLocation - (optional)

*String.* The name of the cached location. For caching of the More Apps screen, set this value to `"moreApps"`, for caching a specific interstitial, you may specify any string.
  
If no location is given, the default location `"Game Over"` is used.

(Although you can specify any string you like, Chartboost recommends to use one of their predefined locations to help keep eCPM's as high as possible)

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
