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
@property double upperBounds;
@property double lowerBounds;
@end

@interface FlxGraphSpace : NSObject
@property double xBase;
@property (readonly) FlxGraphRange *xRange;
@property (readonly) FlxGraphRange *yRange;
@end
