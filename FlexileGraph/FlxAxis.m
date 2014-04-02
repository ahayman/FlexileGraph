//
//  FlxAxis.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxAxis.h"

@interface FlxAxis () <FlxAxisTickDelegate>
@end

@implementation FlxAxis{
    FlxAxisSpace _axisSpace;
    FlxGraphSpace *_graphSpace;
    
    //Anchoring
    FlxAxisAnchor _anchorType;
    double _graphSpaceAnchor;
    UIRectEdge _sideAnchor;
    CGFloat _absoluteAnchor;
    BOOL _axisNeedsLayout;
    
    //Ticks
    __weak id <FlxAxisTickDelegate> _tickDelegate;
    CGFloat _majorTickSize;
    CGFloat _minorTickSize;
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
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
- (void) performAxisLayout{
    if (_axisNeedsLayout){
        [self layoutAxis];
    }
}
#pragma mark - Interface
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
- (void) setAbsoluteAnchor:(CGFloat)absoluteAnchor{
    _absoluteAnchor = absoluteAnchor;
    _anchorType = FlxAxisAnchorAbsolute;
    [self setAxisNeedsLayout];
}
- (CGFloat) absoluteAnchor{
    return _absoluteAnchor;
}
#pragma mark Tick Generation
- (void) setTickDelegate:(id<FlxAxisTickDelegate>)tickDelegate{
    if (tickDelegate){
        _tickDelegate = tickDelegate;
    } else {
        _tickDelegate = self;
    }
}
- (id <FlxAxisTickDelegate>) tickDelegate{
    return _tickDelegate;
}
#pragma mark Layout
- (void) setAxisNeedsLayout{
    if (!_axisNeedsLayout){
        _axisNeedsLayout = YES;
        [self performSelector:@selector(performAxisLayout) withObject:nil afterDelay:0];
    }
}
- (void) layoutAxis{
    _axisNeedsLayout = NO;
    
    
    
    if ([_tickDelegate axis:self needsUpdateInRange:self.axisRange]){
        if (_majorTickCount){
            _majorTickCount = 0;
            free(_majorTicks);
        }
        _majorTicks = [_tickDelegate majorTicksInRange:self.axisRange tickCount:&_majorTickCount];
        
        if (_minorTickCount){
            _minorTickCount = 0;
            free(_minorTicks);
        }
        _minorTicks = [_tickDelegate minorTicksInRange:self.axisRange tickCount:&_minorTickCount];
    }
}
#pragma mark - Protocol
#pragma mark - Overridden
@end
