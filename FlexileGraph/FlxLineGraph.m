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
#import "FlxGraphDataSet.h"

@implementation FlxLineGraph
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
#pragma mark - Interface
#pragma mark - Protocol
#pragma mark - Overridden
- (CGPathRef) newGraphPath{
    FlxGraphRange *xRange = self.graphSpace.xRange;
    FlxGraphRange *yRange = self.graphSpace.yRange;
    CGMutablePathRef pathRef = NULL;
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
        
        pathRef = CGPathCreateMutable();
        double x = 0, y = 0;
        CGFloat resolution = 1.0f / [UIScreen mainScreen].scale;
        CGFloat resStart = 0, resEnd = 0 + resolution;
        
        BOOL fill = (self.fillColor) ? YES : NO;
        NSUInteger idx = 0;
        
        if (fill){
            //Initiall point for fill shape
            x = (xData[idx] - xLower) * xFactor;
            y = (yUpper - self.graphSpace.xBase) * yFactor;
        } else {
            x = (xData[idx] - xLower) * xFactor;
            y = (yUpper - yData[idx]) * yFactor;
            idx++;
        }
        
        CGPathMoveToPoint(pathRef, NULL, x, y);
        
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
                CGPathAddLineToPoint(pathRef, NULL, resStart, y);
                
                resStart = floor(x / resolution) * resolution;
                resEnd = resStart + resolution;
                cY = (yUpper - yData[idx]) * yFactor;
            }
        } else {
            for (; idx <= upperIdx; idx++){
                CGPathAddLineToPoint(pathRef, NULL, (xData[idx] - xLower) * xFactor, (yUpper - yData[idx]) * yFactor);
            }
        }
        
        if (fill){
            //Last point and path close if we're filling
            y = (yUpper - self.graphSpace.xBase) * yFactor;
            x = (xData[upperIdx] - xLower) * xFactor;
            CGPathAddLineToPoint(pathRef, NULL, x, y);
            
            CGPathCloseSubpath(pathRef);
        }
    }
    return pathRef;
}
@end
