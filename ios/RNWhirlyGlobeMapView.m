
#import "RNWhirlyGlobeMapView.h"

#import "UIColor+HexString.h"
#import "UIView+FindUIViewController.h"

#import <WhirlyGlobeComponent.h>
#import <MapboxVectorTiles.h>
#import <MaplyComponent.h>

#if __has_include(<React/RCTConvert.h>)
#import <React/RCTConvert.h>
#import <SafariServices/SafariServices.h>
#else
#import "RCTConvert.h"
#endif

#import "MapboxTilesWrapperLayer.h"
#import "MaplyVectorTilesWrapperLayer.h"

@implementation RNWhirlyGlobeMapView {
    MaplyBaseViewController * _mapViewController;
    NSMutableDictionary * _dataTaskObjects;
    NSMutableDictionary * _objectDescs;
    NSMutableDictionary * _objects;
    NSMutableDictionary * _layers;

    NSDictionary * _trackingConfig;

    BOOL _isChangeWhirlyGlobeVC;
    BOOL _useGlobeMap;
    BOOL _firstInit;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self preparation];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self preparation];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self preparation];
    }
    return self;
}

- (void)preparation {
    _firstInit = FALSE;
    _useGlobeMap = FALSE;
    _trackingConfig = nil;
    _mapViewController = nil;
    _isChangeWhirlyGlobeVC = FALSE;
    _layers = [[NSMutableDictionary alloc] init];
    _objects = [[NSMutableDictionary alloc] init];
    _objectDescs = [[NSMutableDictionary alloc] init];
    _dataTaskObjects = [[NSMutableDictionary alloc] init];
}

- (void)setGlobeMap:(BOOL)value {
    if (_useGlobeMap != value || !_firstInit) {
        _firstInit = TRUE;
        _useGlobeMap = value;
        _isChangeWhirlyGlobeVC = TRUE;
    }
    [self setNeedsLayout];
}
#pragma clang diagnostic pop

- (void)removeInternalMapViewController {
    if (_mapViewController != nil) {
        [_mapViewController stopLocationTracking];
        [_mapViewController stopAnimation];
        [_mapViewController removeAllLayers];
        [_mapViewController.view removeFromSuperview];
        [_mapViewController removeFromParentViewController];
    }
    _mapViewController = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_isChangeWhirlyGlobeVC) {
        [self removeInternalMapViewController];
        UIViewController *vc = [self firstAvailableUIViewController];
        if (vc != nil) {
            if (_useGlobeMap) {
                _mapViewController = [[WhirlyGlobeViewController alloc] init];
            } else {
                _mapViewController = [[MaplyViewController alloc] initWithMapType:MaplyMapTypeFlat];
            }
            [self addSubview:_mapViewController.view];
            [vc addChildViewController:_mapViewController];
            _mapViewController.clearColor = _useGlobeMap ? [UIColor blackColor] : [UIColor whiteColor];
            // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
            _mapViewController.frameInterval = 2;
            // Add tmp layers
            for (NSString * uuid in _layers) {
                if ([_layers[uuid] isKindOfClass:[MaplyViewControllerLayer class]]) {
                    if ([_layers[uuid] isKindOfClass:[MaplyQuadImageTilesLayer class]]) {
                        ((MaplyQuadImageTilesLayer *)_layers[uuid]).handleEdges = _useGlobeMap;
                        ((MaplyQuadImageTilesLayer *)_layers[uuid]).coverPoles = _useGlobeMap;
                    }
                    [_mapViewController addLayer:_layers[uuid]];
                } else if([_layers[uuid] isKindOfClass:[MapboxTilesWrapperLayer class]]) {
                    [_mapViewController addLayer:[((MapboxTilesWrapperLayer *)_layers[uuid]) generateLayerByVc:_mapViewController]];
                } else if([_layers[uuid] isKindOfClass:[MaplyVectorTilesWrapperLayer class]]) {
                    [_mapViewController addLayer:[((MaplyVectorTilesWrapperLayer *)_layers[uuid]) generateLayerByVc:_mapViewController]];
                }
            }
            // Add tmp objects on bkg thread
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                for (NSString *uuid in self->_objects) {
                    if (!self->_mapViewController) {
                        return;
                    }
                    NSDictionary *desc = self->_objectDescs[uuid] ? self->_objectDescs[uuid] : nil;
                    if ([self->_objects[uuid] isKindOfClass:[MaplyScreenMarker class]]) {
                        [self->_mapViewController addScreenMarkers:@[self->_objects[uuid]] desc:desc];
                    } else if ([self->_objects[uuid] isKindOfClass:[MaplyScreenLabel class]]) {
                        [self->_mapViewController addScreenLabels:@[self->_objects[uuid]] desc:desc];
                    } else if ([self->_objects[uuid] isKindOfClass:[MaplyVectorObject class]]) {
                        [self->_mapViewController addVectors:@[self->_objects[uuid]] desc:desc];
                    }
                }
            });
            [self initLocationTracking];
            _isChangeWhirlyGlobeVC = FALSE;
        }
    }
    if (_mapViewController != nil) {
        _mapViewController.view.frame = self.frame;
    }
}

