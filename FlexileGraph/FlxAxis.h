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

@protocol FlxAxisLabelFormatterDelegate <NSObject>
- (NSFormatter *) majorLabelFormatterForRange:(FlxGraphRange *)range forAxis:(FlxAxis *)axis;
- (NSFormatter *) minorLabelFormatterForRange:(FlxGraphRange *)range forAxis:(FlxAxis *)axis;
@end

@protocol FlxAxisTickDelegate <NSObject>
- (BOOL) axis:(FlxAxis *)axis needsMajorUpdateInRange:(FlxGraphRange *)range;
- (BOOL) axis:(FlxAxis *)axis needsMinorUpdateInRange:(FlxGraphRange *)range;
- (double *) majorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis;
- (double *) minorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis;
@end

@interface FlxAxis : CAShapeLayer
@property (strong, nonatomic) NSString *axisID;
@property (nonatomic) FlxAxisSpace axisSpace;
@property (readonly, nonatomic) FlxGraphRange *axisRange;
@property (strong, nonatomic) FlxGraphSpace *graphSpace;
@property (nonatomic) CGFloat axisWidth;
@property (strong, nonatomic) UIColor *lineColor;
@property (strong, nonatomic) CATextLayer *axisLabel;
@property (nonatomic) BOOL isDateAxis; ///Used only if the axis is calculating it's own ticks
@property (readonly) NSUInteger majorTickCount; ///The number of major ticks
@property (readonly) NSUInteger minorTickCount; ///The number of minorTicks

//Labelling
@property (weak, nonatomic) id <FlxAxisLabelFormatterDelegate> labelFormatterDelegate;
@property (strong, nonatomic) UIColor *majorFontColor;
@property (strong, nonatomic) UIFont *majorLabelFont;
@property (strong, nonatomic) UIColor *minorFontColor;
@property (strong, nonatomic) UIFont *minorLabelFont;

//Anchoring
@property (nonatomic) FlxAxisAnchor anchorType; ///anchor to either a side or the graph space
@property (nonatomic) double graphSpaceAnchor; ///anchors the axis to a spcific location in the graph space
@property (nonatomic) UIRectEdge sideAnchor; ///anchors the axis to a side
@property (nonatomic) CGFloat anchorOffset; ///offset for the axis if side anchored

//Tick Generation
@property (weak, nonatomic) id <FlxAxisTickDelegate> tickDelegate;
@property (nonatomic) CGSize majorTickSize; ///Major Tick size. If 0 no ticks will be presented. Default: 4
@property (nonatomic) CGSize minorTickSize; ///Minor Tick Size: If 0 no ticks will be presented. Default: 2

- (void) setAxisNeedsLayout;
- (void) layoutAxis;

@end
