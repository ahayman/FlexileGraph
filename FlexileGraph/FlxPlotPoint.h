//
//  FlxPlotPoint.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/28/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef NS_ENUM(NSUInteger, FlxPlotPointType) {
    FlxPlotPointTypeCircle,
    FlxPlotPointTypeStar,
    FlxPlotPointTypeCross,
    FlxPlotPointTypeVerticalLine,
    FlxPlotPointTypeHorizontalLine
};

@interface FlxPlotPoint : CAShapeLayer
@property (nonatomic) FlxPlotPointType type;

//Star Configuration
@property (nonatomic) NSUInteger starPoints; /// Default: 5, min: 3 ... no max.
@property (nonatomic) CGFloat starPointLength; /// Default: .5, min: 0, max: 1

@end
