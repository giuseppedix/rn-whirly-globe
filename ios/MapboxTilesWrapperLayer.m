#import "MapboxTilesWrapperLayer.h"

#import <WhirlyGlobeComponent.h>
#import <MapboxVectorTiles.h>
#import <MaplyComponent.h>

@implementation MapboxTilesWrapperLayer {
    MaplyMBTileSource * _source;
    MaplyQuadPagingLayer * _layer;
}

@synthesize flipY = _flipY;
@synthesize singleLevelLoading = _singleLevelLoading;

- (instancetype)initWithMBTileSource:(MaplyMBTileSource *__nonnull)source {
    self = [super init];
    if (self) {
        _source = source;
        _layer = nil;
    }
    return self;
}

- (MaplyQuadPagingLayer *)getLatestLayer {
    return _layer;
}

- (MaplyQuadPagingLayer *)generateLayerByVc:(MaplyBaseViewController *)controller {
    if (_source == nil) {
        return nil;
    }
    MaplyVectorStyleSimpleGenerator * simpleStyle = [[MaplyVectorStyleSimpleGenerator alloc] initWithViewC:controller];
    MapboxVectorTilesPagingDelegate * mapBoxTiles = [[MapboxVectorTilesPagingDelegate alloc] initWithMBTiles:_source style:simpleStyle viewC:controller];
    _layer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:_source.coordSys delegate:mapBoxTiles];
    _layer.singleLevelLoading = _singleLevelLoading;
    _layer.importance = 512*512*2;
    _layer.flipY = _flipY;
    return _layer;
}

- (void)destroy {
    _source = nil;
    _layer = nil;
}

@end
