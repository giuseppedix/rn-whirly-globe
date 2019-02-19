#import "MaplyVectorTilesWrapperLayer.h"

#import <WhirlyGlobeComponent.h>
#import <MaplyComponent.h>

@implementation MaplyVectorTilesWrapperLayer {
    NSString * _mapFilePath;
    MaplyQuadPagingLayer * _layer;
}

@synthesize flipY = _flipY;
@synthesize drawPriority = _drawPriority;
@synthesize singleLevelLoading = _singleLevelLoading;
@synthesize numSimultaneousFetches = _numSimultaneousFetches;

- (instancetype)initWithMapFilePath:(NSString *__nonnull)path {
    self = [super init];
    if (self) {
        _mapFilePath = path;
        _layer = nil;
    }
    return self;
}

- (MaplyQuadPagingLayer *)generateLayerByVc:(MaplyBaseViewController *)controller {
    MaplyVectorTiles * vecTiles = [[MaplyVectorTiles alloc] initWithDatabase: _mapFilePath viewC:controller];
    MaplyQuadPagingLayer * layer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:[[MaplySphericalMercator alloc] initWebStandard] delegate:vecTiles];
    if (_numSimultaneousFetches > 0) {
        layer.numSimultaneousFetches = _numSimultaneousFetches;
    }
    _layer.singleLevelLoading = _singleLevelLoading;
    _layer.drawPriority = _drawPriority;
    _layer.importance = 512*512*2;
    _layer.flipY = _flipY;
    return layer;
}

- (MaplyQuadPagingLayer *)getLatestLayer {
    return _layer;
}

- (void)destroy {
    _mapFilePath = nil;
    _layer = nil;
}

@end
