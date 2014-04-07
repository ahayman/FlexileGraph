//
//  FlxAxis.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxAxis.h"
#import "FlxGraphSpace.h"
#import "FlxAxisTickGenerator.h"

@implementation FlxAxis{
    FlxAxisSpace _axisSpace;
    FlxGraphSpace *_graphSpace;
    
    //Anchoring
    FlxAxisAnchor _anchorType;
    double _graphSpaceAnchor;
    UIRectEdge _sideAnchor;
    CGFloat _anchorOffset;
    
    BOOL _axisNeedsLayout;
    
    //Ticks
    __weak id <FlxAxisTickDelegate> _tickDelegate;
    FlxAxisTickGenerator *_tickGenerator;
    CGSize _majorTickSize;
    CGSize _minorTickSize;
    NSUInteger _majorTickCount;
    double *_majorTicks;
    NSUInteger _minorTickCount;
    double *_minorTicks;
    
    NSMutableArray *_majorTickLayers;
    NSMutableArray *_majorTickCache;
    NSMutableArray *_minorTickLayers;
    NSMutableArray *_minorTickCache;
}
#pragma mark - Class
#pragma mark - Init
- (id) init{
    if (self = [super init]){
        _majorTickLayers = [NSMutableArray new];
        _majorTickCache = [NSMutableArray new];
        _minorTickLayers = [NSMutableArray new];
        _minorTickCache = [NSMutableArray new];
        
        _majorTickSize = CGSizeMake(1, 6);
        _minorTickSize = CGSizeMake(1, 4);
        
        self.lineColor = [UIColor blackColor];
        self.lineWidth = 1.0f;
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
- (CALayer *) _newMajorTick{
    CALayer *layer = [CALayer new];
    layer.frame = ({
        CGRect frame = CGRectZero;
        frame.size.width = (_axisSpace == FlxAxisSpaceX) ? _majorTickSize.width : _majorTickSize.height;
        frame.size.height = (_axisSpace == FlxAxisSpaceX) ? _majorTickSize.height : _majorTickSize.width;
        frame;
    });
    layer.backgroundColor = self.strokeColor;
    return layer;
}
- (CALayer *) _newMinorTick{
    CALayer *layer = [CALayer new];
    layer.frame = ({
        CGRect frame = CGRectZero;
        frame.size.width = (_axisSpace == FlxAxisSpaceX) ? _minorTickSize.width : _minorTickSize.height;
        frame.size.height = (_axisSpace == FlxAxisSpaceX) ? _minorTickSize.height : _minorTickSize.width;
        frame;
    });
    layer.backgroundColor = self.strokeColor;
    return layer;
}
- (BOOL) _visibleInRange:(FlxGraphRange *)range{
    CGFloat anchorPosition = [self _anchorPosition];
    CGFloat axisSpan = MAX(_majorTickSize.height, MAX(_minorTickSize.height, _axisWidth));
    CGFloat lower = anchorPosition - (axisSpan / 2);
    CGFloat upper = anchorPosition + axisSpan;
    CGFloat upperBounds = (_axisSpace == FlxAxisSpaceX) ? self.bounds.size.height : self.bounds.size.width;
    return ((lower >= 0 && lower <= upperBounds) || (upper >= 0 && upper <= upperBounds));
}
- (CGFloat) _anchorPosition{
    switch (_anchorType) {
        case FlxAxisAnchorSide:
            return ({
                CGFloat anchor = 0;
                if (_sideAnchor & UIRectEdgeBottom && _axisSpace == FlxAxisSpaceX){
                    anchor = self.bounds.size.height;
                } else if (_sideAnchor & UIRectEdgeRight && _axisSpace == FlxAxisSpaceY){
                    anchor = self.bounds.size.width;
                }
                anchor += _anchorOffset;
                anchor;
            });
        case FlxAxisAnchorSpace:
            return ({
                FlxGraphRange *range = self.axisRange;
                double rangeToSpace = (_axisSpace == FlxAxisSpaceX) ? self.bounds.size.height / range.boundSpan : self.bounds.size.width / range.boundSpan;
                double position = (range.lowerBounds + _graphSpaceAnchor) * rangeToSpace;
                position;
            });
    }
}
- (void) _performAxisLayout{
    if (_axisNeedsLayout){
        [self layoutAxis];
    }
}
#pragma mark - Interface
- (void) setLineColor:(UIColor *)lineColor{
    [self setStrokeColor:lineColor.CGColor];
}
- (UIColor *) lineColor{
    return [UIColor colorWithCGColor:self.strokeColor];
}
#pragma mark Anchoring
- (void) setAnchorType:(FlxAxisAnchor)anchorType{
    _anchorType = anchorType;
    [self setAxisNeedsLayout];
}
- (FlxAxisAnchor) anchorType{
    return _anchorType;
}
- (void) setGraphSpaceAnchor:(double)graphSpaceAnchor{
    _graphSpaceAnchor = graphSpaceAnchor;
    _anchorType = FlxAxisAnchorSpace;
    [self setAxisNeedsLayout];
}
- (double) graphSpaceAnchor{
    return _graphSpaceAnchor;
}
- (void) setSideAnchor:(UIRectEdge)sideAnchor{
    _sideAnchor = sideAnchor;
    _anchorType = FlxAxisAnchorSide;
    [self setAxisNeedsLayout];
}
- (UIRectEdge) sideAnchor{
    return _sideAnchor;
}
- (FlxGraphRange *) axisRange{
    if (_graphSpace){
        return _axisSpace == FlxAxisSpaceX ? _graphSpace.xRange : _graphSpace.yRange;
    }
    return nil;
}
#pragma mark Tick Generation
- (void) setTickDelegate:(id<FlxAxisTickDelegate>)tickDelegate{
    if (tickDelegate){
        _tickDelegate = tickDelegate;
    } else {
        _tickDelegate = _tickGenerator = [FlxAxisTickGenerator new];
    }
}
- (id <FlxAxisTickDelegate>) tickDelegate{
    return _tickDelegate;
}
#pragma mark Layout
- (void) setAxisNeedsLayout{
    if (!_axisNeedsLayout){
        _axisNeedsLayout = YES;
        [self performSelector:@selector(_performAxisLayout) withObject:nil afterDelay:0];
    }
}
- (void) layoutAxis{
    _axisNeedsLayout = NO;
    
    FlxGraphRange *axisRange = self.axisRange;
    
    if (![self _visibleInRange:axisRange]){
        if (_majorTickLayers.count){
            for (CALayer *layer in _majorTickLayers){
                [layer removeFromSuperlayer];
            }
            [_majorTickCache addObjectsFromArray:_majorTickLayers];
            [_majorTickLayers removeAllObjects];
        }
        if (_minorTickLayers.count){
            for (CALayer *layer in _minorTickLayers){
                [layer removeFromSuperlayer];
            }
            [_minorTickCache addObjectsFromArray:_minorTickLayers];
            [_minorTickLayers removeAllObjects];
        }
        self.path = nil;
        return;
    }
    
    if ([_tickDelegate axis:self needsMajorUpdateInRange:axisRange]){
        if (_majorTickCount){
            _majorTickCount = 0;
            free(_majorTicks);
        }
        _majorTicks = [_tickDelegate majorTicksInRange:axisRange tickCount:&_majorTickCount forAxis:self];
    }
    
    if ([_tickDelegate axis:self needsMinorUpdateInRange:axisRange]){
        if (_minorTickCount){
            _minorTickCount = 0;
            free(_minorTicks);
        }
        _minorTicks = [_tickDelegate minorTicksInRange:axisRange tickCount:&_minorTickCount forAxis:self];
    }
    
    BOOL animate = (_majorTickCount != _majorTickLayers.count || _minorTickCount != _minorTickLayers.count);
    if (animate){
        [CATransaction begin];
        [CATransaction setAnimationDuration:.1];
        [CATransaction setCompletionBlock:^{
            for (CALayer *layer in _minorTickCache) [layer removeFromSuperlayer];
            for (CALayer *layer in _majorTickCache) [layer removeFromSuperlayer];
        }];
    }
    
    CABasicAnimation *displayingOpacity = nil;
    if (_majorTickCount > _majorTickLayers.count || _minorTickCount > _minorTickLayers.count){
        displayingOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        displayingOpacity.fromValue = @0;
        displayingOpacity.toValue = @1;
    }
    
    CABasicAnimation *disappearingOpacity = nil;
    if (_majorTickCount < _majorTickLayers.count || _minorTickCount < _minorTickLayers.count){
        disappearingOpacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        disappearingOpacity.fromValue = @1;
        disappearingOpacity.toValue = @0;
    }
    
    //Generate/remove Major Ticks
    while (_majorTickCount > _majorTickLayers.count && _majorTickCache.count > 0) {
        CALayer *layer = _majorTickCache.lastObject;
        [_majorTickCache removeLastObject];
        [self addSublayer:layer];
        [_majorTickLayers addObject:layer];
        [layer addAnimation:displayingOpacity forKey:displayingOpacity.keyPath];
    }
    while (_majorTickCount > _majorTickLayers.count){
        CALayer *layer = [self _newMajorTick];
        [self addSublayer:layer];
        [_majorTickLayers addObject:layer];
        [layer addAnimation:displayingOpacity forKey:displayingOpacity.keyPath];
    }
    while (_majorTickCount < _majorTickLayers.count){
        CALayer *layer = _majorTickLayers.lastObject;
        [_majorTickLayers removeLastObject];
        [_majorTickCache addObject:layer];
        [layer addAnimation:disappearingOpacity forKey:disappearingOpacity.keyPath];
    }
    
    //Generate/remove minor ticks
    while (_minorTickCount > _minorTickLayers.count && _minorTickCache > 0){
        CALayer *layer = _minorTickCache.lastObject;
        [_minorTickLayers removeLastObject];
        [self addSublayer:layer];
        [_minorTickLayers addObject:layer];
        [layer addAnimation:displayingOpacity forKey:displayingOpacity.keyPath];
    }
    while (_minorTickCount > _minorTickLayers.count){
        CALayer *layer = [self _newMinorTick];
        [self addSublayer:layer];
        [_minorTickLayers addObject:layer];
        [layer addAnimation:displayingOpacity forKey:displayingOpacity.keyPath];
    }
    while (_minorTickCount < _minorTickLayers.count){
        CALayer *layer = _minorTickLayers.lastObject;
        [_minorTickLayers removeLastObject];
        [_minorTickCache addObject:layer];
        [layer addAnimation:disappearingOpacity forKey:disappearingOpacity.keyPath];
    }
    
    //Layout present ticks
    CGFloat axisPosition = [self _anchorPosition];
    CGPoint axisPoint = CGPointZero;
    if (_axisSpace == FlxAxisSpaceX){
        axisPoint.y = axisPosition;
        double graphToSpace = self.bounds.size.width / axisRange.boundSpan;
        double valueAnchor = axisRange.lowerBounds;
        
        for (int i = 0; i < _majorTickCount; i++){
            axisPoint.x = (_majorTicks[i] - valueAnchor) * graphToSpace;
            [(CALayer *)_majorTickLayers[i] setPosition:axisPoint];
        }
        
        for (int i = 0; i < _minorTickCount; i++){
            axisPoint.x = (_minorTicks[i] - valueAnchor) * graphToSpace;
            [(CALayer *)_minorTickLayers[i] setPosition:axisPoint];
        }
        
        //Line path
        axisPoint.x = (axisRange.lowerBounds >= axisRange.rangeMin) ? 0 : (axisRange.rangeMin - valueAnchor) * graphToSpace;
        CGPoint endPoint = axisPoint;
        endPoint.x = (axisRange.upperBounds <= axisRange.rangeMin) ? self.bounds.size.width : (axisRange.rangeMax - valueAnchor) * graphToSpace;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, axisPoint.x, axisPoint.y);
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
        self.path = path;
        
    } else {
        axisPoint.x = axisPosition;
        double graphToSpace = self.bounds.size.height / axisRange.boundSpan;
        double valueAnchor = axisRange.upperBounds;
        
        for (int i = 0; i < _majorTickCount; i++){
            axisPoint.y = (valueAnchor - _majorTicks[i]) * graphToSpace;
            [(CALayer *)_majorTickLayers[i] setPosition:axisPoint];
        }
        
        for (int i = 0; i < _minorTickCount; i++){
            axisPoint.y = (valueAnchor - _minorTicks[i]) * graphToSpace;
            [(CALayer *)_minorTickLayers[i] setPosition:axisPoint];
        }
        
        //Line path
        axisPoint.y = (axisRange.lowerBounds >= axisRange.rangeMin) ? self.bounds.size.height : (valueAnchor - axisRange.rangeMin) * graphToSpace;
        CGPoint endPoint = axisPoint;
        endPoint.y = (axisRange.upperBounds <= axisRange.rangeMin) ? 0 : (valueAnchor - axisRange.rangeMax) * graphToSpace;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, axisPoint.x, axisPoint.y);
        CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
        self.path = path;
        
    }
    
    if (animate){
        [CATransaction commit];
    }
}
#pragma mark - Protocol
#pragma mark - Overridden
- (void) setStrokeColor:(CGColorRef)strokeColor{
    if (!strokeColor) strokeColor = [UIColor blackColor].CGColor;
    [super setStrokeColor:strokeColor];
    
    for (CALayer *layer in _majorTickCache){ layer.backgroundColor = strokeColor; }
    for (CALayer *layer in _majorTickLayers) { layer.backgroundColor = strokeColor; }
    for (CALayer *layer in _minorTickCache) { layer.backgroundColor = strokeColor; }
    for (CALayer *layer in _minorTickLayers) { layer.backgroundColor = strokeColor; }
}
@end
