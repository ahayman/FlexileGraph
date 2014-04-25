//
//  FlxAxisTickGenerator.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/6/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxAxisTickGenerator.h"
#import "FlxGraphSpace.h"
#import "NSDateComponents+flxGraphDateComponentsExt.h"

#define MajorTickIntervalDivisor 9

@implementation FlxAxisTickGenerator{
    double _minorStart;
    double _minorEnd;
    double _majorInterval;
    double _majorStart;
    double _majorEnd;
    double _minorInterval;
}
#pragma mark - Class
#pragma mark - Init
#pragma mark - Lazy
#pragma mark - Private
- (double) _niceNum:(double)num round:(BOOL)round{
    double exp;
    double fraction;
    double nice;
    
    exp = floor(log10(num));
    fraction = num / pow(10, exp);
    
    if (round) {
        if (fraction < 1.5) {
            nice = 1;
        } else if (fraction < 3) {
            nice = 2;
        } else if (fraction < 7) {
            nice = 5;
        } else {
            nice = 10;
        }
    } else {
        if (fraction <= 1) {
            nice = 1;
        } else if (fraction <= 2) {
            nice = 2;
        } else if (fraction <= 5) {
            nice = 2;
        } else {
            nice = 10;
        }
    }
    
    return nice * pow(10, exp);
}
#pragma mark - Interface
#pragma mark - Protocol
- (BOOL) axis:(FlxAxis *)axis needsMajorUpdateInRange:(FlxGraphRange *)range{
    
    return YES;
    
    BOOL (^StandardCalc)() = ^ BOOL {
        double majorTickInt = [self _niceNum:range.tickSpan / MajorTickIntervalDivisor round:YES];
        if (majorTickInt == _majorInterval){
            double start = ceil(range.tickMin / majorTickInt) * majorTickInt;
            double end = floor(range.tickMax / majorTickInt) * majorTickInt;
            
            return (start >= _majorStart && end <= _majorEnd);
        } else {
            return YES;
        }
    };
    
    if (axis.isDateAxis){
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMin];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMax];
        NSCalendarUnit major, minor;
        if ([NSDateComponents getNiceMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *majorInterval = [NSDateComponents new];
            [majorInterval setValue:1 forUnit:major];
            NSDateComponents *components = [calendar components:AllMajorCalendarUnits fromDate:startDate];
            
            [components alignTo:major];
            NSDate *startTick = [calendar dateFromComponents:components];
            if ([startTick compare:startDate] == NSOrderedAscending) startTick = [calendar dateByAddingComponents:majorInterval toDate:startTick options:0];
            
            components = [calendar components:AllMajorCalendarUnits fromDate:endDate];
            [components alignTo:major];
            NSDate *endTick = [calendar dateFromComponents:components];
            
            return (_majorStart == startTick.timeIntervalSinceReferenceDate && _majorEnd == endTick.timeIntervalSinceReferenceDate);
            
        } else {
            return StandardCalc();
        }
    } else {
        return StandardCalc();
    }
}
- (BOOL) axis:(FlxAxis *)axis needsMinorUpdateInRange:(FlxGraphRange *)range{
    
    return YES;
    
    BOOL (^StandardCalc)() = ^ BOOL {
            double majorTickInt = [self _niceNum:range.tickSpan / MajorTickIntervalDivisor round:YES];
            double minorTickInt = majorTickInt / 10;
        
        if (minorTickInt == _minorInterval){
            
            double minorStart = ceil(range.tickMin / minorTickInt) * minorTickInt;
            double minorEnd = floor(range.tickMax / minorTickInt) * minorTickInt;
            
            return (minorStart >= _minorStart && minorEnd <= _minorEnd);
        } else {
            return YES;
        }
    };
    
    if (axis.isDateAxis){
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMin];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMax];
        NSCalendarUnit major, minor;
        if ([NSDateComponents getNiceMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *majorInterval = [NSDateComponents new];
            [majorInterval setValue:1 forUnit:minor];
            NSDateComponents *components = [calendar components:AllMajorCalendarUnits fromDate:startDate];
            
            [components alignTo:minor];
            NSDate *startTick = [calendar dateFromComponents:components];
            if ([startTick compare:startDate] == NSOrderedAscending) startTick = [calendar dateByAddingComponents:majorInterval toDate:startTick options:0];
            
            components = [calendar components:AllMajorCalendarUnits fromDate:endDate];
            [components alignTo:minor];
            NSDate *endTick = [calendar dateFromComponents:components];
            
            return (_minorStart >= startTick.timeIntervalSinceReferenceDate && _minorEnd <= endTick.timeIntervalSinceReferenceDate);
            
        } else {
            return StandardCalc();
        }
    } else {
        return StandardCalc();
    }
}
- (double *) majorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis{
    
    double * (^StandardIntervalCalculation)() = ^ double *{
        if (range.tickMin < 0 && range.tickMax > 0){
            double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
            
            NSUInteger lowerCount = fabsf(range.tickMin) / majorTickInt;
            NSUInteger upperCount = (range.tickMax / majorTickInt);
            NSUInteger count = lowerCount + upperCount + 1;
            
            double cValue = lowerCount * majorTickInt * -1;
            _majorStart = cValue;
            double *values = malloc(sizeof(double) * count);
            
            for (int i = 0; i < count; i++){
                values[i] = cValue;
                cValue += majorTickInt;
            }
            
            _majorEnd = cValue - majorTickInt;
            _majorInterval = majorTickInt;
            
            *tickCount = count;
            return values;
            
        } else {
            
            double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
            
            double majorStart = ({
                double start = ceil(range.tickMin / majorTickInt) * majorTickInt;
                start;
            });
            
            double majorEnd = ({
                double end = ceil(range.tickMax / majorTickInt) * majorTickInt;
                end;
            });
            
            NSInteger count = (majorEnd - majorStart) / majorTickInt;
            if (count < 0) count = 0;
            
            double *majorTicks = malloc(sizeof(double) * count);
            for (int i = 0; i < count; i++){
                majorTicks[i] = majorStart;
                majorStart += majorTickInt;
            }
            
            _majorStart = majorStart;
            _majorEnd = majorEnd;
            _majorInterval = majorTickInt;
            
            *tickCount = count;
            return majorTicks;
        }
    };
    
    if (axis.isDateAxis){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMin];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMax];
        
        NSCalendarUnit major, minor;
        if ([NSDateComponents getNiceMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            NSDateComponents *majorInterval = [NSDateComponents new];
            [majorInterval setValue:1 forUnit:major];
            NSDateComponents *startComponents = [calendar components:AllMajorCalendarUnits fromDate:startDate];
            
            [startComponents alignTo:major];
            NSDate *majorTick = [calendar dateFromComponents:startComponents];
            NSDateComponents *components = [calendar components:major fromDate:majorTick toDate:endDate options:0];
            NSUInteger count = [components valueForCalendarUnit:major];
            
            if ([majorTick compare:startDate] == NSOrderedAscending) majorTick = [calendar dateByAddingComponents:majorInterval toDate:majorTick options:0];
            
            _majorStart = majorTick.timeIntervalSinceReferenceDate;
            
            double *ticks = malloc(sizeof(double) * count);
            
            for (int i = 0; i < count; i++){
                ticks[i] = majorTick.timeIntervalSinceReferenceDate;
                majorTick = [calendar dateByAddingComponents:majorInterval toDate:majorTick options:0];
            }
            
            _majorEnd = majorTick.timeIntervalSinceReferenceDate;
            _majorInterval = [calendar dateFromComponents:majorInterval].timeIntervalSinceReferenceDate;
            
            NSLog(@"Major Ticks: %lu", (unsigned long)count);
            *tickCount = count;
            return ticks;
        } else {
            return StandardIntervalCalculation();
        }
 
    } else {
        return StandardIntervalCalculation();
    }
}
- (double *) minorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis{
    
    double * (^StandardIntervalCalculation)() = ^ double * {
        
        if (range.tickMin < 0 && range.tickMax > 0){
            
            double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
            double minorTickInt = majorTickInt / 10;
            
            NSUInteger lowerCount = fabsf(range.tickMin) / minorTickInt;
            NSUInteger upperCount = (range.tickMax / minorTickInt);
            NSUInteger count = lowerCount + upperCount + 1;
            
            double cValue = lowerCount * minorTickInt * -1;
            _majorStart = cValue;
            double *values = malloc(sizeof(double) * count);
            
            for (int i = 0; i < count; i++){
                values[i] = cValue;
                cValue += minorTickInt;
            }
            
            _majorEnd = cValue - minorTickInt;
            _majorInterval = minorTickInt;
            
            *tickCount = count;
            return values;
            
        } else {
            
            double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
            double minorTickInt = majorTickInt / 9;
            
            NSUInteger minorTickCount = range.tickSpan / minorTickInt;
            
            double minorStart = ceil(range.tickMin / minorTickInt) * minorTickInt;
            
            _minorStart = minorStart;
            _minorInterval = minorTickInt;
            
            double *minorTicks = malloc(sizeof(double) * minorTickCount);
            
            double minorTick = minorStart;
            
            for (int i = 0; i < minorTickCount; i++){
                minorTicks[i] = minorTick;
                minorTick += minorTickInt;
            }
            
            *tickCount = minorTickCount;
            return minorTicks;
        }
    };
    
    if (axis.isDateAxis){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMin];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMax];
        
        NSCalendarUnit major, minor;
        if ([NSDateComponents getNiceMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            NSDateComponents *majorInterval = [NSDateComponents new];
            [majorInterval setValue:1 forUnit:major];
            NSDateComponents *minorInterval = [NSDateComponents new];
            NSInteger minorInt = 1;
            [minorInterval setValue:minorInt forUnit:minor];
            NSDateComponents *startComponents = [calendar components:AllMajorCalendarUnits fromDate:startDate];
            
            [startComponents alignTo:minor];
            NSDate *firstMinorInBounds = [calendar dateFromComponents:startComponents];
            while ([firstMinorInBounds compare:startDate] == NSOrderedAscending){
                firstMinorInBounds = [calendar dateByAddingComponents:minorInterval toDate:firstMinorInBounds options:0];
            }
            
            [startComponents alignTo:major];
            NSDate *firstMajor = [calendar dateFromComponents:startComponents];
            while ([firstMajor compare:firstMinorInBounds] == NSOrderedAscending){
                firstMajor = [calendar dateByAddingComponents:majorInterval toDate:firstMajor options:0];
            }
            
            NSDate *cDate = firstMinorInBounds;
            _minorStart = firstMinorInBounds.timeIntervalSinceReferenceDate;
            NSDate *eDate = firstMajor;
            NSUInteger minorTickCount = [[calendar components:minor fromDate:startDate toDate:endDate options:0] valueForCalendarUnit:minor];
            while (minorTickCount > 100){
                minorTickCount /= 2;
                minorInt *= 2;
            }
            [minorInterval setValue:minorInt forUnit:minor];
            
            minorTickCount = 0;
            
            while ([cDate compare:endDate] == NSOrderedAscending){
                NSDateComponents *components = [calendar components:minor fromDate:cDate toDate:eDate options:0];
                NSInteger count = ([components valueForCalendarUnit:minor] / minorInt) - 1;
                if (count < 0) count = 0;
                minorTickCount += count;
                cDate = eDate;
                eDate = [calendar dateByAddingComponents:majorInterval toDate:cDate options:0];
                if ([eDate compare:endDate] != NSOrderedAscending){
                    eDate = endDate;
                }
            }
            
            cDate = firstMinorInBounds;
            eDate = firstMajor;
            
            NSUInteger idx = 0;
            NSDate *minorTick;
            
            double *minorTicks = malloc(sizeof(double) * minorTickCount);
            
            while ([cDate compare:endDate] == NSOrderedAscending){
                NSDateComponents *components = [calendar components:minor fromDate:cDate toDate:eDate options:0];
                NSInteger count = ([components valueForCalendarUnit:minor] / minorInt) - 1;
                minorTick = cDate;
                for (NSInteger i = 0; i < count && idx < minorTickCount; i++, idx++){
                    minorTick = [calendar dateByAddingComponents:minorInterval toDate:minorTick options:0];
                    minorTicks[idx] = minorTick.timeIntervalSinceReferenceDate;
                }
                cDate = eDate;
                eDate = [calendar dateByAddingComponents:majorInterval toDate:cDate options:0];
                if ([eDate compare:endDate] != NSOrderedAscending){
                    eDate = endDate;
                }
            }
            
            if (idx > minorTickCount){
                NSLog(@"Count: %lu, i: %lu", (unsigned long)minorTickCount, (unsigned long)idx);
            }
            
            _minorEnd = minorTick.timeIntervalSinceReferenceDate;
            _minorInterval = [calendar dateFromComponents:minorInterval].timeIntervalSinceReferenceDate;
            
            NSLog(@"Minor Ticks: %lu \n    -----    ", (unsigned long)minorTickCount);
            
            *tickCount = minorTickCount;
            return minorTicks;
            
        } else {
            return StandardIntervalCalculation();
        }
        
    } else {
        return StandardIntervalCalculation();
    }
}
#pragma mark - Overridden
@end
