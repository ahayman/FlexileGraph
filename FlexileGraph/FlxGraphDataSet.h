//
//  FlxGraphDataSet.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlxGraphDataSet;
@class FlxGraphSpace;
@class FlxGraphRange;

extern NSString *const FlxGraphRecordCountInvalidated;

@interface FlxGraphDataSetProperties : NSObject
+ (instancetype) propertyWithCount:(NSUInteger)count;
@property (nonatomic) NSUInteger count;
- (void) invalidate;
@end

@protocol FlxGraphDataSetDataSource <NSObject>
- (double *) doublesForDataSet:(FlxGraphDataSet *)dataSet inRange:(NSRange)range freeDoubles:(BOOL *)freeDoubles;
@end


@interface FlxGraphDataSet : NSObject
@property (strong, nonatomic) id dataSetID;
@property (weak, nonatomic) id <FlxGraphDataSetDataSource> dataSource;
@property (strong, nonatomic) FlxGraphDataSetProperties *dataProperties;
@property (copy) double * (^dataSourceBlock) (NSRange range, BOOL *freeDoubles);

- (double *) doublesLimitedToRange:(FlxGraphRange *)range boundingRange:(NSRange *)boundingRange;
- (double *) doublesInRange:(NSRange)range;

- (void) setData:(double *)data withProperties:(FlxGraphDataSetProperties *)properties;

- (void) invalidateData;
@end
