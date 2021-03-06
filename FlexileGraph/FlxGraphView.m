//
//  FlxGraphView.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/28/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraphView.h"
#import "FlxGraph.h"
#import "FlxGraphSpace.h"
#import "FlxAxis.h"

@implementation FlxGraphView{
    FlxGraphSpace *_graphSpace;
    NSMutableArray *_graphs;
    NSMutableArray *_axes;
    
    //Pinching & Dragging
    UIPinchGestureRecognizer *_pinch;
    UIPanGestureRecognizer *_drag;
    double _pinchMin;
    double _pinchMax;
    double _lastPinchSpan;
    BOOL _pinchVertical;
    
    BOOL _dragVertical;
    BOOL _dragging;
    CGPoint _dragLastPoint;
    double _dragSpaceConv;
}
#pragma mark - Class
#pragma mark - Init
- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        _graphs = [NSMutableArray new];
        _axes = [NSMutableArray new];
        self.clipsToBounds = YES;
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
- (void) drag:(UIPanGestureRecognizer *)drag{
    if (drag.state == UIGestureRecognizerStateBegan){
        _dragLastPoint = [drag locationInView:self];
    } else if (drag.state == UIGestureRecognizerStateChanged){
        CGPoint point = [drag locationInView:self];
        if (!_dragging){
            _dragging = YES;
            CGSize pinchSize = CGSizeMake(fabsf(point.x - _dragLastPoint.x), fabsf(point.y - _dragLastPoint.y));
            if (pinchSize.width < pinchSize.height){
                _dragSpaceConv = self.graphSpace.yRange.boundSpan / self.bounds.size.height;
                _dragVertical = YES;
            } else {
                _dragSpaceConv = self.graphSpace.xRange.boundSpan / self.bounds.size.width;
                _dragVertical = NO;
            }
        }
        
        double diff;
        FlxGraphRange *range;
        if (_dragVertical){
            diff = (point.y - _dragLastPoint.y) * _dragSpaceConv;
            range = self.graphSpace.yRange;
        } else {
            diff = (_dragLastPoint.x - point.x) * _dragSpaceConv;
            range = self.graphSpace.xRange;
        }
        //Apply the
        if (range.lowerBounds + diff < range.rangeMax - (range.boundSpan * .1) && range.upperBounds + diff > range.rangeMin + (range.boundSpan * .1)){
            [range setBoundsToLower:range.lowerBounds + diff upper:range.upperBounds + diff];
        }
        
        _dragLastPoint = point;
        
        [self updateLayout];
        
    } else {
        _dragging = NO;
    }
}
- (void) pinch:(UIPinchGestureRecognizer *)pinch{
    void (^SetPinchBaseline)(CGPoint point1, CGPoint point2) = ^(CGPoint point1, CGPoint point2){
        if (_pinchVertical){
            FlxGraphRange *range = _graphSpace.yRange;
            double pinchMin = MIN(point1.y, point2.y);
            double pinchMax = MAX(point1.y, point2.y);
            CGFloat height = self.bounds.size.height;
            _pinchMin = ((height - pinchMax) / height) * range.boundSpan + range.lowerBounds;
            _pinchMax = ((height - pinchMin) / height) * range.boundSpan + range.lowerBounds;
            _lastPinchSpan = pinchMax - pinchMin;
        } else {
            FlxGraphRange *range = _graphSpace.xRange;
            double pinchMin = MIN(point1.x, point2.x);
            double pinchMax = MAX(point1.x, point2.x);
            _pinchMin = (pinchMin / self.bounds.size.width) * range.boundSpan + range.lowerBounds;
            _pinchMax = (pinchMax / self.bounds.size.width) * range.boundSpan + range.lowerBounds;
            _lastPinchSpan = pinchMax - pinchMin;
        }
    };
    
    if (pinch.state == UIGestureRecognizerStateBegan){
        CGPoint point1 = [pinch locationOfTouch:0 inView:self];
        CGPoint point2 = [pinch locationOfTouch:1 inView:self];
        CGSize pinchSize = CGSizeMake(fabsf(point1.x - point2.x), fabsf(point1.y - point2.y));
        _pinchVertical = (pinchSize.width < pinchSize.height) ? YES : NO;
        SetPinchBaseline(point1, point2);
    } else if (pinch.numberOfTouches > 1){
        FlxGraphRange *range = (_pinchVertical) ? _graphSpace.yRange : _graphSpace.xRange;
        CGPoint point1 = [pinch locationOfTouch:0 inView:self];
        CGPoint point2 = [pinch locationOfTouch:1 inView:self];
        double pinchMin, pinchMax;
        if (_pinchVertical) {
            pinchMin = MIN(point1.y, point2.y);
            pinchMax = MAX(point1.y, point2.y);
            if (fabs((pinchMax - pinchMin) - _lastPinchSpan) < 10){
                double height = self.bounds.size.height;
                double conv = (_pinchMax - _pinchMin) / (pinchMax - pinchMin);
                double lower = _pinchMin - (height - pinchMax) * conv;
                double upper = height * conv + lower;
                double boundSpan = upper - lower;
                if (lower > range.rangeMax - boundSpan * .1){
                    lower = range.rangeMax - boundSpan * .1;
                }
                if (upper < range.rangeMin + boundSpan * .1){
                    upper = range.rangeMin + boundSpan * .1;
                }
                [range setBoundsToLower:lower upper:upper];
                _lastPinchSpan = pinchMax - pinchMin;
            } else {
                SetPinchBaseline(point1, point2);
            }
        } else {
            pinchMin = MIN(point1.x, point2.x);
            pinchMax = MAX(point1.x, point2.x);
            if (fabs((pinchMax - pinchMin) - _lastPinchSpan) < 10){
                double conv = (_pinchMax - _pinchMin) / (pinchMax - pinchMin);
                double lower = _pinchMin - pinchMin * conv;
                double upper = self.bounds.size.width * conv + lower;
                double boundSpan = upper - lower;
                if (lower > range.rangeMax - boundSpan * .1){
                    lower = range.rangeMax - boundSpan * .1;
                }
                if (upper < range.rangeMin + boundSpan * .1){
                    upper = range.rangeMin + boundSpan * .1;
                }
                [range setBoundsToLower:lower upper:upper];
                _lastPinchSpan = pinchMax - pinchMin;
            } else {
                SetPinchBaseline(point1, point2);
            }
        }
        
        [self updateLayout];
    }
}
#pragma mark - Interface
- (void) updateLayout{
    for (FlxGraph *graph in _graphs){
        [graph layoutGraph];
    }
    for (FlxAxis *axis in _axes){
        [axis layoutAxis];
    }
}
- (void) setGraphSpace:(FlxGraphSpace *)graphSpace{
    _graphSpace = graphSpace;
    for (FlxGraph *graph in _graphs){
        graph.graphSpace = _graphSpace;
    }
}
- (FlxGraphSpace *) graphSpace{
    return _graphSpace;
}
- (void) setEnableDragging:(BOOL)enableDragging{
    if (enableDragging){
        if (!_drag){
            _drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
            _drag.maximumNumberOfTouches = 1;
        }
        if (_drag.view != self){
            [self addGestureRecognizer:_drag];
        }
    } else {
        if (_drag.view){
            [_drag.view removeGestureRecognizer:_drag];
        }
    }
}
- (BOOL) enableDragging{
    return (_drag.view == self) ? YES : NO;
}
- (void) setEnablePinching:(BOOL)enablePinching{
    if (enablePinching){
        if (!_pinch){
            _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        }
        if (_pinch.view != self){
            [self addGestureRecognizer:_pinch];
        }
    } else {
        if (_pinch.view){
            [_pinch.view removeGestureRecognizer:_pinch];
        }
    }
}
- (void) addGraphToView:(FlxGraph *)graph{
    if (!graph) return;
    if (![_graphs containsObject:graph]){
        [_graphs addObject:graph];
        graph.graphSpace = self.graphSpace;
        graph.frame = self.bounds;
        if (_axes.count){
            [self.layer insertSublayer:graph below:_axes.firstObject];
        } else {
            [self.layer addSublayer:graph];
        }
    }
}
- (void) removeGraph:(FlxGraph *)graph{
    if (!graph) return;
    [graph removeFromSuperlayer];
    [_graphs removeObject:graph];
}
- (void) removeAllGraphs{
    for (FlxGraph *graph in _graphs){
        [graph removeFromSuperlayer];
    }
    [_graphs removeAllObjects];
}
- (void) addAxis:(FlxAxis *)axis{
    if (!axis) return;
    if (![_axes containsObject:axis]){
        [_axes addObject:axis];
        axis.frame = self.bounds;
        [axis setAxisNeedsLayout];
        [self.layer addSublayer:axis];
    }
}
- (void) removeAxis:(FlxAxis *)axis{
    if (!axis) return;
    [axis removeFromSuperlayer];
    [_axes removeObject:axis];
}
- (void) removeAllAxes{
    for (FlxAxis *axis in _axes){
        [axis removeFromSuperlayer];
    }
    [_axes removeAllObjects];
}
#pragma mark - Protocol
#pragma mark - Overridden
- (void) layoutSubviews{
    for (FlxGraph *graph in _graphs){
        graph.frame = self.bounds;
        [graph layoutGraph];
    }
    for (FlxAxis *axis in _axes){
        axis.frame = self.bounds;
        [axis layoutAxis];
    }
}
@end
