//
//  FlxRangeGraph.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/26/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraph.h"
@class FlxGraphDataSet;

@interface FlxRangeGraph : FlxGraph
@property (strong, nonatomic) FlxGraphDataSet *xData;
@property (strong, nonatomic) FlxGraphDataSet *yUpperData;
@property (strong, nonatomic) FlxGraphDataSet *yLowerData;
@end
