//
//  FlxGraphSpace.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlxGraphRange : NSObject
@property double rangeMax;
@property double rangeMin;
@property (readonly) double rangeSpan;
@property double upperBounds;
@property double lowerBounds;
@property (readonly) double boundSpan;
@property (readonly) double tickMin;
@property (readonly) double tickMax;
@property (readonly) double tickSpan;
- (void) expandRangeByProportion:(double)prop;
- (void) expandBoundsByProportion:(double)prop;
@end

@interface FlxGraphSpace : NSObject
@property double xBase;
@property (readonly) FlxGraphRange *xRange;
@property (readonly) FlxGraphRange *yRange;
@end
