//
//  FlxPlotGraph.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraph.h"
@class FlxGraphDataSet;

@interface FlxLineGraph : FlxGraph
@property (strong) FlxGraphDataSet *xData;
@property (strong) FlxGraphDataSet *yData;
@end