- (void)clear {
    if (_mapViewController) {
        [_mapViewController removeAllLayers];
        [_mapViewController removeObjects:[_objects allValues]];
    }
    for (NSString * uuid in _dataTaskObjects) {
        if([_dataTaskObjects[uuid] isKindOfClass:[NSURLSessionDataTask class]]) {
            [_dataTaskObjects[uuid] cancel];
        }
    }
    [_dataTaskObjects removeAllObjects];
    [_objectDescs removeAllObjects];
    [_objects removeAllObjects];
    for (NSString * uuid in _layers) {
        if ([_layers[uuid] isKindOfClass:[MapboxTilesWrapperLayer class]]) {
            [((MapboxTilesWrapperLayer *)_layers[uuid]) destroy];
        }
    }
    [_layers removeAllObjects];
}

- (void)dealloc {
    [self clear];
    [self removeInternalMapViewController];
}

- (UIViewController *)firstAvailableUIViewController {
    return (UIViewController *) [self traverseResponderChainForUIViewController];
}

#pragma mark location tracking

- (void)initLocationTracking {
    [self stopLocationTracking];
    if (_trackingConfig && _mapViewController) {
        bool useHeading = _trackingConfig[@"useHeading"] ? [_trackingConfig[@"useHeading"] boolValue] : false;
        bool useCourse = _trackingConfig[@"useCourse"] ? [_trackingConfig[@"useCourse"] boolValue] : false;
        bool simulate = _trackingConfig[@"simulate"] ? [_trackingConfig[@"simulate"] boolValue] : false;
        [_mapViewController startLocationTrackingWithDelegate:self useHeading:useHeading useCourse:useCourse simulate:simulate];
    }
}

- (void)startLocationTracking:(NSDictionary *)config {
    _trackingConfig = config;
    [self initLocationTracking];
}

- (void)stopLocationTracking {
    if (_mapViewController) {
        [_mapViewController stopLocationTracking];
    }
    _trackingConfig = nil;
}

#pragma mark location delegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

}

#pragma mark create objects methods

