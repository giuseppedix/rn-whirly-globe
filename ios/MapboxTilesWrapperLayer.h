#import <Foundation/Foundation.h>

#import <MaplyMBTileSource.h>
#import <MaplyQuadPagingLayer.h>
#import <MaplyBaseViewController.h>

@interface MapboxTilesWrapperLayer : NSObject

- (instancetype)initWithMBTileSource:(MaplyMBTileSource *__nonnull)source;

- (MaplyQuadPagingLayer *)generateLayerByVc:(MaplyBaseViewController *)controller;

- (MaplyQuadPagingLayer *)getLatestLayer;

- (void)destroy;

@property (assign, nonatomic) bool flipY;

@property (assign, nonatomic) bool singleLevelLoading;

@end
