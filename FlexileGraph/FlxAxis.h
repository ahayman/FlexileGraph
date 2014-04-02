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
    FlxAxisAnchorAbsolute,
    FlxAxisAnchorSide
};

@protocol FlxAxisTickDelegate <NSObject>
- (BOOL) axis:(FlxAxis *)axis needsUpdateInRange:(FlxGraphRange *)range;
- (double *) majorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount;
- (double *) minorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount;
@end

@interface FlxAxis : CAShapeLayer
@property FlxAxisSpace axisSpace;
@property (readonly) FlxGraphRange *axisRange;
@property (strong) FlxGraphSpace *graphSpace;

//Anchoring
@property FlxAxisAnchor anchorType;
@property double graphSpaceAnchor;
@property UIRectEdge sideAnchor;
@property CGFloat absoluteAnchor;

//Tick Generation
@property (weak) id <FlxAxisTickDelegate> tickDelegate;
@property CGFloat majorTickSize;
@property CGFloat minorTickSize;

- (void) setAxisNeedsLayout;
- (void) layoutAxis;

@end
