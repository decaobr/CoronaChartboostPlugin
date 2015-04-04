// ----------------------------------------------------------------------------
// ChartboostPlugin.mm
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

#import "ChartboostPlugin.h"


// ----------------------------------------------------------------------------

@class UIViewController;

namespace Corona
{

// ----------------------------------------------------------------------------

class chartboostLibrary
{
	public:
		typedef chartboostLibrary Self;

	public:
		static const char kName[];
		
	public:
		static int Open( lua_State *L );
		static int Finalizer( lua_State *L );
		static Self *ToLibrary( lua_State *L );

	protected:
		chartboostLibrary();
		bool Initialize( void *platformContext );
		
	public:
		UIViewController* GetAppViewController() const { return fAppViewController; }

	public:
		static int init( lua_State *L );
		static int startSession( lua_State *L );
		static int config( lua_State *L );
		static int show( lua_State *L );
		static int cache( lua_State *L );
		static int hasCachedInterstitial( lua_State *L );
		static int hasCachedMoreApps( lua_State *L );
		static int hasCachedRewardedVideo( lua_State *L );
        static int autoCacheAds( lua_State *L );
        static int closeImpression( lua_State *L );
        static int isAnyAdVisible( lua_State *L );
		static int prefetchVideo( lua_State *L );
		static int getPluginVersion( lua_State *L );

