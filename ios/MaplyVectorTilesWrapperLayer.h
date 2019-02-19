#import <Foundation/Foundation.h>

#import <MaplyQuadPagingLayer.h>
#import <MaplyBaseViewController.h>

@interface MaplyVectorTilesWrapperLayer : NSObject

- (instancetype)initWithMapFilePath:(NSString *__nonnull)path;

- (MaplyQuadPagingLayer *)generateLayerByVc:(MaplyBaseViewController *)controller;

- (MaplyQuadPagingLayer *)getLatestLayer;

- (void)destroy;

@property (assign, nonatomic) bool flipY;

@property (assign, nonatomic) int drawPriority;

@property (assign, nonatomic) bool singleLevelLoading;

@property (assign, nonatomic) int numSimultaneousFetches;

@end
