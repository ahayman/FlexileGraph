//
//  FlxGraphView.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/28/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlxGraph;
@class FlxGraphSpace;
@class FlxAxis;

@interface FlxGraphView : UIView
@property (strong, nonatomic) FlxGraphSpace *graphSpace;
@property (readonly) NSArray *graphs;
@property (nonatomic) BOOL enableDragging; ///Default: NO
@property (nonatomic) BOOL enablePinching; ///Default: NO

- (void) updateLayout;

- (void) addGraphToView:(FlxGraph *)graph;
- (void) removeGraph:(FlxGraph *)graph;
- (void) removeAllGraphs;

- (void) addAxis:(FlxAxis *)axis;
- (void) removeAxis:(FlxAxis *)axis;
- (void) removeAllAxes;
@end
