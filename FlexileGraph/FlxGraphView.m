//
//  FlxGraphView.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/28/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraphView.h"
#import "FlxGraph.h"
#import "FlxAxis.h"

@implementation FlxGraphView{
    FlxGraphSpace *_graphSpace;
    NSMutableArray *_graphs;
    NSMutableArray *_axes;
}
#pragma mark - Class
#pragma mark - Init
- (id) initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        _graphs = [NSMutableArray new];
        _axes = [NSMutableArray new];
    }
    return self;
}
#pragma mark - Lazy
#pragma mark - Private
#pragma mark - Interface
- (void) setGraphSpace:(FlxGraphSpace *)graphSpace{
    _graphSpace = graphSpace;
    for (FlxGraph *graph in _graphs){
        graph.graphSpace = _graphSpace;
    }
}
- (FlxGraphSpace *) graphSpace{
    return _graphSpace;
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
    }
    for (FlxAxis *axis in _axes){
        axis.frame = self.bounds;
    }
}
@end
