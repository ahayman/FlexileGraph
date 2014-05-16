//
//  FlxGraphDataSet.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraphDataSet.h"
#import "FlxGraphSpace.h"

NSString *const FlxGraphRecordCountInvalidated = @"FlxGraphRecordCountInvalidated";

@implementation FlxGraphDataSetProperties
+ (instancetype) propertyWithCount:(NSUInteger)count{
    FlxGraphDataSetProperties *graphRecordCount = [FlxGraphDataSetProperties new];
    graphRecordCount.count = count;
    return graphRecordCount;
}
- (void) setCount:(NSUInteger)count{
    _count = count;
    [self invalidate];
}
- (void) invalidate{
    [[NSNotificationCenter defaultCenter] postNotificationName:FlxGraphRecordCountInvalidated object:self];
}
@end

@implementation FlxGraphDataSet{
    BOOL _dataSet;
    double *_data;
    FlxGraphDataSetProperties *_dataProperties;
}
#pragma mark - Class
#pragma mark - Init
#pragma mark - Lazy
#pragma mark - Private
- (NSUInteger) lowerBoundsInRange:(FlxGraphRange *)range{
    NSUInteger recordCount = _dataProperties.count;
    double lowerBounds = range.lowerBounds;
    double centerData = 0;
    NSUInteger lower = 0;
    NSUInteger upper = recordCount;
    NSUInteger center = 0;
    while (YES) {
        center = lower + ((upper - lower) / 2);
        if (lower == upper || lower == center) {
            if (_data[lower] > lowerBounds && lower > 0){
                lower --;
            }
            return lower;
        }
        
        centerData = _data[center];
        
        if (centerData == lowerBounds) return center;
        else if (centerData > lowerBounds) upper = center;
        else if (centerData < lowerBounds) lower = center;
    }
}
- (NSUInteger) upperBoundsInRange:(FlxGraphRange *)range{
    NSUInteger recordCount = _dataProperties.count;
    if (recordCount < 1) return 0;
    double upperBounds = range.upperBounds;
    double centerData = 0;
    NSUInteger lower = 0;
    NSUInteger upper = recordCount;
    NSUInteger center = 0;
    while (YES) {
        center = lower + ((upper - lower) / 2);
        if (lower == upper || lower == center) {
            if (_data[lower] < upperBounds && lower < recordCount - 1){
                lower ++;
            }
            return lower;
        }
        
        centerData = _data[center];
        
        if (centerData == upperBounds) return center;
        else if (centerData > upperBounds) upper = center;
        else if (centerData < upperBounds) lower = center;
    }
}
- (void) loadData{
    if (_dataSet) [self invalidateData];
    
    NSUInteger recordCount = _dataProperties.count;
    if (recordCount < 1) return;
    
    NSUInteger limit = 5000;
    NSUInteger offset = 0;
    
    if (_dataSourceBlock){
        _data = malloc(sizeof(double) * recordCount);
        NSRange range = NSMakeRange(offset, limit);
        BOOL freeDoubles = NO;
        
        while (offset < recordCount){
            if (offset + limit > recordCount){
                limit = recordCount % limit;
            }
            
            range = NSMakeRange(offset, limit);
            freeDoubles = NO;
            @autoreleasepool {
                double *doubles =  _dataSourceBlock(range, &freeDoubles);
                if (doubles){
                    memcpy(&_data[offset], doubles, sizeof(double) * limit);
                    if (freeDoubles) free(doubles);
                }
            }
            offset += range.length;
        }
    } else if ([_dataSource respondsToSelector:@selector(doublesForDataSet:inRange:freeDoubles:)]){
        _data = malloc(sizeof(double) * recordCount);
        NSRange range = NSMakeRange(offset, limit);
        BOOL freeDoubles = NO;
        
        while (offset < recordCount){
            if (offset + limit > recordCount){
                limit = recordCount % limit;
            }
            
            range = NSMakeRange(offset, limit);
            freeDoubles = NO;
            @autoreleasepool {
                double *doubles = [_dataSource doublesForDataSet:self inRange:range freeDoubles:&freeDoubles];
                if (doubles){
                    memcpy(&_data[offset], doubles, sizeof(double) * limit);
                    if (freeDoubles) free(doubles);
                }
            }
            offset += range.length;
        }
    }
    _dataSet = YES;
}
#pragma mark - Interface
- (void) setDataProperties:(FlxGraphDataSetProperties *)dataProperties{
    if (_dataProperties){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:FlxGraphRecordCountInvalidated object:_dataProperties];
    }
    
    _dataProperties = dataProperties;
    
    if (_dataProperties){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateData) name:FlxGraphRecordCountInvalidated object:_dataProperties];
    }
}
- (double *) doublesLimitedToRange:(FlxGraphRange *)range boundingRange:(NSRange *)boundingRange{
    if (!_dataSet){
        [self loadData];
    }
    
    NSUInteger lowerIdx = [self lowerBoundsInRange:range];
    NSUInteger upperIdx = [self upperBoundsInRange:range];
    
    if (boundingRange){
        *boundingRange = NSMakeRange(lowerIdx, upperIdx - lowerIdx);
    }
    
    return &_data[lowerIdx];
}
- (double *) doublesInRange:(NSRange)range{

    if (NSMaxRange(range) >= _dataProperties.count){
        [NSException raise:@"Range Out of Bounds" format:@"Requested range: %@ of data in the graph data set is out bounds of the record count: %lu", NSStringFromRange(range), (unsigned long)_dataProperties.count];
    }
    if (range.length == 0) return nil;
    
    if (!_dataSet){
        [self loadData];
    }
    
    return &_data[range.location];
}
- (void) invalidateData{
    if (_dataSet){
        _dataSet = NO;
        free(_data);
    }
}
#pragma mark - Protocol
#pragma mark - Overridden
- (void) dealloc{
    [self invalidateData];
}
@end
