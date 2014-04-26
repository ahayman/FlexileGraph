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
- (double *) xDoublesForLineGraph:(FlxLineGraph *)graph inRange:(NSRange)range freeDoubles:(BOOL *)free;
- (double *) yDoublesForLineGraph:(FlxLineGraph *)graph inRange:(NSRange)range freeDoubles:(BOOL *)free;
@end

@interface FlxLineGraph : FlxGraph
@property (weak) id <FlxLineGraphDataSource> dataSource;
@end
