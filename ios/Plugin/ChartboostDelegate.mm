// ----------------------------------------------------------------------------
//  ChartboostDelegate.mm
//
/*
The MIT License (MIT)

Copyright (c) 2014 Gremlin Interactive Limited

Updated for Chartboost SDK 5.x by Ingemar Bergmark, Swipeware (www.swipeware.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
// ----------------------------------------------------------------------------

// Apple
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Accounts/Accounts.h>
#import <AVFoundation/AVFoundation.h>
#import <AdSupport/AdSupport.h>

// Corona
#import "CoronaRuntime.h"
#include "CoronaAssert.h"
#include "CoronaEvent.h"
#include "CoronaLua.h"
#include "CoronaLibrary.h"

// Chartboost
#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>
#import <CommonCrypto/CommonDigest.h>
#import "ChartboostDelegate.h"

// Chartboost Delegate implementation

@implementation ChartboostDelegate

- (NSString *)getErrorInfo:(CBLoadError)error
{
    NSString *errorStr;
    
    switch (error) {
    case CBLoadErrorInternal:
        errorStr = @"Unknown internal error";
        break;
    case CBLoadErrorInternetUnavailable:
        errorStr = @"Network is currently unavailable";
        break;
    case CBLoadErrorTooManyConnections:
        errorStr = @"Too many requests are pending for that location";
        break;
    case CBLoadErrorWrongOrientation:
        errorStr = @"Interstitial loaded with wrong orientation";
        break;
    case CBLoadErrorFirstSessionInterstitialsDisabled:
        errorStr = @"Interstitial disabled, first session";
        break;
    case CBLoadErrorNetworkFailure:
        errorStr = @"Network request failed";
        break;
    case CBLoadErrorNoAdFound:
        errorStr = @"No ad received";
        break;
    case CBLoadErrorSessionNotStarted:
        errorStr = @"Session not started";
        break;
    case CBLoadErrorUserCancellation:
        errorStr = @"User manually cancelled the impression";
        break;
    case CBLoadErrorNoLocationFound:
        errorStr = @"No location detected";
        break;
    default:
        errorStr = @"Code not defined";
    }

    return [NSString stringWithFormat:@"Error %d: %@", error, errorStr];
}

// Interstitial delegate methods

// Called before requesting an interstitial from the backend
- (BOOL)shouldRequestInterstitial:(CBLocation)location
{
	return YES;
}

// Called when an interstitial has been received, before it is presented on screen

// Return NO if showing an interstitial is currently inappropriate, for example if the user has entered the main game mode
/*
 * shouldDisplayInterstitial
 *
 * This is used to control when an interstitial should or should not be displayed
 * The default is YES, and that will let an interstitial display as normal
 * If it's not okay to display an interstitial, return NO
 *
 * For example: during gameplay, return NO.
 *
 * Is fired on:
 * -Interstitial is loaded & ready to display
 */
- (BOOL)shouldDisplayInterstitial:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "interstitial" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "willDisplay" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );

	lua_pushstring( self.L, "willDisplay" );
	lua_setfield( self.L, -2, "response" );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
    
    // Otherwise return YES to display the interstitial
    return self.cbShouldDisplayInterstitial ? YES : NO;
}

/* 
 * didDisplayInterstitial
 *
 * This is called when an intersitital has been displayed on the screen
*/

- (void)didDisplayInterstitial:(CBLocation)location;
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "interstitial" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );
	
	lua_pushstring( self.L, "didDisplay" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );

	lua_pushstring( self.L, "didDisplay" );
	lua_setfield( self.L, -2, "response" );
    
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

/*
 * didDismissInterstitial
 *
 * This is called when an interstitial is dismissed
 *
 * Is fired on:
 * - Interstitial click
 * - Interstitial close
 *
 * #Pro Tip: Use the delegate method below to immediately re-cache interstitials
 */
- (void)didDismissInterstitial:(CBLocation)location
{
    // Fired on click and close
    // Not needed since we fire events for both
}

