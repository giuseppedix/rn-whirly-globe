
#import "RNWhirlyGlobeMapManager.h"
#import "RNWhirlyGlobeMapView.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#else
#import "RCTBridge.h"
#endif

#if __has_include(<React/RCTUIManager.h>)
#import <React/RCTUIManager.h>
#else
#import "RCTUIManager.h"
#endif

#import <Foundation/Foundation.h>

@implementation RNWhirlyGlobeMapManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(globeMap, BOOL)

RCT_EXPORT_VIEW_PROPERTY(locationTracking, BOOL)

- (UIView *)view
{
    return [[RNWhirlyGlobeMapView alloc] init];
}

- (void)rejectInvalidArgumentError:(RCTPromiseRejectBlock)reject
                            ByView:(id)view
{
    reject(@"Invalid argument",
           [NSString stringWithFormat:@"Invalid view returned from registry, expecting RNWhirlyGlobeMap, got: %@", view],
           NULL);
}

#pragma mark exported RNWhirlyGlobeMapView methods

RCT_EXPORT_METHOD(addTilesLayer:(nonnull NSNumber *)reactTag
                         config:(nonnull NSDictionary *)config
                       resolver:(RCTPromiseResolveBlock)resolve
                       rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            NSString *uuid = [view createTilesLayer:config];
            if (uuid != NULL) {
                resolve(@{@"uuid": uuid});
            } else {
                reject(@"Invalid config", @"Maybe it was empty", NULL);
            }
        }
    }];
}

RCT_EXPORT_METHOD(addScreenMarker:(nonnull NSNumber *)reactTag
                           config:(nonnull NSDictionary *)config
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        }
        else {
            NSString *uuid = [view createScreenMarker:config];
            if (uuid != NULL) {
                resolve(@{@"uuid": uuid});
            } else {
                reject(@"Invalid config", @"Maybe it was empty", NULL);
            }
        }
    }];
}

RCT_EXPORT_METHOD(addScreenLabel:(nonnull NSNumber *)reactTag
                          config:(nonnull NSDictionary *)config
                        resolver:(RCTPromiseResolveBlock)resolve
                        rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            NSString *uuid = [view createScreenLabel:config];
            if (uuid != NULL) {
                resolve(@{@"uuid": uuid});
            } else {
                reject(@"Invalid config", @"Maybe it was empty", NULL);
            }
        }
    }];
}

RCT_EXPORT_METHOD(addVectorObject:(nonnull NSNumber *)reactTag
                           config:(nonnull NSDictionary *)config
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            NSString *uuid = [view createVectorObject:config];
            if (uuid != NULL) {
                resolve(@{@"uuid": uuid});
            } else {
                reject(@"Invalid config", @"Maybe it was empty", NULL);
            }
        }
    }];
}

RCT_EXPORT_METHOD(removeMapObject:(nonnull NSNumber *)reactTag
                             uuid:(nonnull NSString *)uuid
                         resolver:(RCTPromiseResolveBlock)resolve
                         rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            [view removeMapObjectByUUID:uuid];
            resolve(NULL);
        }
    }];
}

RCT_EXPORT_METHOD(removeMapTilesLayer:(nonnull NSNumber *)reactTag
                                 uuid:(nonnull NSString *)uuid
                             resolver:(RCTPromiseResolveBlock)resolve
                             rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            [view removeTilesLayerByUUID:uuid];
            resolve(NULL);
        }
    }];
}

RCT_EXPORT_METHOD(startLocationTracking:(nonnull NSNumber *)reactTag
                                 config:(nonnull NSDictionary *)config
                               resolver:(RCTPromiseResolveBlock)resolve
                               rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            [view startLocationTracking:config];
            resolve(NULL);
        }
    }];
}

RCT_EXPORT_METHOD(stopLocationTracking:(nonnull NSNumber *)reactTag
                              resolver:(RCTPromiseResolveBlock)resolve
                              rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            [view stopLocationTracking];
            resolve(NULL);
        }
    }];
}

RCT_EXPORT_METHOD(animateToPosition:(nonnull NSNumber *)reactTag
                             config:(nonnull NSDictionary *)config
                           resolver:(RCTPromiseResolveBlock)resolve
                           rejecter:(RCTPromiseRejectBlock)reject)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager,
                                        NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[RNWhirlyGlobeMapView class]]) {
            [self rejectInvalidArgumentError:reject ByView:view];
        } else {
            float  lon  = config[@"lon"] && [config[@"lon"] isKindOfClass:[NSNumber class]] ? [config[@"lon"] floatValue] : 0.0f;
            float  lat  = config[@"lat"] && [config[@"lat"] isKindOfClass:[NSNumber class]] ? [config[@"lat"] floatValue] : 0.0f;
            double time = config[@"time"] && [config[@"time"] isKindOfClass:[NSNumber class]] ? [config[@"time"] doubleValue] : 0.0;
            if (lon + lat + (float)time > 0) {
                [view animateToPositionLon:lon Lat:lat ByTime:time];
            }
            resolve(NULL);
        }
    }];
}

@end
