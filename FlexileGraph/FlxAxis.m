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
    
    //Labelling
    UIColor *_majorFontColor;
    UIFont *_majorLabelFont;
    UIColor *_minorFontColor;
    UIFont *_minorLabelFont;
    NSMutableArray *_majorLabels;
    NSMutableArray *_majorLabelCache;
    NSMutableArray *_minorLabels;
    NSMutableArray *_minorLabelCache;
    
    //Axis Label
    CATextLayer *_axisLabel;
    
}
#pragma mark - Class
#pragma mark - Init
- (id) init{
    if (self = [super init]){
        _majorTickLayers = [NSMutableArray new];
        _majorTickCache = [NSMutableArray new];
        _minorTickLayers = [NSMutableArray new];
        _minorTickCache = [NSMutableArray new];
        
        _majorLabels = [NSMutableArray new];
        _majorLabelCache = [NSMutableArray new];
        _minorLabels = [NSMutableArray new];
        _minorLabelCache = [NSMutableArray new];
        
        _majorTickSize = CGSizeMake(1, 10);
        _minorTickSize = CGSizeMake(1, 5);
        
        self.lineColor = [UIColor blackColor];
        self.lineWidth = 2.0f;
        self.fillColor = [UIColor colorWithWhite:0 alpha:.5f].CGColor;
        self.tickDelegate = nil;
    }
    return self;
}
#pragma mark - Lazy
- (UIColor *) majorFontColor{
    if (!_majorFontColor){
        _majorFontColor = [UIColor blackColor];
    }
    return _majorFontColor;
}
- (UIFont *) majorLabelFont{
    if (!_majorLabelFont){
        _majorLabelFont = [UIFont fontWithName:@"Helvetica" size:12];
    }
    return _majorLabelFont;
}
- (UIColor *) minorFontColor{
    if (!_minorFontColor){
        _minorFontColor = [UIColor colorWithWhite:.4f alpha:1];
    }
    return _minorFontColor;
}
- (UIFont *) minorLabelFont{
    if (!_minorLabelFont){
        _minorLabelFont = [UIFont fontWithName:@"Helvetica" size:10];
    }
    return _minorLabelFont;
}
#pragma mark - Private
- (CATextLayer *) _newMajorLabel{
    CATextLayer *textLayer = [CATextLayer new];
    textLayer.font = CGFontCreateWithFontName((__bridge CFStringRef)self.majorLabelFont.fontName);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.fontSize = self.majorLabelFont.pointSize;
    textLayer.foregroundColor = self.majorFontColor.CGColor;
    return textLayer;
}
- (CATextLayer *) _newMinorLabel{
    CATextLayer *textLayer = [CATextLayer new];
    textLayer.font = CGFontCreateWithFontName((__bridge CFStringRef)self.minorLabelFont.fontName);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.fontSize = self.majorLabelFont.pointSize;
    textLayer.foregroundColor = self.minorFontColor.CGColor;
    return textLayer;
}
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
    layer.actions = @{@"onOrderOut" : [NSNull null], @"sublayers" : [NSNull null], @"contents" : [NSNull null], @"bounds" : [NSNull null], @"position" : [NSNull null]};
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
                BOOL subtractOffset = NO;
                if (_sideAnchor & UIRectEdgeBottom && _axisSpace == FlxAxisSpaceX){
                    anchor = self.bounds.size.height;
                    subtractOffset = YES;
                } else if (_sideAnchor & UIRectEdgeRight && _axisSpace == FlxAxisSpaceY){
                    anchor = self.bounds.size.width;
                    subtractOffset = YES;
                }
                
                if (subtractOffset){
                    anchor -= _anchorOffset;
                } else {
                    anchor += _anchorOffset;
                }
                anchor;
            });
        case FlxAxisAnchorSpace:
            return ({
                FlxGraphRange *range = self._axisSpaceRange;
                double rangeToSpace = (_axisSpace == FlxAxisSpaceX) ? self.bounds.size.height / range.boundSpan : self.bounds.size.width / range.boundSpan;
                double position =  0;
                if (_axisSpace == FlxAxisSpaceX){
                    position = (range.upperBounds - _graphSpaceAnchor) * rangeToSpace;
                } else {
                    position = (_graphSpaceAnchor - range.lowerBounds) * rangeToSpace;
                }
                position += _anchorOffset;
                position;
            });
    }
}
- (void) _performAxisLayout{
    if (_axisNeedsLayout){
        [self layoutAxis];
    }
}
- (FlxGraphRange *) _axisSpaceRange{
    if (_graphSpace){
        return _axisSpace == FlxAxisSpaceX ? _graphSpace.yRange : _graphSpace.xRange;
    }
    return nil;
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
        
        if (_majorLabels.count){
            for (CALayer *layer in _majorLabels){
                [layer removeFromSuperlayer];
            }
            [_majorLabelCache addObjectsFromArray:_majorLabels];
            [_majorLabels removeAllObjects];
        }
        
        if (_minorLabels.count){
            for (CALayer *layer in _minorLabels){
                [layer removeFromSuperlayer];
            }
            [_minorLabelCache addObjectsFromArray:_minorLabels];
            [_minorLabels removeAllObjects];
        }
        
        [_axisLabel removeFromSuperlayer];
        
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
    
    //Generate/remove Major Ticks
    while (_majorTickCount > _majorTickLayers.count && _majorTickCache.count > 0) {
        CALayer *layer = _majorTickCache.lastObject;
        [_majorTickCache removeLastObject];
        [self addSublayer:layer];
        [_majorTickLayers addObject:layer];
    }
    while (_majorTickCount > _majorTickLayers.count){
        CALayer *layer = [self _newMajorTick];
        [self addSublayer:layer];
        [_majorTickLayers addObject:layer];
    }
    while (_majorTickCount < _majorTickLayers.count){
        CALayer *layer = _majorTickLayers.lastObject;
        [_majorTickLayers removeLastObject];
        [_majorTickCache addObject:layer];
        [layer removeFromSuperlayer];
    }
    
    //Generate/remove minor ticks
    while (_minorTickCount > _minorTickLayers.count && _minorTickCache.count > 0){
        CALayer *layer = _minorTickCache.lastObject;
        [_minorTickCache removeLastObject];
        [self addSublayer:layer];
        [_minorTickLayers addObject:layer];
    }
    while (_minorTickCount > _minorTickLayers.count){
        CALayer *layer = [self _newMinorTick];
        [self addSublayer:layer];
        [_minorTickLayers addObject:layer];
    }
    while (_minorTickCount < _minorTickLayers.count){
        CALayer *layer = _minorTickLayers.lastObject;
        [_minorTickLayers removeLastObject];
        [_minorTickCache addObject:layer];
        [layer removeFromSuperlayer];
    }
    
    //Generate/remove labels
    NSFormatter *majorFormatter = [_labelFormatterDelegate majorLabelFormatterForRange:axisRange forAxis:self];
    BOOL majorDateFormatter = [majorFormatter isKindOfClass:[NSDateFormatter class]];
    if (majorFormatter){
        while (_majorTickCount > _majorLabels.count && _majorLabelCache.count > 0){
            CATextLayer *layer = _majorLabelCache.lastObject;
            [_majorLabelCache removeLastObject];
            
            [self addSublayer:layer];
            [_majorLabels addObject:layer];
        }
        while (_majorTickCount > _majorLabels.count){
            CATextLayer *layer = [self _newMajorLabel];
            [self addSublayer:layer];
            [_majorLabels addObject:layer];
        }
        while (_majorTickCount < _majorLabels.count){
            CALayer *layer = _majorLabels.lastObject;
            [_majorLabels removeLastObject];
            [layer removeFromSuperlayer];
            [_majorLabelCache addObject:layer];
        }
    } else {
        while (_majorLabels.count) {
            CALayer *layer = _majorLabels.lastObject;
            [_majorLabels removeLastObject];
            [layer removeFromSuperlayer];
            [_majorLabelCache addObject:layer];
        }
    }
    
    NSFormatter *minorFormatter = [_labelFormatterDelegate minorLabelFormatterForRange:axisRange forAxis:self];
    BOOL minorDateFormatter = [minorFormatter isKindOfClass:[NSDateFormatter class]];
    if (minorFormatter){
        while (_minorTickCount > _minorLabels.count && _minorLabelCache.count > 0){
            CATextLayer *layer = _minorLabelCache.lastObject;
            [_minorLabelCache removeLastObject];
            [self addSublayer:layer];
            [_minorLabels addObject:layer];
        }
        while (_minorTickCount > _minorLabels.count){
            CATextLayer *layer = [self _newMinorLabel];
            [self addSublayer:layer];
            [_minorLabels addObject:layer];
        }
        while (_minorTickCount < _minorLabels.count){
            CALayer *layer = _minorLabels.lastObject;
            [_minorLabels removeLastObject];
            [layer removeFromSuperlayer];
            [_minorLabelCache addObject:layer];
        }
    } else {
        while (_minorLabels.count){
            CALayer *layer = _minorLabels.lastObject;
            [_minorLabels removeLastObject];
            [layer removeFromSuperlayer];
            [_minorLabelCache addObject:layer];
        }
    }
    
    
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    
    //Layout present ticks
    CGFloat axisPosition = [self _anchorPosition];
    CGPoint axisPoint = CGPointZero;
    if (_axisSpace == FlxAxisSpaceX){
        axisPoint.y = axisPosition;
        double graphToSpace = self.bounds.size.width / axisRange.boundSpan;
        double valueAnchor = axisRange.lowerBounds;
        
        for (int i = 0; i < _majorTickCount; i++){
            double tick = _majorTicks[i];
            axisPoint.x = (tick - valueAnchor) * graphToSpace;
            [(CALayer *)_majorTickLayers[i] setPosition:axisPoint];
            
            if (majorFormatter){
                CATextLayer *layer = _majorLabels[i];
                NSString *label = [majorFormatter stringForObjectValue:majorDateFormatter ? [NSDate dateWithTimeIntervalSinceReferenceDate:tick] : @(tick)];
                layer.string = label;
                layer.frame = ({
                    CGRect bounds = CGRectZero;
                    bounds.size = [label sizeWithAttributes:@{NSFontAttributeName : _majorLabelFont}];
                    bounds.size.height = ceil(bounds.size.height);
                    bounds.size.width = ceil(bounds.size.width) + 2;
                    bounds;
                });
                layer.position = ({
                    CGPoint point = CGPointMake(axisPoint.x, axisPoint.y + layer.bounds.size.height);
                    if (point.y + layer.bounds.size.height / 2 > self.bounds.size.height){
                        point.y = axisPoint.y - layer.bounds.size.height;
                    }
                    point;
                });
            }
        }
        
        for (int i = 0; i < _minorTickCount; i++){
            double tick = _minorTicks[i];
            axisPoint.x = (tick - valueAnchor) * graphToSpace;
            [(CALayer *)_minorTickLayers[i] setPosition:axisPoint];
            
            if (minorFormatter){
                CATextLayer *layer = _minorLabels[i];
                NSString *label = [minorFormatter stringForObjectValue:minorDateFormatter ? [NSDate dateWithTimeIntervalSinceReferenceDate:tick] : @(tick)];
                layer.string = label;
                layer.frame = ({
                    CGRect bounds = CGRectZero;
                    bounds.size = [label sizeWithAttributes:@{NSFontAttributeName : _minorLabelFont}];
                    bounds.size.height = ceil(bounds.size.height);
                    bounds.size.width = ceil(bounds.size.width) + 2;
                    bounds;
                });
                layer.position = ({
                    CGPoint point = CGPointMake(axisPoint.x, axisPoint.y + layer.bounds.size.height);
                    if (point.y + layer.bounds.size.height / 2 > self.bounds.size.height){
                        point.y = axisPoint.y - layer.bounds.size.height;
                    }
                    point;
                });
            }
        }
        
        //Axis Label
        if (_axisLabel){
            if (!_axisLabel.superlayer) [self addSublayer:_axisLabel];
            _axisLabel.position = ({
                CGPoint point = CGPointMake(self.position.x, axisPoint.y + _axisLabel.bounds.size.height + _majorLabelFont.pointSize);
                point;
            });
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
            double tick = _majorTicks[i];
            axisPoint.y = (valueAnchor - tick) * graphToSpace;
            [(CALayer *)_majorTickLayers[i] setPosition:axisPoint];
            
            if (majorFormatter){
                CATextLayer *layer = _majorLabels[i];
                NSString *label = [majorFormatter stringForObjectValue:majorDateFormatter ? [NSDate dateWithTimeIntervalSinceReferenceDate:tick] : @(tick)];
                layer.string = label;
                layer.bounds = ({
                    CGRect bounds = CGRectZero;
                    bounds.size = [label sizeWithAttributes:@{NSFontAttributeName : _majorLabelFont}];
                    bounds.size.height = ceil(bounds.size.height);
                    bounds.size.width = ceil(bounds.size.width) + 2;
                    bounds;
                });
                layer.position = ({
                    CGPoint point = CGPointMake(axisPoint.x - layer.bounds.size.width, axisPoint.y);
                    if (point.x - layer.bounds.size.width / 2 < 0){
                        point.x = axisPoint.x + layer.bounds.size.width;
                    }
                    point;
                });
            }
        }
        
        for (int i = 0; i < _minorTickCount; i++){
            double tick = _minorTicks[i];
            axisPoint.y = (valueAnchor - tick) * graphToSpace;
            [(CALayer *)_minorTickLayers[i] setPosition:axisPoint];
            if (minorFormatter){
                CATextLayer *layer = _minorLabels[i];
                NSString *label = [majorFormatter stringForObjectValue:minorDateFormatter ? [NSDate dateWithTimeIntervalSinceReferenceDate:tick] : @(tick)];
                layer.string = label;
                layer.bounds = ({
                    CGRect bounds = CGRectZero;
                    bounds.size = [label sizeWithAttributes:@{NSFontAttributeName : _minorLabelFont}];
                    bounds.size.height = ceil(bounds.size.height);
                    bounds.size.width = ceil(bounds.size.width) + 2;
                    bounds;
                });
                layer.position = ({
                    CGPoint point = CGPointMake(axisPoint.x - layer.bounds.size.width, axisPoint.y);
                    if (point.x - layer.bounds.size.width / 2 < 0){
                        point.x = axisPoint.x + layer.bounds.size.width;
                    }
                    point;
                });
            }
        }
        
        //Axis Label
        if (_axisLabel){
            if (!_axisLabel.superlayer){
                _axisLabel.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1);
                [self addSublayer:_axisLabel];
            }
            
            _axisLabel.position = ({
                CGPoint point = CGPointMake(axisPoint.x + _axisLabel.bounds.size.width + _majorLabelFont.pointSize, self.position.y);
                point;
            });
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
    
    [CATransaction commit];
    
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
