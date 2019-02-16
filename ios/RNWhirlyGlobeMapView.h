

#if __has_include(<React/RCTComponent.h>)
#import <React/RCTComponent.h>
#else
#import "RCTComponent.h"
#endif

#if __has_include(<React/RCTView.h>)
#import <React/RCTView.h>
#else
#import "RCTView.h"
#endif

#import <MaplyLocationTracker.h>

@interface RNWhirlyGlobeMapView : RCTView<MaplyLocationTrackerDelegate>

- (void)animateToPositionLon:(float)lon Lat:(float)lat ByTime:(double)time;

- (NSString *)createTilesLayer:(NSDictionary *)config;

- (NSString *)createVectorObject:(NSDictionary *)config;
- (NSString *)createScreenMarker:(NSDictionary *)config;
- (NSString *)createScreenLabel:(NSDictionary *)config;

- (void)removeMapObjectByUUID:(NSString *)uuid;
- (void)removeTilesLayerByUUID:(NSString *)uuid;

- (void)startLocationTracking:(NSDictionary *)config;
- (void)stopLocationTracking;

@end