// Same as above, but only called when dismissed for a close
- (void)didCloseInterstitial:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "interstitial" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "closed" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
    
	lua_pushstring( self.L, "closed" );
	lua_setfield( self.L, -2, "response" );
    
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Same as above, but only called when dismissed for a click
- (void)didClickInterstitial:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "interstitial" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "clicked" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );

	lua_pushstring( self.L, "clicked" );
	lua_setfield( self.L, -2, "response" );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

/*
 * didCacheInterstitial
 *
 * Passes in the location name that has successfully been cached.
 *
 * Is fired on:
 * - All assets loaded
 * - Triggered by cacheInterstitial
 *
 * Notes:
 * - Similar to this is: cb.hasCachedInterstitial(String location)
 * Which will return true if a cached interstitial exists for that location
 */
- (void)didCacheInterstitial:(CBLocation)location
{
    // Create the event
    Corona::Lua::NewEvent( self.L, "chartboost" );
    lua_pushstring( self.L, "interstitial" );
    lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, "cached" );  // 'phase' deprecated. use 'response' instead.
    lua_setfield( self.L, -2, "phase" );
    
    lua_pushstring( self.L, "cached" );
    lua_setfield( self.L, -2, "response" );
    
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
    
    // Dispatch the event
    Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

/*
 * didFailToLoadInterstitial
 *
 * This is called when an interstitial has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No publishing campaign matches for that user (go make a new one in the dashboard)
 */
- (void)didFailToLoadInterstitial:(CBLocation)location withError:(CBLoadError)error
{
    // Create the event
    Corona::Lua::NewEvent( self.L, "chartboost" );
    lua_pushstring( self.L, "interstitial" );
    lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, "failed" );  // 'phase' deprecated. use 'response' instead.
    lua_setfield( self.L, -2, "phase" );
    
    lua_pushstring( self.L, "failed" );
    lua_setfield( self.L, -2, "response" );
    
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

    lua_pushstring( self.L, [[self getErrorInfo:error] UTF8String]);
    lua_setfield( self.L, -2, "info" );
    
    // Dispatch the event
    Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// More apps delegate methods

// Called when an more apps page has been received, before it is presented on screen
// Return NO if showing the more apps page is currently inappropriate
- (BOOL)shouldDisplayMoreApps:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "moreApps" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

	lua_pushstring( self.L, "willDisplay" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "willDisplay" );
	lua_setfield( self.L, -2, "response" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );

	return self.cbShouldDisplayMoreApps ? YES : NO;
}

