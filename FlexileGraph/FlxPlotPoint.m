//
//  FlxPlotPoint.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/28/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxPlotPoint.h"

static CGRect squareRect(CGRect rect){
    CGFloat min = fminf(rect.size.width, rect.size.height);
    rect.origin.x += floorf((rect.size.width - min) / 2);
    rect.origin.y += floorf((rect.size.height - min) / 2);
    rect.size.height = rect.size.width = min;
    return rect;
}

@implementation FlxPlotPoint{
    FlxPlotPointType _type;
}
#pragma mark - Class
#pragma mark - Init
- (id) init{
    if (self = [super init]){
        self.lineWidth = 1;
        self.strokeColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), ({
            CGFloat colors[] = {0, 1};
            colors;
        }));
        self.fillColor = CGColorCreate(CGColorSpaceCreateDeviceGray(), ({
            CGFloat colors[] = {0, .5};
            colors;
        }));
        _starPointLength = .5;
        _starPoints = 5;
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
- (CGPathRef) circlePath{
    if (CGRectIsEmpty(self.bounds)) return nil;;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddEllipseInRect(pathRef, NULL, squareRect(self.bounds));
    return pathRef;
}
- (CGPathRef) starPath{
    if (CGRectIsEmpty(self.bounds)) return nil;;
    
    CGFloat pointLength = MAX(0.0f, MIN(1.0f, _starPointLength));
    NSUInteger points = _starPoints;
    if (points < 3) points = 3;
    CGRect rect = self.bounds;
    CGPoint rectCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2;
    CGFloat innerRadius = MAX(1.0f, radius * (1- pointLength));
    CGFloat radians = (2 * M_PI) / (((points * 2)) ? : 1.0f);
    CGPoint currentPoint = CGPointMake((cosf(- M_PI_2) * radius) + rectCenter.x, (sinf(- M_PI_2) * radius) + rectCenter.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, currentPoint.x, currentPoint.y);
    
    CGFloat curRadius;
    for (int i = 1; i < (points * 2); i++){
        if (i % 2 == 1) curRadius = innerRadius;
        else curRadius = radius;
        currentPoint = CGPointMake((cosf((radians * i) - M_PI_2) * curRadius) + rectCenter.x , (sinf((radians * i) - M_PI_2) * curRadius) + rectCenter.y);
        CGPathAddLineToPoint(path, NULL, currentPoint.x, currentPoint.y);
    }
    
    CGPathCloseSubpath(path);
    return path;
}
- (CGPathRef) crossPath{
    if (CGRectIsEmpty(self.bounds)) return nil;;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = self.bounds;
    CGFloat midX = CGRectGetMidX(bounds);
    CGPathMoveToPoint(pathRef, NULL, midX, bounds.origin.y);
    CGPathAddLineToPoint(pathRef, NULL, midX, CGRectGetMaxY(bounds));
    
    CGFloat midY = CGRectGetMidY(bounds);
    CGPathMoveToPoint(pathRef, NULL, bounds.origin.x, midY);
    CGPathAddLineToPoint(pathRef, NULL, CGRectGetMaxX(bounds), midY);
    
    return pathRef;
}
- (CGPathRef) verticalLinePath{
    if (CGRectIsEmpty(self.bounds)) return nil;;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = self.bounds;
    CGFloat midX = CGRectGetMidX(bounds);
    CGPathMoveToPoint(pathRef, NULL, midX, bounds.origin.y);
    CGPathAddLineToPoint(pathRef, NULL, midX, CGRectGetMaxY(bounds));
    
    return pathRef;
}
- (CGPathRef) horizontalLinePath{
    if (CGRectIsEmpty(self.bounds)) return nil;;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = self.bounds;
    CGFloat midY = CGRectGetMidY(bounds);
    CGPathMoveToPoint(pathRef, NULL, bounds.origin.x, midY);
    CGPathAddLineToPoint(pathRef, NULL, CGRectGetMaxX(bounds), midY);
    
    return pathRef;
}
#pragma mark - Interface
#pragma mark - Protocol
#pragma mark - Overridden
- (void) layoutSublayers{
    self.path = ({
        CGPathRef ref = nil;
        switch (_type) {
            case FlxPlotPointTypeCircle:
                ref = [self circlePath];
                break;
            case FlxPlotPointTypeStar:
                ref = [self starPath];
                break;
            case FlxPlotPointTypeHorizontalLine:
                ref = [self horizontalLinePath];
                break;
            case FlxPlotPointTypeVerticalLine:
                ref = [self verticalLinePath];
                break;
            case FlxPlotPointTypeCross:
                ref = [self crossPath];
                break;
        }
        ref;
    });
}
@end
