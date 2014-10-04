//
//  chartboostDelegate.java
//  Chartboost Plugin
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

// Package name
package plugin.chartboost;

// Android Imports
import android.content.Context;

// JNLua imports
import com.naef.jnlua.LuaState;
import com.naef.jnlua.LuaType;

// Corona Imports
import com.ansca.corona.CoronaActivity;
import com.ansca.corona.CoronaEnvironment;
import com.ansca.corona.CoronaLua;
import com.ansca.corona.CoronaRuntime;
import com.ansca.corona.CoronaRuntimeTask;
import com.ansca.corona.CoronaRuntimeTaskDispatcher;
import com.ansca.corona.storage.FileContentProvider;

// Java/Misc Imports
import java.math.BigDecimal;
import org.json.JSONException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.io.File;

// Android Imports
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.UriMatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.graphics.drawable.Drawable;
import android.widget.ImageView;
import android.R;
import android.R.drawable;

// Chartboost Imports
import com.chartboost.sdk.*;
import com.chartboost.sdk.Model.CBError.CBImpressionError;

// Chartboost class
public class chartboostDelegate extends ChartboostDelegate
{
    // Event task
    private static class LuaCallBackListenerTask implements CoronaRuntimeTask 
    {
        private int fLuaListenerRegistryId;
        private String fType = null;
        private String fPhase = null;
        private String fResult = null;
        private String fLocation = null;

        public LuaCallBackListenerTask( int luaListenerRegistryId, String type, String phase ) 
        {
            fLuaListenerRegistryId = luaListenerRegistryId;
            fType = type;
            fPhase = phase;
        }

        public LuaCallBackListenerTask( int luaListenerRegistryId, String type, String phase, String result ) 
        {
            fLuaListenerRegistryId = luaListenerRegistryId;
            fType = type;
            fPhase = phase;
            fResult = result;
        }

        public LuaCallBackListenerTask( int luaListenerRegistryId, String type, String phase, String result, String location ) 
        {
            fLuaListenerRegistryId = luaListenerRegistryId;
            fType = type;
            fPhase = phase;
            fResult = result;
            fLocation = location;
        }

        @Override
        public void executeUsing( CoronaRuntime runtime )
        {
            try 
            {
                // Fetch the Corona runtime's Lua state.
                final LuaState L = runtime.getLuaState();

                // Dispatch the lua callback
                if ( CoronaLua.REFNIL != fLuaListenerRegistryId ) {
                    // Setup the event
                    CoronaLua.newEvent( L, "chartboost" );

                    // Type
                    L.pushString( fType );
                    L.setField( -2, "type" );

                    // Phase (DEPRECATED. Use 'response' instead)
                    L.pushString( fPhase );
                    L.setField( -2, "phase" );

                    // Response
                    L.pushString( fPhase );
                    L.setField( -2, "response" );

                    // Result
                    if ( fResult != null && ! fResult.isEmpty() ) {
                        L.pushString( fResult );
                        L.setField( -2, "info" );
                    }

                    // Location
                    if ( fLocation != null ) {
                        L.pushString( fLocation );
                        L.setField( -2, "location" );
                    }

                    // Dispatch the event
                    CoronaLua.dispatchEvent( L, fLuaListenerRegistryId, 0 );
                }
            }
            catch ( Exception ex ) 
            {
                ex.printStackTrace();
            }
        }
    }
    
    // Interstitals
    @Override
    public boolean shouldRequestInterstitial( String location )
    {
        return true;
    }

    @Override
    public boolean shouldDisplayInterstitial( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "interstitial", "willDisplay", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );

        return true;
    }

    @Override
    public void didCacheInterstitial( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "interstitial", "cached", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didFailToLoadInterstitial( String location, CBImpressionError error )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, 
                    "interstitial", "failed", String.format("%s", error.name()), location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didDismissInterstitial( String location )
    {
        // No need to use. Called on Close/Click
    }

    @Override
    public void didCloseInterstitial( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "interstitial", "closed" , "", location);

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didClickInterstitial( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "interstitial", "clicked" , "", location);

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didDisplayInterstitial( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "interstitial", "didDisplay", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    // Rewarded Video
    @Override
    public boolean shouldDisplayRewardedVideo( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "rewardedVideo", "willDisplay", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );

        return true;
    }

    @Override
    public void didCacheRewardedVideo( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "rewardedVideo", "cached", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didFailToLoadRewardedVideo( String location, CBImpressionError error )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, 
            "rewardedVideo", "failed", String.format("%s", error.name()), location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didDismissRewardedVideo( String location )
    {
        // No need to use. Called on Close/Click
    }

    @Override
    public void didCloseRewardedVideo( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "rewardedVideo", "closed" , "", location);

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didClickRewardedVideo( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "rewardedVideo", "clicked" , "", location);

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didDisplayRewardedVideo( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "rewardedVideo", "didDisplay", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didCompleteRewardedVideo(String location, int reward)
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        String rewardStr = Integer.toString(reward);
        
        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "rewardedVideo", "reward", rewardStr, location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );        
    }

    // More Apps
    @Override
    public boolean shouldRequestMoreApps( String location )
    {
        return true;
    }

    @Override
    public boolean shouldDisplayMoreApps( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "moreApps", "willDisplay", "", location);

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );

        return true;
    }

    @Override
    public void didFailToLoadMoreApps( String location, CBImpressionError error )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, 
            "moreApps", "failed", String.format("%s", error.name()), location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );        
    }

    @Override
    public void didCacheMoreApps( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "moreApps", "cached", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );        
    }

    @Override
    public void didDismissMoreApps( String location )
    {
        // no need to use. called on close/click
    }

    @Override
    public void didCloseMoreApps( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "moreApps", "closed", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didClickMoreApps( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "moreApps", "clicked", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }

    @Override
    public void didDisplayMoreApps( String location )
    {
        // Corona runtime task dispatcher
        final CoronaRuntimeTaskDispatcher dispatcher = new CoronaRuntimeTaskDispatcher( chartboostHelper.luaState );

        // Create the task
        LuaCallBackListenerTask task = new LuaCallBackListenerTask( chartboostHelper.listenerRef, "moreApps", "didDisplay", "", location );

        // Send the task to the Corona runtime asynchronously.
        dispatcher.send( task );
    }
}