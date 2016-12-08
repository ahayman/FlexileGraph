//
//  FlxScatterPlot.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/26/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxScatterPlot.h"
#import "FlxGraphSpace.h"

@implementation FlxScatterPlot{
    NSMutableArray *_cachedLayers;
    NSMutableArray *_layers;
}
#pragma mark - Class
#pragma mark - Init
- (id) init{
    if (self = [super init]){
        self.lineWidth = 1.0f;
        self.strokeColor = [UIColor blackColor].CGColor;
        self.fillColor = nil;
        _cachedLayers = [NSMutableArray new];
        _layers = [NSMutableArray new];
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
- (CALayer *) _newPlotLayer{
    if (_pointLayerClass){
        CALayer *layer = (CALayer *)[_pointLayerClass new];
        layer.frame = CGRectMake(0, 0, _plotLayerSize.width, _plotLayerSize.height);
        return layer;
    } else {
        FlxPlotPoint *layer = [FlxPlotPoint new];
        layer.type = _pointType;
        layer.frame = CGRectMake(0, 0, _plotLayerSize.width, _plotLayerSize.height);
        return layer;
    }
}
- (void) _clearlayers{
    [_cachedLayers removeAllObjects];
    for (CALayer *layer in _layers){
        [layer removeFromSuperlayer];
    }
    [_layers removeAllObjects];
}
#pragma mark - Interface
#pragma mark - Protocol
#pragma mark - Overridden
- (CGPathRef) graphPath{
    FlxGraphRange *xRange = self.graphSpace.xRange;
    FlxGraphRange *yRange = self.graphSpace.yRange;
    if (xRange && yRange && _xData.dataProperties.count && _yData && _xData.dataProperties.count >= _yData.dataProperties.count){
        NSRange dataRange;
        double *xData = [_xData doublesLimitedToRange:xRange boundingRange:&dataRange];
        if (!dataRange.length) return nil;
        double *yData = [_yData doublesInRange:dataRange];
        NSUInteger upperIdx = dataRange.length;
        
        double xSpan = self.bounds.size.width;
        double ySpan = self.bounds.size.height;
        
        double xLower = xRange.lowerBounds;
        double xUpper = xRange.upperBounds;
        double yLower = yRange.lowerBounds;
        double yUpper = yRange.upperBounds;
        
        double xFactor = xSpan / ((xUpper - xLower) ?: 1);
        double yFactor = ySpan / ((yUpper - yLower) ?: 1);
        
        if (!_layerDelegate){
            while (dataRange.length > _layers.count && _cachedLayers.count > 0) {
                CALayer *layer = _cachedLayers.lastObject;
                [_cachedLayers removeLastObject];
                [self addSublayer:layer];
                [_layers addObject:layer];
            }
            while (dataRange.length > _layers.count){
                CALayer *layer = [self _newPlotLayer];
                [self addSublayer:layer];
                [_layers addObject:layer];
            }
            while (dataRange.length < _layers.count){
                CALayer *layer = _layers.lastObject;
                [_layers removeLastObject];
                [_cachedLayers addObject:layer];
                [layer removeFromSuperlayer];
            }
        }
        
        double x = 0, y = 0;
        CGFloat resolution = 1.0f / [UIScreen mainScreen].scale;
        CGFloat resStart = 0, resEnd = 0 + resolution;
        
        NSUInteger idx = 0;
        
        
        resStart = floor(x / resolution) * resolution;
        resEnd = resStart + resolution;
        
        double cY = (yUpper - yData[idx]) * yFactor;
        x = (xData[idx] - xLower) * xFactor;
        BOOL findMin = NO;
        
        if (dataRange.length > self.bounds.size.width / resolution){
            while (idx <= upperIdx){
                findMin = (cY > y) ? NO : YES;
                while (x < resEnd && idx <= upperIdx){
                    cY = (yUpper - yData[idx]) * yFactor;
                    y = findMin ? fmin(cY, y) : fmax(cY, y);
                    idx++;
                    x = (xData[idx] - xLower) * xFactor;
                }
                
                CALayer *layer = ({
                    CALayer *layer;
                    if (_layerDelegate){
                        layer = [_layerDelegate plotLayerForRecord:idx inScatterPlot:self];
                    } else {
                        layer = _layers[idx];
                    }
                    layer;
                });
                
                layer.position = CGPointMake(resStart, y);
                
                resStart = floor(x / resolution) * resolution;
                resEnd = resStart + resolution;
                cY = (yUpper - yData[idx]) * yFactor;
            }
        } else {
            for (; idx <= upperIdx; idx++){
                CALayer *layer = ({
                    CALayer *layer;
                    if (_layerDelegate){
                        layer = [_layerDelegate plotLayerForRecord:idx inScatterPlot:self];
                    } else {
                        layer = _layers[idx];
                    }
                    layer;
                });
                
                layer.position = CGPointMake((xData[idx] - xLower) * xFactor, (yUpper - yData[idx]) * yFactor);
            }
        }
        
    }
    return nil;
}
- (void) setPointLayerClass:(Class)pointLayerClass{
    if (!pointLayerClass || [pointLayerClass isSubclassOfClass:[CALayer class]]){
        _pointLayerClass = pointLayerClass;
        [self _clearlayers];
        [self layoutGraph];
    }
}
- (void) setPlotLayerSize:(CGSize)plotLayerSize{
    _plotLayerSize = plotLayerSize;
    
    if (!_layerDelegate){
        for (CALayer *layer in _layers){
            CGPoint position = layer.position;
            layer.frame = CGRectMake(0, 0, plotLayerSize.width, plotLayerSize.height);
            layer.position = position;
        }
        for (CALayer *layer in _cachedLayers){
            layer.frame = CGRectMake(0, 0, plotLayerSize.width, plotLayerSize.height);
        }
    }
}
- (void) setPointType:(FlxPlotPointType)pointType{
    _pointType = pointType;
    
    if (!_pointLayerClass && !_layerDelegate){
        for (FlxPlotPoint *layer in _cachedLayers){
            layer.type = _pointType;
        }
        for (FlxPlotPoint *layer in _layers){
            layer.type = _pointType;
        }
    }
    
}
@end
