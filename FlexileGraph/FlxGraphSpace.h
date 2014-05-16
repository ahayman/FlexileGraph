//
//  FlxGraphSpace.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlxGraphRange : NSObject
@property (nonatomic) double rangeMax;
@property (nonatomic) double rangeMin;
@property (readonly) double rangeSpan;
@property (nonatomic) double upperBounds;
@property (nonatomic) double lowerBounds;
@property (nonatomic) double maxBoundScale; //Default: 0, 0 = No Max
@property (nonatomic) double minBoundScale; //Default: 0, 0 = No Max
@property (readonly) double boundSpan;
@property (readonly) double tickMin;
@property (readonly) double tickMax;
@property (readonly) double tickSpan;
- (void) expandRangeByProportion:(double)prop;
- (void) expandBoundsByProportion:(double)prop;
- (void) setBoundsToLower:(double)lower upper:(double)upper;
@end

@interface FlxGraphSpace : NSObject
@property double xBase;
@property (readonly) FlxGraphRange *xRange;
@property (readonly) FlxGraphRange *yRange;
@end
