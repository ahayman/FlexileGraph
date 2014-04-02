//
//  FlxPlotGraph.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraph.h"
@class FlxLineGraph;

@protocol FlxLineGraphDataSource <NSObject>
- (NSUInteger) recordCountForGraph:(FlxLineGraph *)graph;
- (double *) xDoublesForGraph:(FlxLineGraph *)graph inRange:(NSRange)range;
- (double *) yDoublesForGraph:(FlxLineGraph *)graph inRange:(NSRange)range;
@end

@interface FlxLineGraph : FlxGraph
@property (weak) id <FlxLineGraphDataSource> dataSource;
@end
