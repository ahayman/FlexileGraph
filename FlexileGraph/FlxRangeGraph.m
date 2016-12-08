//
//  FlxRangeGraph.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/26/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxRangeGraph.h"
#import "FlxGraphSpace.h"
#import "FlxGraphDataSet.h"

@implementation FlxRangeGraph
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
- (CGPathRef) graphPath{
    FlxGraphRange *xRange = self.graphSpace.xRange;
    FlxGraphRange *yRange = self.graphSpace.yRange;
    CGFloat scale = 1; //[[UIScreen mainScreen] scale];
    CGMutablePathRef pathRef = NULL;
    if (xRange && yRange && _xData.dataProperties.count && _yUpperData && _yLowerData && _yUpperData.dataProperties.count <= _xData.dataProperties.count && _yLowerData.dataProperties.count <= _xData.dataProperties.count){
        NSRange dataRange;
        double *xData = [_xData doublesLimitedToRange:xRange boundingRange:&dataRange];
        if (!dataRange.length) return nil;
        double *yUpperData = [_yUpperData doublesInRange:dataRange];
        double *yLowerData = [_yLowerData doublesInRange:dataRange];
        NSUInteger upperIdx = dataRange.length;
        
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
        
        NSInteger idx = 0;
        
        x = (xData[idx] - xLower) * xFactor;
        y = (yUpper - yLowerData[idx]) * yFactor;
        idx++;
        
        CGPathMoveToPoint(pathRef, NULL, x, y);
        
        resStart = floor(x / resolution) * resolution;
        resEnd = resStart + resolution;
        
        double cY = (yUpper - yLowerData[idx]) * yFactor;
        x = (xData[idx] - xLower) * xFactor;
        BOOL findMin = NO;
        
        //Lower path draw
        if (dataRange.length > self.bounds.size.width / resolution){
            while (idx <= upperIdx){
                findMin = (cY > y) ? NO : YES;
                while (x < resEnd && idx <= upperIdx){
                    cY = (yUpper - yLowerData[idx]) * yFactor;
                    y = findMin ? fmin(cY, y) : fmax(cY, y);
                    idx++;
                    x = (xData[idx] - xLower) * xFactor;
                }
                CGPathAddLineToPoint(pathRef, NULL, resStart, y);
                
                resStart = floor(x / resolution) * resolution;
                resEnd = resStart + resolution;
                cY = (yUpper - yLowerData[idx]) * yFactor;
            }
        } else {
            for (; idx <= upperIdx; idx++){
                CGPathAddLineToPoint(pathRef, NULL, (xData[idx] - xLower) * xFactor, (yUpper - yLowerData[idx]) * yFactor);
            }
        }
        
        //Upper path draw
        if (dataRange.length > self.bounds.size.width / resolution){
            while (idx >= 0){
                findMin = (cY > y) ? NO : YES;
                while (x < resEnd && idx <= upperIdx){
                    cY = (yUpper - yUpperData[idx]) * yFactor;
                    y = findMin ? fmin(cY, y) : fmax(cY, y);
                    idx--;
                    x = (xData[idx] - xLower) * xFactor;
                }
                CGPathAddLineToPoint(pathRef, NULL, resStart, y);
                
                resStart = floor(x / resolution) * resolution;
                resEnd = resStart + resolution;
                cY = (yUpper - yUpperData[idx]) * yFactor;
            }
        } else {
            for (; idx >= 0; idx--){
                CGPathAddLineToPoint(pathRef, NULL, (xData[idx] - xLower) * xFactor, (yUpper - yUpperData[idx]) * yFactor);
            }
        }
        
        CGPathCloseSubpath(pathRef);
    }
    return pathRef;
}
@end
