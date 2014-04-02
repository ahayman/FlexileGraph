//
//  FlexileGraph.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlxGraphSpace;


@interface FlxGraph : CAShapeLayer
@property (strong) NSString *graphID;
@property (strong) FlxGraphSpace *graphSpace;

//Covenience Properties
@property (strong) UIColor *lineColor;
@property (strong) UIColor *graphColor;

- (void) setDataNeedsUpdate;
- (void) updateData;
- (void) setGraphNeedsLayout;
- (void) layoutGraph;
@end
