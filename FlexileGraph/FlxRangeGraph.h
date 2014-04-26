//
//  FlxRangeGraph.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/26/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraph.h"
@class FlxRangeGraph;

@protocol FlxRangeGraphDataSource <NSObject>
- (NSUInteger) recordCountForGraph:(FlxRangeGraph *)graph;
- (double *) xDoublesForLineGraph:(FlxRangeGraph *)graph inRange:(NSRange)range freeDoubles:(BOOL *)free;
- (double *) yUpperDoublesForLineGraph:(FlxRangeGraph *)graph inRange:(NSRange)range freeDoubles:(BOOL *)free;
- (double *) yLowerDoublesForLineGraph:(FlxRangeGraph *)graph inRange:(NSRange)range freeDoubles:(BOOL *)free;
@end

@interface FlxRangeGraph : FlxGraph
@property (weak) id <FlxRangeGraphDataSource> dataSource;
@end