- (NSString *)createScreenMarker:(NSDictionary *)config {
    if (!config) {
        return nil;
    }
    NSString *uuid = [[NSUUID UUID] UUIDString];
    MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
    marker.loc = MaplyCoordinateMakeWithDegrees(
        config[@"lon"] ? [config[@"lon"] floatValue] : 0,
        config[@"lat"] ? [config[@"lat"] floatValue] : 0
    );

    if (config[@"size"] && [config[@"size"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *size = config[@"size"];
        marker.size = CGSizeMake(
            size[@"width"] ? [size[@"width"] floatValue] : 0,
            size[@"height"] ? [size[@"height"] floatValue] : 0
        );
    }
    if (marker.size.width < 1 || marker.size.height < 1) {
        marker.size = CGSizeMake(40, 40);
    }
    if (config[@"offset"] && [config[@"offset"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *offset = config[@"offset"];
        marker.offset = CGPointMake(
            offset[@"x"] ? [offset[@"x"] floatValue] : 0,
            offset[@"y"] ? [offset[@"y"] floatValue] : 0
        );
    }
    if (config[@"color"] && [config[@"color"] isKindOfClass:[NSString class]]) {
        marker.color = [UIColor colorWithHexString:config[@"color"]];
    }
    if (config[@"rotation"] && [config[@"rotation"] isKindOfClass:[NSNumber class]]) {
        marker.rotation = [config[@"rotation"] doubleValue];
    }
    if (config[@"selectable"] && [config[@"selectable"] isKindOfClass:[NSNumber class]]) {
        marker.selectable = [config[@"selectable"] boolValue];
    }
    if (config[@"image"]) {
        marker.image = [RCTConvert UIImage:config[@"image"]];
    }
    if (_mapViewController) {
        [_mapViewController addScreenMarkers:@[marker] desc:nil];
    }
    _objects[uuid] = marker;
    return uuid;
}

- (NSString *)createScreenLabel:(NSDictionary *)config {
    if (!config) {
        return nil;
    }
    NSString *uuid = [[NSUUID UUID] UUIDString];
    MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
    label.text = config[@"text"];
    label.loc = MaplyCoordinateMakeWithDegrees(
        config[@"lon"] ? [config[@"lon"] floatValue] : 0,
        config[@"lat"] ? [config[@"lat"] floatValue] : 0
    );
    if (config[@"offset"] && [config[@"offset"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *offset = config[@"offset"];
        label.offset = CGPointMake(
            offset[@"x"] ? [offset[@"x"] floatValue] : 0,
            offset[@"y"] ? [offset[@"y"] floatValue] : 0
        );
    }
    if (config[@"rotation"] && [config[@"rotation"] isKindOfClass:[NSNumber class]]) {
        label.rotation = [config[@"rotation"] floatValue];
    }
    if (config[@"selectable"] && [config[@"selectable"] isKindOfClass:[NSNumber class]]) {
        label.selectable = [config[@"selectable"] boolValue];
    }
    // Font configuration
    float fontSize = config[@"fontSize"] ? [config[@"fontSize"] floatValue] : 14.0f;
    NSArray *names = [UIFont fontNamesForFamilyName:config[@"fontFamily"] ? config[@"fontFamily"] : @"Helvetica Neue"];
    NSDictionary * desc = @{
        kMaplyFont: names.count > 0 ? [UIFont fontWithName:names[0] size:fontSize] : [UIFont systemFontOfSize:fontSize],
        kMaplyTextOutlineSize: config[@"outlineSize"] ? config[@"outlineSize"] : @(0),
        kMaplyTextOutlineColor: config[@"outlineColor"]
            && [config[@"outlineColor"] isKindOfClass:[NSString class]] ? [UIColor colorWithHexString:config[@"outlineColor"]] : [UIColor blackColor],
        kMaplyColor: config[@"color"]
            && [config[@"color"] isKindOfClass:[NSString class]] ? [UIColor colorWithHexString:config[@"color"]] : [UIColor whiteColor]
    };
    if (_mapViewController) {
        [_mapViewController addScreenLabels:@[label] desc: desc];
    }
    _objectDescs[uuid] = desc;
    _objects[uuid] = label;
    return uuid;
}

- (NSString *)createVectorObject:(NSDictionary *)config {
    if (!config) {
        return nil;
    }
    if (!config[@"source"] || ![config[@"source"] isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    bool selectable = false;
    float lineWidth = 4.0f;
    NSDictionary *headers = @{};
    NSDictionary *source = config[@"source"];
    if (!source[@"uri"] || ![config[@"uri"] isKindOfClass:[NSString class]]) {
        return nil;
    }
    NSString *uuid = [[NSUUID UUID] UUIDString];
    if (source[@"headers"] && [source[@"headers"] isKindOfClass:[NSDictionary class]]) {
        headers = source[@"requestHeaders"];
    }
    if (config[@"selectable"] && [config[@"selectable"] isKindOfClass:[NSNumber class]]) {
        selectable = [config[@"selectable"] boolValue];
    }
    if (config[@"lineWidth"] && [config[@"lineWidth"] isKindOfClass:[NSNumber class]]) {
        lineWidth = [config[@"lineWidth"] floatValue];
    }
    NSDictionary * desc = @{
        kMaplyColor: config[@"color"] && [config[@"color"] isKindOfClass:[NSString class]] ? [UIColor colorWithHexString:config[@"color"]] : [UIColor whiteColor],
        kMaplySelectable: @(selectable),
        kMaplyVecWidth: @(lineWidth)
    };
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:source[@"uri"]]
                                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:10.0];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPMethod: source[@"method"] && [config[@"method"] isKindOfClass:[NSString class]] ? source[@"method"] : @"GET"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response,
                                                                    NSError *error) {
                                                    [self->_dataTaskObjects removeObjectForKey:uuid];
                                                    // TODO: Add error event to JS
                                                    if (error) {
                                                        NSLog(@"%@", error);
                                                    }
                                                    if (data) {
                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                                            if (!self->_mapViewController) {
                                                                return;
                                                            }
                                                            MaplyVectorObject *vectorObject = [MaplyVectorObject VectorObjectFromGeoJSON:data];
                                                            if(self->_mapViewController) {
                                                                [self->_mapViewController addVectors:@[vectorObject] desc:desc];
                                                            }
                                                            self->_objects[uuid] = vectorObject;
                                                            // TODO: Add finish loading event (only main thread)
                                                        });
                                                    }
                                                }];
    _dataTaskObjects[uuid] = dataTask;
    _objectDescs[uuid] = desc;
    [dataTask resume];
    return uuid;
}

- (void)setupTilesLayer:(id)layer FromConfig:(NSDictionary *)config {
    if (!config) {
        return;
    }
    if ([layer isKindOfClass:[MapboxTilesWrapperLayer class]]) {
        MapboxTilesWrapperLayer * wrapper = (MapboxTilesWrapperLayer *)layer;
        wrapper.singleLevelLoading = config[@"singleLevelLoading"] ? [config[@"singleLevelLoading"] boolValue] : false;
        wrapper.drawPriority = config[@"drawPriority"] && [config[@"drawPriority"] isKindOfClass:[NSNumber class]] ? [config[@"drawPriority"] intValue] : 0;
        wrapper.flipY = config[@"flipY"] ? [config[@"flipY"] boolValue] : false;
        return;
    }
    if ([layer isKindOfClass:[MaplyVectorTilesWrapperLayer class]]) {
        MaplyVectorTilesWrapperLayer * wrapper = (MaplyVectorTilesWrapperLayer *)layer;
        wrapper.singleLevelLoading = config[@"singleLevelLoading"] ? [config[@"singleLevelLoading"] boolValue] : false;
        wrapper.numSimultaneousFetches = config[@"numSimultaneousFetches"] && [config[@"numSimultaneousFetches"] isKindOfClass:[NSNumber class]] ? [config[@"numSimultaneousFetches"] intValue] : 0;
        wrapper.drawPriority = config[@"drawPriority"] && [config[@"drawPriority"] isKindOfClass:[NSNumber class]] ? [config[@"drawPriority"] intValue] : 0;
        wrapper.flipY = config[@"flipY"] ? [config[@"flipY"] boolValue] : false;
        return;
    }
    if ([layer isKindOfClass:[MaplyQuadImageTilesLayer class]]) {
        MaplyQuadImageTilesLayer * tilesLayer = (MaplyQuadImageTilesLayer *)layer;
        tilesLayer.drawPriority = config[@"drawPriority"] && [config[@"drawPriority"] isKindOfClass:[NSNumber class]] ? [config[@"drawPriority"] intValue] : 0;
        tilesLayer.singleLevelLoading = config[@"singleLevelLoading"] ? [config[@"singleLevelLoading"] boolValue] : false;
        tilesLayer.requireElev = config[@"requireElev"] ? [config[@"requireElev"] boolValue] : false;
        tilesLayer.waitLoad = config[@"waitLoad"] ? [config[@"waitLoad"] boolValue] : true;
        tilesLayer.handleEdges = _useGlobeMap;
        tilesLayer.coverPoles = _useGlobeMap;
        tilesLayer.flipY = config[@"flipY"] ? [config[@"flipY"] boolValue] : false;
        return;
    }
    if ([layer isKindOfClass:[MaplyQuadPagingLayer class]]) {
        MaplyQuadPagingLayer * tilesLayer = (MaplyQuadPagingLayer *)layer;
        tilesLayer.drawPriority = config[@"drawPriority"] && [config[@"drawPriority"] isKindOfClass:[NSNumber class]] ? [config[@"drawPriority"] intValue] : 0;
        tilesLayer.singleLevelLoading = config[@"singleLevelLoading"] ? [config[@"singleLevelLoading"] boolValue] : false;
        tilesLayer.flipY = config[@"flipY"] ? [config[@"flipY"] boolValue] : false;
        return;
    }
}

- (NSString *)createTilesLayer:(NSDictionary *)config {
    if (!config) {
        return nil;
    }
    NSString * uuid = [[NSUUID UUID] UUIDString];
    if (config[@"mb"] && [config[@"mb"] isKindOfClass:[NSString class]]) {
        if (config[@"useVectorMbTiles"] && [config[@"useVectorMbTiles"] isKindOfClass:[NSString class]]) {
            if([config[@"useVectorMbTiles"] isEqualToString:@"mapbox"]) {
                MaplyMBTileSource * tileSource = [[MaplyMBTileSource alloc] initWithMBTiles:config[@"mb"]];
                MapboxTilesWrapperLayer * wrapper = [[MapboxTilesWrapperLayer alloc] initWithMBTileSource: tileSource];
                [self setupTilesLayer:wrapper FromConfig:config];
                _layers[uuid] = wrapper;
                MaplyQuadPagingLayer * layer = [wrapper generateLayerByVc:_mapViewController];
                if (layer != nil) {
                    [_mapViewController addLayer:layer];
                }
                return uuid;
            }
            if([config[@"useVectorMbTiles"] isEqualToString:@"maply"]) {
                NSString * mapFilePath = [[NSBundle mainBundle] pathForResource:config[@"mb"] ofType:@"mbtiles"];
                MaplyVectorTilesWrapperLayer * wrapper = [[MaplyVectorTilesWrapperLayer alloc] initWithMapFilePath: mapFilePath];
                [self setupTilesLayer:wrapper FromConfig:config];
                MaplyQuadPagingLayer * layer = [wrapper generateLayerByVc:_mapViewController];
                if (layer != nil) {
                    [_mapViewController addLayer:layer];
                }
                return uuid;
            }
        }
        MaplyMBTileSource * tileSource = [[MaplyMBTileSource alloc] initWithMBTiles:config[@"mb"]];
        MaplyQuadImageTilesLayer * layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
        [self setupTilesLayer:layer FromConfig:config];
        _layers[uuid] = layer;
        return uuid;
    }
    if (config[@"source"] && [config[@"source"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary * source = config[@"source"];
        NSString * baseCacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString * tilesCacheDir = [NSString stringWithFormat:@"%@/%@/", baseCacheDir, source[@"cacheDir"] ? source[@"cacheDir"] : @"stamentiles"];
        MaplyRemoteTileSource * tileSource = [[MaplyRemoteTileSource alloc]
                                             initWithBaseURL: source[@"uri"] ? source[@"uri"] : @"http://tile.stamen.com/terrain/"
                                                         ext: source[@"ext"] ? source[@"ext"] : @"png"
                                                     minZoom: source[@"minZoom"] && [source[@"minZoom"] isKindOfClass:[NSNumber class]] ? [source[@"minZoom"] intValue] : 0
                                                     maxZoom: source[@"maxZoom"] && [source[@"maxZoom"] isKindOfClass:[NSNumber class]] ? [source[@"maxZoom"] intValue] : 18];
        tileSource.cacheDir = tilesCacheDir;
        MaplyQuadImageTilesLayer * layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
        [self setupTilesLayer:layer FromConfig:config];
        _layers[uuid] = layer;
        if(_mapViewController) {
            [_mapViewController addLayer:layer];
        }
        return uuid;
    }
    return nil;
}

#pragma mark remove objects methods

- (void)removeMapObjectByUUID:(NSString *)uuid {
    if (_dataTaskObjects[uuid] && [_dataTaskObjects[uuid] isKindOfClass:[NSURLSessionDataTask class]]) {
        [_dataTaskObjects[uuid] cancel];
    }
    [_objectDescs removeObjectForKey:uuid];
    [_dataTaskObjects removeObjectForKey:uuid];
    if (_objects[uuid]) {
        if (_mapViewController) {
            [_mapViewController removeObject:_objects[uuid]];
        }
        [_objects removeObjectForKey:uuid];
    }
}

- (void)removeTilesLayerByUUID:(NSString *)uuid {
    if (_layers[uuid]) {
        // Check layer wrappers
        if ([_layers[uuid] isKindOfClass:[MapboxTilesWrapperLayer class]]) {
            MaplyQuadPagingLayer * layer = [((MapboxTilesWrapperLayer *)_layers[uuid]) getLatestLayer];
            if (layer != nil) {
                [_mapViewController removeLayer: layer];
            }
            [((MapboxTilesWrapperLayer *)_layers[uuid]) destroy];
            return;
        } else if ([_layers[uuid] isKindOfClass:[MaplyVectorTilesWrapperLayer class]]) {
            MaplyQuadPagingLayer * layer = [((MaplyVectorTilesWrapperLayer *)_layers[uuid]) getLatestLayer];
            if (layer != nil) {
                [_mapViewController removeLayer: layer];
            }
            [((MaplyVectorTilesWrapperLayer *)_layers[uuid]) destroy];
            return;
        }
        // Base layers
        if (_mapViewController) {
            [_mapViewController removeLayer:_layers[uuid]];
        }
        [_layers removeObjectForKey:uuid];
    }
}

#pragma mark over public methods

- (void)animateToPositionLon:(float)lon Lat:(float)lat ByTime:(double)time {
    if (!_mapViewController) {
        return;
    }
    if ([_mapViewController isKindOfClass:[WhirlyGlobeViewController class]]) {
        [((WhirlyGlobeViewController *)_mapViewController) animateToPosition:MaplyCoordinateMakeWithDegrees(lon, lat) time:(NSTimeInterval)time];
    } else if ([_mapViewController isKindOfClass:[MaplyViewController class]]) {
        [((MaplyViewController *)_mapViewController) animateToPosition:MaplyCoordinateMakeWithDegrees(lon, lat) time:(NSTimeInterval)time];
    }
}

@end