	private:
		UIViewController *fAppViewController;
};

// ----------------------------------------------------------------------------

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char chartboostLibrary::kName[] = "plugin.chartboost";

// Plugin version
const char *chartboostPluginVersion = "iOS SDK 5.1.5 rev 2";

// Pointer to the Chartboost Delegate
ChartboostDelegate *chartBoostDelegate;

int chartboostLibrary::Open( lua_State *L )
{
	// Register __gc callback
	const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
	CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
	
	//CoronaLuaInitializeGCMetatable( L, kMetatableName, Finalizer );
	void *platformContext = CoronaLuaGetContext( L );

	// Set library as upvalue for each library function
	Self *library = new Self;

	if ( library->Initialize( platformContext ) )
	{
		// Functions in library
		static const luaL_Reg kFunctions[] =
		{
			{ "init", init },
			{ "startSession", startSession },
			{ "show", show },
			{ "cache", cache },
			{ "hasCachedInterstitial", hasCachedInterstitial },
			{ "hasCachedMoreApps", hasCachedMoreApps },
			{ "hasCachedRewardedVideo", hasCachedRewardedVideo },
            { "autoCacheAds", autoCacheAds },
            { "closeImpression", closeImpression },
            { "isAnyAdVisible", isAnyAdVisible },
			{ "prefetchVideo", prefetchVideo },
			{ "config", config },
			{ "getPluginVersion", getPluginVersion },
			{ NULL, NULL }
		};

		// Register functions as closures, giving each access to the
		// 'library' instance via ToLibrary()
		{
			CoronaLuaPushUserdata( L, library, kMetatableName );
			luaL_openlib( L, kName, kFunctions, 1 ); // leave "library" on top of stack
		}
	}

	return 1;
}

int chartboostLibrary::Finalizer( lua_State *L )
{
	Self *library = (Self *)CoronaLuaToUserdata( L, 1 );
	delete library;
		
	// Free the Lua listener
	Corona::Lua::DeleteRef( chartBoostDelegate.L, chartBoostDelegate.listenerRef );
	chartBoostDelegate.listenerRef = NULL;
	
	// Release the chartboost delegate
	[chartBoostDelegate release];
	chartBoostDelegate = nil;

	return 0;
}

chartboostLibrary* chartboostLibrary::ToLibrary( lua_State *L )
{
	// library is pushed as part of the closure
	Self *library = (Self *)CoronaLuaToUserdata( L, lua_upvalueindex( 1 ) );
	return library;
}

chartboostLibrary::chartboostLibrary()
:	fAppViewController( nil )
{
}

bool chartboostLibrary::Initialize( void *platformContext )
{
	bool result = ( ! fAppViewController );

	if ( result )
	{
		id<CoronaRuntime> runtime = (id<CoronaRuntime>)platformContext;
		fAppViewController = runtime.appViewController; // TODO: Should we retain?
	}

	return result;
}
	
// [Lua] chartboost.getPluginVersion()
int chartboostLibrary::getPluginVersion( lua_State *L )
{
	lua_pushstring( L, chartboostPluginVersion );
	return 1;
}

// [Lua] chartboost.init( options )
int chartboostLibrary::init( lua_State *L )
{
	// The app id
	const char *appId = NULL;
	// The app signature
	const char *appSignature = NULL;

	// The listener reference
	Corona::Lua::Ref listenerRef = NULL;

	// If an options table has been passed
	if ( lua_type( L, -1 ) == LUA_TTABLE )
	{
		// Get listener key
		lua_getfield( L, -1, "listener" );
		if ( Lua::IsListener( L, -1, "chartboost" ) )
		{
			// Set the listener reference
			listenerRef = Corona::Lua::NewRef( L, -1 );
		}
		lua_pop( L, 1 );
		
		// Get the app id
		lua_getfield( L, -1, "appID" );
		if ( lua_type( L, -1 ) == LUA_TSTRING )
		{
			appId = lua_tostring( L, -1 );
		}
		else
		{
			luaL_error( L, "Error: App id expected, got: %s", luaL_typename( L, -1 ) );
		}
		lua_pop( L, 1 );
		
		// Get the app signature
		lua_getfield( L, -1, "appSignature" );
		if ( lua_type( L, -1 ) == LUA_TSTRING )
		{
			appSignature = lua_tostring( L, -1 );
		}
		else
		{
			luaL_error( L, "Error: App signature expected, got: %s", luaL_typename( L, -1 ) );
		}
		lua_pop( L, 1 );
	}
	// No options table passed in
	else
	{
		luaL_error( L, "Error: chartboost.init(), options table expected, got %s", luaL_typename( L, -1 ) );
	}

	// Initialize the Chartboost delegate
	if ( chartBoostDelegate == nil )
	{
		chartBoostDelegate = [[ChartboostDelegate alloc] init];
		// Assign the lua state so we can access it from within the delegate
		chartBoostDelegate.L = L;
		// Set the callback reference to the listener ref we assigned above
		chartBoostDelegate.listenerRef = listenerRef;
		// We display loading view for more apps by default
		chartBoostDelegate.cbShouldDisplayLoadingViewForMoreApps = true;
		// We allow display of more apps by default
		chartBoostDelegate.cbShouldDisplayMoreApps = true;
		// We allow display of rewarded videos by default
		chartBoostDelegate.cbShouldDisplayRewardedVideos = true;
		// We allow display of interstitials by default
		chartBoostDelegate.cbShouldDisplayInterstitial = true;
	}
	
	// If the app id isn't null
	if ( appId != NULL && appSignature != NULL)
	{
		// Begin a user session. Must not be dependent on user actions or any prior network requests.
		// Must be called every time your app becomes active.
		[Chartboost startWithAppId:[NSString stringWithUTF8String:appId]
                    appSignature  :[NSString stringWithUTF8String:appSignature]
                    delegate      :chartBoostDelegate];
        
        [Chartboost setShouldRequestInterstitialsInFirstSession:YES];
        [Chartboost setFramework: CBFrameworkCorona];
        [Chartboost setShouldDisplayLoadingViewForMoreApps:chartBoostDelegate.cbShouldDisplayLoadingViewForMoreApps ? YES : NO];
	}

	return 0;
}

// [Lua] chartboost.startSession( appId, appSignature )
int chartboostLibrary::startSession( lua_State *L )
{
	const char *appId = luaL_checkstring( L, 1 );
	const char *appSignature = luaL_checkstring( L, 2 );
	
	// Begin a user session. Must not be dependent on user actions or any prior network requests.
	// Must be called every time your app becomes active.
	[Chartboost startWithAppId:[NSString stringWithUTF8String:appId]
                appSignature  :[NSString stringWithUTF8String:appSignature]
                delegate      :chartBoostDelegate];
	
	return 0;
}
	
	
// [Lua] chartboost.config( options )
int chartboostLibrary::config( lua_State *L )
{
	// Should we display more apps?
	bool shouldDisplayMoreApps = true;
	// Should we display more apps?
	bool shouldDisplayRewardedVideos = true;
	// Should we display loading view for more apps?
	bool shouldDisplayLoadingViewForMoreApps = true;
	// Should we display interstitials?
	bool shouldDisplayInterstitial = true;

	// If an options table has been passed
	if ( lua_type( L, -1 ) == LUA_TTABLE )
	{
		// Get the more apps table
		lua_getfield( L, -1, "moreApps" );
        
		// If more apps is a table
		if ( lua_type( L, -1 ) == LUA_TTABLE )
		{
			// See if we should display more apps
			lua_getfield( L, -1, "display" );
			// Check if the display is a boolean
			if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
			{
				shouldDisplayMoreApps = lua_toboolean( L, -1 );
			}
			lua_pop( L, 1 );
			
			// See if we should display the loading view more apps
			lua_getfield( L, -1, "loadingView" );
			// Check if the loadingView is a boolean
			if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
			{
				shouldDisplayLoadingViewForMoreApps = lua_toboolean( L, -1 );
			}
			lua_pop( L, 1 );
		}
        
        lua_pop( L, 1 );
		
		// Get the interstitial table
		lua_getfield( L, -1, "interstitial" );

		// If interstitial is a table
		if ( lua_type( L, -1 ) == LUA_TTABLE )
		{
			// See if we should display interstitials
			lua_getfield( L, -1, "display" );

			// If display is a boolean
			if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
			{
				shouldDisplayInterstitial = lua_toboolean( L, -1 );
			}
			lua_pop( L, 1 );
		}
		
		lua_pop( L, 1 );

		// Get the rewarded video table
		lua_getfield( L, -1, "rewardedVideo" );

		// Check if it's a table
		if ( lua_type( L, -1 ) == LUA_TTABLE )
		{
			// See if we should display interstitials
			lua_getfield( L, -1, "display" );

			// If display is a boolean
			if ( lua_type( L, -1 ) == LUA_TBOOLEAN )
			{
				shouldDisplayRewardedVideos = lua_toboolean( L, -1 );
			}
			lua_pop( L, 1 );
		}
		
		lua_pop( L, 1 );
	}
	
	// Set the values
	chartBoostDelegate.cbShouldDisplayMoreApps = shouldDisplayMoreApps;
	chartBoostDelegate.cbShouldDisplayInterstitial = shouldDisplayInterstitial;
    chartBoostDelegate.cbShouldDisplayRewardedVideos = shouldDisplayRewardedVideos;

	chartBoostDelegate.cbShouldDisplayLoadingViewForMoreApps = shouldDisplayLoadingViewForMoreApps;
    [Chartboost setShouldDisplayLoadingViewForMoreApps:chartBoostDelegate.cbShouldDisplayLoadingViewForMoreApps ? YES : NO];

	return 0;
}

// [Lua] chartboost.cache( adType, [location] )
int chartboostLibrary::cache( lua_State *L )
{
	const char *adType = NULL;
	const char *namedLocation = NULL;

	// Get the ad type
    if ( lua_type( L, 1 ) == LUA_TSTRING ) {
        adType = lua_tostring(L, 1);
    }

	// Get the named location
	if ( lua_type( L, 2 ) == LUA_TSTRING ) {
		namedLocation = lua_tostring( L, 2 );
	}
    
    //backwards compatibility with Gremlin Interactive's v1.x library
    if (adType == NULL) { // no parameters. assume interstitial
        adType = "interstitial";

    } else if (
        (strcmp( adType, "interstitial" ) != 0) &&
        (strcmp( adType, "rewardedVideo" ) != 0) &&
        (strcmp( adType, "moreApps" ) != 0)
    ) { // assume interstitial with named location as first parameter
        adType = "interstitial";
        namedLocation = lua_tostring(L, 1);
    }
	
    // If namedLocation isn't null, then cache the location for the interstitial.
    if ( namedLocation != NULL ) {
        if ( strcmp( adType, "moreApps" ) == 0 ) {
            [Chartboost cacheMoreApps:[NSString stringWithUTF8String:namedLocation]];
        } else if ( strcmp( adType, "rewardedVideo" ) == 0 ) {
            [Chartboost cacheRewardedVideo:[NSString stringWithUTF8String:namedLocation]];
        } else {
            [Chartboost cacheInterstitial:[NSString stringWithUTF8String:namedLocation]];
        }
        
    } else {
        if ( strcmp( adType, "moreApps" ) == 0 ) {
            [Chartboost cacheMoreApps:CBLocationDefault];
        } else if ( strcmp( adType, "rewardedVideo" ) == 0 ) {
            [Chartboost cacheRewardedVideo:CBLocationDefault];
        } else {
            [Chartboost cacheInterstitial:CBLocationDefault];
        }
    }
	return 0;
}

//  [Lua] chartboost.show( adType, [namedLocation] )
int chartboostLibrary::show( lua_State *L )
{
	// if Chartboost has not been initialized
	if ( chartBoostDelegate == nil ) {
		luaL_error( L, "Error: You must call first call chartboost.init() before calling chartboost.show()\n" );
		return 0;
	}

	// Get the ad type
	const char *adType = luaL_checkstring( L, 1 );
	// The interstitial named location
	const char *namedLocation = NULL;
	
	// Get the interstitial named location
	if ( lua_type( L, 2 ) == LUA_TSTRING ) {
		namedLocation = lua_tostring( L, 2 );
	}

    // If namedLocation isn't null, then show the location for the interstitial.
    if ( namedLocation != NULL ) {
        if ( strcmp( adType, "moreApps" ) == 0 ) {
            [Chartboost showMoreApps:[NSString stringWithUTF8String:namedLocation]];
        } else if ( strcmp( adType, "rewardedVideo" ) == 0 ) {
            [Chartboost showRewardedVideo:[NSString stringWithUTF8String:namedLocation]];
        } else {
            [Chartboost showInterstitial:[NSString stringWithUTF8String:namedLocation]];
        }
        
    } else {
        if ( strcmp( adType, "moreApps" ) == 0 ) {
            [Chartboost showMoreApps:CBLocationDefault];
        } else if ( strcmp( adType, "rewardedVideo" ) == 0 ) {
            [Chartboost showRewardedVideo:CBLocationDefault];
        } else {
            [Chartboost showInterstitial:CBLocationDefault];
        }
    }
	return 0;
}
	
// [Lua] chartboost.hasCachedInterstitial( namedLocation )
int chartboostLibrary::hasCachedInterstitial( lua_State *L )
{
	const char *namedLocation = lua_tostring( L, 1 );
	
    if ( namedLocation != NULL ) {
        lua_pushboolean( L, [Chartboost hasInterstitial:[NSString stringWithUTF8String:namedLocation]] ? true : false );
    } else {
        lua_pushboolean( L, [Chartboost hasInterstitial:CBLocationDefault] ? true : false);
    }

    return 1;
}

// [Lua] chartboost.hasCachedRewardedVideo( namedLocation )
int chartboostLibrary::hasCachedRewardedVideo( lua_State *L )
{
	const char *namedLocation = lua_tostring( L, 1 );
	
    if ( namedLocation != NULL ) {
        lua_pushboolean( L, [Chartboost hasRewardedVideo:[NSString stringWithUTF8String:namedLocation]] ? true : false );
    } else {
        lua_pushboolean( L, [Chartboost hasRewardedVideo:CBLocationDefault] ? true : false );
    }

    return 1;
}

// [Lua] chartboost.hasCachedMoreApps()
int chartboostLibrary::hasCachedMoreApps( lua_State *L )
{
	const char *namedLocation = lua_tostring( L, 1 );
	
    if ( namedLocation != NULL ) {
        lua_pushboolean( L, [Chartboost hasMoreApps:[NSString stringWithUTF8String:namedLocation]] ? true : false );
    } else {
        lua_pushboolean( L, [Chartboost hasMoreApps:CBLocationDefault] ? true : false);
    }

    return 1;
}

int chartboostLibrary::autoCacheAds( lua_State *L )
{
    // if Chartboost has not been initialized
    if ( chartBoostDelegate == nil ) {
        luaL_error( L, "Error: You must call first call chartboost.init() before calling chartboost.autoCacheAds()\n" );
        return 0;
    }
    
    BOOL cacheAds = YES;
    
    // Get the ad type
    if ( lua_type( L, 1 ) == LUA_TBOOLEAN ) {
        cacheAds = lua_toboolean(L, 1) ? YES : NO;
    }
    
    [Chartboost setAutoCacheAds: cacheAds];
    
    return 0;
}
    
int chartboostLibrary::closeImpression( lua_State *L )
{
    // if Chartboost has not been initialized
    if ( chartBoostDelegate == nil ) {
        luaL_error( L, "Error: You must call first call chartboost.init() before calling chartboost.autoCacheAds()\n" );
        return 0;
    }
    
    // NOP (Only available on Android)
    
    return 0;
}
    
int chartboostLibrary::isAnyAdVisible( lua_State *L )
{
    // if Chartboost has not been initialized
    if ( chartBoostDelegate == nil ) {
        luaL_error( L, "Error: You must call first call chartboost.init() before calling chartboost.isAnyAdVisible()\n" );
        return 0;
    }
    
    lua_pushboolean( L, [Chartboost isAnyViewVisible] ? true : false);
    
    return 1;
}

int chartboostLibrary::prefetchVideo( lua_State *L )
{
	// if Chartboost has not been initialized
	if ( chartBoostDelegate == nil ) {
		luaL_error( L, "Error: You must call first call chartboost.init() before calling chartboost.prefetchVideo()\n" );
		return 0;
	}
    
    BOOL prefetch = YES;
	
    // Get the ad type
    if ( lua_type( L, 1 ) == LUA_TBOOLEAN ) {
        prefetch = lua_toboolean(L, 1) ? YES : NO;
    }
    
    [Chartboost setShouldPrefetchVideoContent: prefetch];
	
	return 0;
}


	
// ----------------------------------------------------------------------------

} // namespace Corona

//


// ----------------------------------------------------------------------------

CORONA_EXPORT
int luaopen_plugin_chartboost( lua_State *L )
{
	return Corona::chartboostLibrary::Open( L );
}
