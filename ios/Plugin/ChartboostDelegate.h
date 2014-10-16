//
//  ChartboostDelegate.h
//  Plugin
//
//  Created by Ingemar Bergmark on 14-10-16.
//
//

#ifndef Plugin_ChartboostDelegate_h
#define Plugin_ChartboostDelegate_h

// The ChartboostDelegate delegate
@interface ChartboostDelegate: NSObject <ChartboostDelegate>

// Should we display the loading view for more apps?
@property (nonatomic, assign) bool cbShouldDisplayLoadingViewForMoreApps;
// Should we display more apps?
@property (nonatomic, assign) bool cbShouldDisplayMoreApps;
// Should we display rewarded videos?
@property (nonatomic, assign) bool cbShouldDisplayRewardedVideos;
// Should we display interstitials
@property (nonatomic, assign) bool cbShouldDisplayInterstitial;

// Reference to the current Lua listener function
@property (nonatomic) Corona::Lua::Ref listenerRef;
// Pointer to the current Lua state
@property (nonatomic, assign) lua_State *L;

- (NSString *) getErrorInfo:(CBLoadError)error;
@end

#endif
