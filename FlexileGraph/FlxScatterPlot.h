//
//  FlxScatterPlot.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/26/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraph.h"
#import "FlxPlotPoint.h"
@class FlxScatterPlot;

@protocol FlxScatterPlotLayerDelegate <NSObject>
- (CALayer *) plotLayerForRecord:(NSUInteger)index inScatterPlot:(FlxScatterPlot *)plot;
@end

@interface FlxScatterPlot : FlxGraph
@property (strong, nonatomic) FlxGraphDataSet *xData;
@property (strong, nonatomic) FlxGraphDataSet *yData;
@property (weak) id <FlxScatterPlotLayerDelegate> layerDelegate;


@property (nonatomic) FlxPlotPointType pointType;
@property (strong, nonatomic) Class pointLayerClass; ///Must be a subclass of CALayer
@property (nonatomic) CGSize plotLayerSize; //Default: {4, 4}, does not apply to delegate layers
@end
