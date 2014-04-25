//
//  FlxPlotGraph.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxLineGraph.h"
#import "FlxGraphView.h"
#import "FlxGraphSpace.h"

@implementation FlxLineGraph{
    NSUInteger _recordCount;
    BOOL _xDataSet;
    double *_xData;
    BOOL _yDataSet;
    double *_yData;
}
#pragma mark - Class
#pragma mark - Init
- (id) init{
    if (self = [super init]){
        self.lineWidth = 1.0f;
        self.strokeColor = [UIColor blackColor].CGColor;
        self.fillColor = nil;
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
- (void) clearData{
    _recordCount = 0;
    if (_xDataSet){
        _xDataSet = NO;
        free(_xData);
        _xData = nil;
    }
    if (_yDataSet){
        _yDataSet = NO;
        free(_yData);
        _yData = nil;
    }
}
- (CGPathRef) graphPath{
    FlxGraphRange *xRange = self.graphSpace.xRange;
    FlxGraphRange *yRange = self.graphSpace.yRange;
    CGFloat scale = 1; //[[UIScreen mainScreen] scale];
    CGMutablePathRef pathRef = NULL;
    if (xRange && yRange && _xDataSet & _yDataSet){
        NSUInteger lowerIdx = [self lowerBoundsOfData:_xData inRange:xRange];
        NSUInteger upperIdx = [self upperBoundsOfData:_xData inRange:xRange];
        
        double xSpan = self.bounds.size.width * scale;
        double ySpan = self.bounds.size.height * scale;
        
        double xLower = xRange.lowerBounds;
        double xUpper = xRange.upperBounds;
        double yLower = yRange.lowerBounds;
        double yUpper = yRange.upperBounds;
        
        double xFactor = xSpan / ((xUpper - xLower) ?: 1);
        double yFactor = ySpan / ((yUpper - yLower) ?: 1);
        
        pathRef = CGPathCreateMutable();
        double x = 0, y = 0;
        CGFloat resolution = 1.0f / [UIScreen mainScreen].scale;
        CGFloat resStart = 0, resEnd = 0 + resolution;
        
        BOOL fill = (self.fillColor) ? YES : NO;
        NSUInteger idx = lowerIdx;
        
        if (fill){
            //Initiall point for fill shape
            x = (_xData[idx] - xLower) * xFactor;
            y = (yUpper - self.graphSpace.xBase) * yFactor;
        } else {
            x = (_xData[idx] - xLower) * xFactor;
            y = (yUpper - _yData[idx]) * yFactor;
            idx++;
        }
        
        CGPathMoveToPoint(pathRef, NULL, x, y);
        
        resStart = floor(x / resolution) * resolution;
        resEnd = resStart + resolution;
        
        double cY = (yUpper - _yData[idx]) * yFactor;
        x = (_xData[idx] - xLower) * xFactor;
        BOOL findMin = NO;
        
        if (upperIdx - lowerIdx > self.bounds.size.width / resolution){
            while (idx <= upperIdx){
                findMin = (cY > y) ? NO : YES;
                while (x < resEnd && idx <= upperIdx){
                    cY = (yUpper - _yData[idx]) * yFactor;
                    y = findMin ? fmin(cY, y) : fmax(cY, y);
                    idx++;
                    x = (_xData[idx] - xLower) * xFactor;
                }
                CGPathAddLineToPoint(pathRef, NULL, resStart, y);
                
                resStart = floor(x / resolution) * resolution;
                resEnd = resStart + resolution;
                cY = (yUpper - _yData[idx]) * yFactor;
            }
        } else {
            for (; idx <= upperIdx; idx++){
                CGPathAddLineToPoint(pathRef, NULL, (_xData[idx] - xLower) * xFactor, (yUpper - _yData[idx]) * yFactor);
            }
        }
        
        if (fill){
            //Last point and path close if we're filling
            y = (yUpper - self.graphSpace.xBase) * yFactor;
            x = (_xData[upperIdx] - xLower) * xFactor;
            CGPathAddLineToPoint(pathRef, NULL, x, y);
            
            CGPathCloseSubpath(pathRef);
        }
    }
    return pathRef;
}
- (NSUInteger) lowerBoundsOfData:(double *)data inRange:(FlxGraphRange *)range{
    double lowerBounds = range.lowerBounds;
    double centerData = 0;
    NSUInteger lower = 0;
    NSUInteger upper = _recordCount ? _recordCount - 1 : 0;
    NSUInteger center = 0;
    while (YES) {
        center = lower + ((upper - lower) / 2);
        if (lower == upper || lower == center) {
            if (data[lower] > lowerBounds && lower > 0){
                lower --;
            }
            return lower;
        }
        
        centerData = data[center];
        
        if (centerData == lowerBounds) return center;
        else if (centerData > lowerBounds) upper = center;
        else if (centerData < lowerBounds) lower = center;
    }
}
- (NSUInteger) upperBoundsOfData:(double *)data inRange:(FlxGraphRange *)range{
    double upperBounds = range.upperBounds;
    double centerData = 0;
    NSUInteger lower = 0;
    NSUInteger upper = _recordCount ? _recordCount - 1 : 0;
    NSUInteger center = 0;
    while (YES) {
        center = lower + ((upper - lower) / 2);
        if (lower == upper || lower == center) {
            if (data[lower] < upperBounds && lower < _recordCount - 1){
                lower ++;
            }
            return lower;
        }
        
        centerData = data[center];
        
        if (centerData == upperBounds) return center;
        else if (centerData > upperBounds) upper = center;
        else if (centerData < upperBounds) lower = center;
    }
}
#pragma mark - Interface
#pragma mark - Protocol
#pragma mark - Overridden
- (void) updateData{
    [super updateData];
    [self clearData];
    if (_dataSource){
        _recordCount = [_dataSource recordCountForGraph:self];
        _xData = malloc(sizeof(double) * _recordCount);
        _xDataSet = YES;
        _yData = malloc(sizeof(double) * _recordCount);
        _yDataSet = YES;
        
        NSUInteger limit = 5000;
        NSUInteger offset = 0;
        while (offset < _recordCount){
            if (offset + limit > _recordCount){
                limit = _recordCount % limit;
            }
            
            NSRange range = NSMakeRange(offset, limit);
            @autoreleasepool {
                BOOL freeDoubles = NO;
                double *doubles = [_dataSource xDoublesForLineGraph:self inRange:range freeAfterUse:&freeDoubles];
                if (doubles){
                    memcpy(&_xData[offset], doubles, sizeof(double) * limit);
                    if (freeDoubles) free(doubles);
                }
                
                freeDoubles = NO;
                if (doubles){
                    doubles = [_dataSource yDoublesForLineGraph:self inRange:range freeAfterUse:&freeDoubles];
                    memcpy(&_yData[offset], doubles, sizeof(double) * limit);
                    if (freeDoubles) free(doubles);
                }
            }
            offset += range.length;
        }
    }
    [self setGraphNeedsLayout];
}
- (void) dealloc{
    [self clearData];
}
@end
