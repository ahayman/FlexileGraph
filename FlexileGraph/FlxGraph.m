//
//  FlexileGraph.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraph.h"

@implementation FlxGraph{
    FlxGraphSpace *_graphSpace;
    BOOL _dataNeedsUpdate;
    BOOL _graphNeedsLayout;
}
#pragma mark - Class
#pragma mark - Init
#pragma mark - Lazy
#pragma mark - Private
- (void) performDataUpdate{
    if (_dataNeedsUpdate){
        _dataNeedsUpdate = NO;
        [self updateData];
    }
}
- (void) performGraphLayout{
    if (_graphNeedsLayout){
        _graphNeedsLayout = NO;
        [self layoutGraph];
    }
}
#pragma mark - Interface
- (void) setGraphSpace:(FlxGraphSpace *)graphSpace{
    if (graphSpace != _graphSpace){
        _graphSpace = graphSpace;
        [self setGraphNeedsLayout];
    }
}
- (FlxGraphSpace *) graphSpace{
    return _graphSpace;
}
- (void) setLineColor:(UIColor *)lineColor{
    self.strokeColor = lineColor.CGColor;
}
- (UIColor *) lineColor{
    return (self.strokeColor) ? [UIColor colorWithCGColor:self.strokeColor] : nil;
}
- (void) setGraphColor:(UIColor *)graphColor{
    self.fillColor = graphColor.CGColor;
}
- (UIColor *) graphColor{
    return (self.fillColor) ? [UIColor colorWithCGColor:self.fillColor] : nil;
}
- (void) setDataNeedsUpdate{
    if (!_dataNeedsUpdate){
        _dataNeedsUpdate = YES;
        [self performSelector:@selector(performDataUpdate) withObject:nil afterDelay:0];
    }
}
- (void) updateData{
    _dataNeedsUpdate = NO;
}
- (void) setGraphNeedsLayout{
    if (!_graphNeedsLayout){
        _graphNeedsLayout = YES;
        [self performSelector:@selector(performGraphLayout) withObject:nil afterDelay:0];
    }
}
- (void) layoutGraph{
    _graphNeedsLayout = NO;
}
#pragma mark - Protocol
#pragma mark - Overridden
@end