/// Called when an more apps page has been displayed.
-(void)didDisplayMoreApps:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "moreApps" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );
	
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

	lua_pushstring( self.L, "didDisplay" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "didDisplay" );
	lua_setfield( self.L, -2, "response" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

/*
 * didDismissMoreApps
 *
 * This is called when the more apps page is dismissed
 *
 * Is fired on:
 * - More Apps click
 * - More Apps close
 *
 * #Pro Tip: Use the delegate method below to immediately re-cache the more apps page
 */
- (void)didDismissMoreApps:(CBLocation)location
{
    // Fired on click and close
    // Not needed since we fire events for both
}

// Same as above, but only called when dismissed for a close
- (void)didCloseMoreApps:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "moreApps" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

	lua_pushstring( self.L, "closed" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "closed" );
	lua_setfield( self.L, -2, "response" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Same as above, but only called when dismissed for a click
- (void)didClickMoreApps:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "moreApps" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

	lua_pushstring( self.L, "clicked" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "clicked" );
	lua_setfield( self.L, -2, "response" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

/*
 * didFailToLoadMoreApps
 *
 * This is called when the more apps page has failed to load for any reason
 *
 * Is fired on:
 * - No network connection
 * - No more apps page has been created (add a more apps page in the dashboard)
 * - No publishing campaign matches for that user (add more campaigns to your more apps page)
 *  -Find this inside the App > Edit page in the Chartboost dashboard
 */
- (void)didFailToLoadMoreApps:(CBLocation)location withError:(CBLoadError)error
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "moreApps" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "failed" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "failed" );
	lua_setfield( self.L, -2, "response" );
	
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

    lua_pushstring( self.L, [[self getErrorInfo:error] UTF8String]);
	lua_setfield( self.L, -2, "info" );
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Called when the More Apps page has been received and cached
- (void)didCacheMoreApps:(CBLocation)location
{
    // Create the event
    Corona::Lua::NewEvent( self.L, "chartboost" );
    lua_pushstring( self.L, "moreApps" );
    lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

    lua_pushstring( self.L, "cached" );  // 'phase' deprecated. use 'response' instead.
    lua_setfield( self.L, -2, "phase" );
    
    lua_pushstring( self.L, "cached" );
    lua_setfield( self.L, -2, "response" );
    
    Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Rewarded video delegate methods

// Called before a rewarded video will be displayed on the screen.
- (BOOL)shouldDisplayRewardedVideo:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "rewardedVideo" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");

	lua_pushstring( self.L, "willDisplay" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "willDisplay" );
	lua_setfield( self.L, -2, "response" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );

	return self.cbShouldDisplayRewardedVideos ? YES : NO;
}

// Called before a video (rewarded or interstitial) has been displayed on the screen.
- (void)willDisplayVideo:(CBLocation)location
{
    // NOP since there's no way to determine if it's a rewarded video or not
}

// Called after a rewarded video has been displayed on the screen.
- (void)didDisplayRewardedVideo:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "rewardedVideo" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );
    
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	lua_pushstring( self.L, "didDisplay" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
	
	lua_pushstring( self.L, "didDisplay" );
	lua_setfield( self.L, -2, "response" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Called after a rewarded video has been loaded from the Chartboost API
// servers and cached locally.
- (void)didCacheRewardedVideo:(CBLocation)location
{
    // Create the event
    Corona::Lua::NewEvent( self.L, "chartboost" );
    lua_pushstring( self.L, "rewardedVideo" );
    lua_setfield( self.L, -2, CoronaEventTypeKey() );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
    
    lua_pushstring( self.L, "cached" );  // 'phase' deprecated. use 'response' instead.
    lua_setfield( self.L, -2, "phase" );
    
    lua_pushstring( self.L, "cached" );
    lua_setfield( self.L, -2, "response" );
    
    Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Called after a rewarded video has attempted to load from the Chartboost API
// servers but failed.
- (void)didFailToLoadRewardedVideo:(CBLocation)location
                         withError:(CBLoadError)error
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "rewardedVideo" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "failed" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );

	lua_pushstring( self.L, "failed" );
	lua_setfield( self.L, -2, "response" );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
    lua_pushstring( self.L, [[self getErrorInfo:error] UTF8String]);
	lua_setfield( self.L, -2, "info" );
	
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}


// Called after a rewarded video has been dismissed.
- (void)didDismissRewardedVideo:(CBLocation)location
{
    // Fired on click and close
    // Not needed since we fire events for both
}

// Called after a rewarded video has been closed.
- (void)didCloseRewardedVideo:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "rewardedVideo" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "closed" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );
    
	lua_pushstring( self.L, "closed" );
	lua_setfield( self.L, -2, "response" );
    
    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Called after a rewarded video has been clicked.
- (void)didClickRewardedVideo:(CBLocation)location
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "rewardedVideo" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "clicked" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );

	lua_pushstring( self.L, "clicked" );
	lua_setfield( self.L, -2, "response" );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

// Called after a rewarded video has been viewed completely and user is eligible for reward.
- (void)didCompleteRewardedVideo:(CBLocation)location
                      withReward:(int)reward
{
	// Create the event
	Corona::Lua::NewEvent( self.L, "chartboost" );
	lua_pushstring( self.L, "rewardedVideo" );
	lua_setfield( self.L, -2, CoronaEventTypeKey() );

	lua_pushstring( self.L, "reward" );  // 'phase' deprecated. use 'response' instead.
	lua_setfield( self.L, -2, "phase" );

	lua_pushstring( self.L, "reward" );
	lua_setfield( self.L, -2, "response" );

    lua_pushstring( self.L, [location UTF8String]);
    lua_setfield( self.L, -2, "location");
    
    lua_pushstring( self.L, [[[NSNumber numberWithInt:reward] stringValue] UTF8String]);
	lua_setfield( self.L, -2, "info" );
	
	// Dispatch the event
	Corona::Lua::DispatchEvent( self.L, self.listenerRef, 1 );
}

@end