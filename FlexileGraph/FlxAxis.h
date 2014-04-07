//
//  FlxAxis.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlxGraphSpace;
@class FlxAxis;
@class FlxGraphRange;

typedef NS_ENUM(NSUInteger, FlxAxisSpace) {
    FlxAxisSpaceX,
    FlxAxisSpaceY
};

typedef NS_ENUM(NSUInteger, FlxAxisAnchor) {
    FlxAxisAnchorSpace,
    FlxAxisAnchorSide
};

@protocol FlxAxisTickDelegate <NSObject>
- (BOOL) axis:(FlxAxis *)axis needsMajorUpdateInRange:(FlxGraphRange *)range;
- (BOOL) axis:(FlxAxis *)axis needsMinorUpdateInRange:(FlxGraphRange *)range;
- (double *) majorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis;
- (double *) minorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis;
@end

@interface FlxAxis : CAShapeLayer
@property (strong) NSString *axisID;
@property FlxAxisSpace axisSpace;
@property (readonly) FlxGraphRange *axisRange;
@property (strong) FlxGraphSpace *graphSpace;
@property CGFloat axisWidth;
@property (strong) UIColor *lineColor;
@property BOOL isDateAxis; ///Used only if the axis is calculating it's own ticks

//Anchoring
@property FlxAxisAnchor anchorType; ///anchor to either a side or the graph space
@property double graphSpaceAnchor; ///anchors the axis to a spcific location in the graph space
@property UIRectEdge sideAnchor; ///anchors the axis to a side
@property CGFloat anchorOffset; ///offset for the axis if side anchored

//Tick Generation
@property (weak) id <FlxAxisTickDelegate> tickDelegate;
@property CGSize majorTickSize; ///Major Tick size. If 0 no ticks will be presented. Default: 4
@property CGSize minorTickSize; ///Minor Tick Size: If 0 no ticks will be presented. Default: 2

- (void) setAxisNeedsLayout;
- (void) layoutAxis;

@end
