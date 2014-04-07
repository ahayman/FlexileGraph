//
//  FlxAxisTickGenerator.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/6/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxAxisTickGenerator.h"
#import "FlxGraphSpace.h"

#define AllMajorCalendarUnits (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond)

@implementation NSDateComponents (flxUnitValue)
- (void) alignTo:(NSCalendarUnit)unit{
    NSArray *majorCalendarUnits = @[@(NSCalendarUnitYear), @(NSCalendarUnitMonth), @(NSCalendarUnitWeekOfYear), @(NSCalendarUnitDay), @(NSCalendarUnitHour), @(NSCalendarUnitMinute), @(NSCalendarUnitSecond)];
    NSCalendarUnit leastUnit = unit;
    for (NSNumber *num in majorCalendarUnits){
        NSCalendarUnit cUnit = num.unsignedIntegerValue;
        if (cUnit & unit){
            leastUnit = cUnit;
        }
    }
    NSUInteger index = [majorCalendarUnits indexOfObject:@(leastUnit)];
    if (index != NSNotFound){
        for (NSUInteger i = index + 1; i < majorCalendarUnits.count; i++){
            NSCalendarUnit cUnit = [majorCalendarUnits[i] unsignedIntegerValue];
            switch (cUnit) {
                case NSCalendarUnitYear:
                    self.year = 0;
                    break;
                case NSCalendarUnitMonth:
                    self.month = 1;
                    break;
                case NSCalendarUnitWeekOfYear:
                    self.weekOfYear = 0;
                    self.yearForWeekOfYear = self.year;
                    break;
                case NSCalendarUnitDay:
                    self.day = 1;
                    break;
                case NSCalendarUnitHour:
                case NSCalendarUnitMinute:
                case NSCalendarUnitSecond:
                    [self setValue:0 forUnit:cUnit];
                    break;
                default:
                    break;
            }
        }
    }
}
- (void) setValue:(NSUInteger)value forUnit:(NSCalendarUnit)unit{
    if (unit & NSCalendarUnitEra) self.era = value;
    if (unit & NSYearCalendarUnit) self.year = value;
    if (unit & NSQuarterCalendarUnit) self.quarter = value;
    if (unit & NSWeekOfYearCalendarUnit) self.yearForWeekOfYear = value;
    if (unit & NSMonthCalendarUnit) self.month = value;
    if (unit & NSWeekOfMonthCalendarUnit) self.weekOfMonth = value;
    if (unit & NSWeekCalendarUnit) self.week = value;
    if (unit & NSWeekdayCalendarUnit) self.weekday = value;
    if (unit & NSWeekdayOrdinalCalendarUnit) self.weekdayOrdinal = value;
    if (unit & NSDayCalendarUnit) self.day = value;
    if (unit & NSHourCalendarUnit) self.hour = value;
    if (unit & NSMinuteCalendarUnit) self.minute = value;
    if (unit & NSSecondCalendarUnit) self.second = value;
}
- (NSInteger) valueForCalendarUnit:(NSCalendarUnit)unit{
    if (unit & NSCalendarUnitEra) return self.era;
    if (unit & NSYearCalendarUnit) return self.year;
    if (unit & NSQuarterCalendarUnit) return self.quarter;
    if (unit & NSWeekOfYearCalendarUnit) return self.yearForWeekOfYear;
    if (unit & NSMonthCalendarUnit) return self.month;
    if (unit & NSWeekOfMonthCalendarUnit) return self.weekOfMonth;
    if (unit & NSWeekCalendarUnit) return self.week;
    if (unit & NSWeekdayCalendarUnit) return self.weekday;
    if (unit & NSWeekdayOrdinalCalendarUnit) return self.weekdayOrdinal;
    if (unit & NSDayCalendarUnit) return self.day;
    if (unit & NSHourCalendarUnit) return self.hour;
    if (unit & NSMinuteCalendarUnit) return self.minute;
    if (unit & NSSecondCalendarUnit) return self.second;
    return 0;
}
@end

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
- (BOOL) _getMajorUnit:(NSCalendarUnit *)major minor:(NSCalendarUnit *)minor fromDate:(NSDate *)startDate toDate:(NSDate *)endDate{
        NSCalendarUnit compFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [[NSCalendar currentCalendar] components:compFlags fromDate:startDate toDate:endDate options:0];
    
        if (components.year > 10){
            return NO;
        } else if (components.year > 5){
            *major = NSCalendarUnitYear;
            *minor = NSCalendarUnitMonth;
            return YES;
        } else if (components.month > 6){
            *major = NSCalendarUnitMonth;
            *minor = NSCalendarUnitWeekOfYear;
            return YES;
        } else if (components.month > 2){
            *major = NSCalendarUnitMonth;
            *minor = NSCalendarUnitDay;
            return YES;
        } else if (components.week > 2){
            *major = NSCalendarUnitWeekOfYear;
            *minor = NSCalendarUnitDay;
            return YES;
        } else if (components.day > 5){
            *major = NSCalendarUnitDay;
            *minor = NSCalendarUnitHour;
            return YES;
        } else if (components.hour > 24){
            *major = NSCalendarUnitHour;
            *minor = NSCalendarUnitMinute;
            return YES;
        } else if (components.minute > 30){
            *major = NSCalendarUnitMinute;
            *minor = NSCalendarUnitSecond;
            return YES;
        } else {
            return NO;
        }
}
#pragma mark - Interface
#pragma mark - Protocol
- (BOOL) axis:(FlxAxis *)axis needsMajorUpdateInRange:(FlxGraphRange *)range{
    
    BOOL (^StandardCalc)() = ^ BOOL {
        double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
        if (majorTickInt == _majorInterval){
            double start = ceil(range.lowerBounds / majorTickInt) * majorTickInt;
            double end = floor(range.upperBounds / majorTickInt) * majorTickInt;
            
            return (start >= _majorStart && end <= _majorEnd);
        } else {
            return NO;
        }
    };
    
    if (axis.isDateAxis){
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.lowerBounds];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.upperBounds];
        NSCalendarUnit major, minor;
        if ([self _getMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            
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
    
    BOOL (^StandardCalc)() = ^ BOOL {
            double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
            double minorTickInt = majorTickInt / 10;
        
        if (minorTickInt == _minorInterval){
            
            double minorStart = ceil(range.lowerBounds / minorTickInt) * minorTickInt;
            double minorEnd = floor(range.upperBounds / minorTickInt) * minorTickInt;
            
            return (minorStart >= _minorStart && minorEnd <= _minorEnd);
        } else {
            return NO;
        }
    };
    
    if (axis.isDateAxis){
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.lowerBounds];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.upperBounds];
        NSCalendarUnit major, minor;
        if ([self _getMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            
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
            
            return (_minorStart == startTick.timeIntervalSinceReferenceDate && _minorEnd == endTick.timeIntervalSinceReferenceDate);
            
        } else {
            return StandardCalc();
        }
    } else {
        return StandardCalc();
    }
}
- (double *) majorTicksInRange:(FlxGraphRange *)range tickCount:(NSUInteger *)tickCount forAxis:(FlxAxis *)axis{
    
    double * (^StandardIntervalCalculation)() = ^ double *{
        double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
        double start = ({
            double start = ceil(range.lowerBounds / majorTickInt) * majorTickInt;
            start -= (start * majorTickInt * 3);
            if (start < range.rangeMin){
                start = (range.rangeMin / majorTickInt) * majorTickInt;
            }
            start;
        });
        double end = ({
            double end = floor(range.upperBounds / majorTickInt) * majorTickInt;
            end += (end * majorTickInt * 3);
            if ( end > range.rangeMax){
                end = (range.rangeMax / majorTickInt) * majorTickInt;
            }
            end;
        });
        
        NSInteger count = (end - start) / majorTickInt;
        if (count < 0) count = 0;
        double *majorTicks = malloc(sizeof(double) * count);
        for (int i = 0; i < count; i++){
            majorTicks[i] = start;
            start += majorTickInt;
        }
        
        _majorStart = start;
        _majorEnd = end;
        _majorInterval = majorTickInt;
        
        *tickCount = count;
        return majorTicks;
    };
    
    if (axis.isDateAxis){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.lowerBounds];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.upperBounds];
        NSCalendarUnit compFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [calendar components:compFlags fromDate:startDate toDate:endDate options:0];
        
        NSCalendarUnit major, minor;
        if ([self _getMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            NSUInteger count = [components valueForCalendarUnit:major];
            NSDateComponents *majorInterval = [NSDateComponents new];
            [majorInterval setValue:1 forUnit:major];
            NSDateComponents *startComponents = [calendar components:AllMajorCalendarUnits fromDate:startDate];
            
            [startComponents alignTo:major];
            NSDate *majorTick = [calendar dateFromComponents:startComponents];
            if ([majorTick compare:startDate] == NSOrderedAscending) majorTick = [calendar dateByAddingComponents:majorInterval toDate:majorTick options:0];
            
            _majorStart = majorTick.timeIntervalSinceReferenceDate;
            
            double *ticks = malloc(sizeof(double) * count);
            
            for (int i = 0; i < count; i++){
                ticks[i] = majorTick.timeIntervalSinceReferenceDate;
                majorTick = [calendar dateByAddingComponents:majorInterval toDate:majorTick options:0];
            }
            
            _majorEnd = majorTick.timeIntervalSinceReferenceDate;
            _majorInterval = [calendar dateFromComponents:majorInterval].timeIntervalSinceReferenceDate;
            
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
        double majorTickInt = [self _niceNum:range.boundSpan / MajorTickIntervalDivisor round:YES];
        double majorStart = ({
            double start = ceil(range.lowerBounds / majorTickInt) * majorTickInt;
            start -= (start * majorTickInt * 3);
            if (start < range.rangeMin){
                start = (range.rangeMin / majorTickInt) * majorTickInt;
            }
            start;
        });
        double majorEnd = ({
            double end = floor(range.upperBounds / majorTickInt) * majorTickInt;
            end += (end * majorTickInt * 3);
            if ( end > range.rangeMax){
                end = (range.rangeMax / majorTickInt) * majorTickInt;
            }
            end;
        });
        
        NSInteger majorTickcount = (majorEnd - majorStart) / majorTickInt;
        
        double minorTickInt = majorTickInt / 10;
        double minorTickCount = majorTickcount * MajorTickIntervalDivisor;
        
        double minorStart = ceil(range.lowerBounds / minorTickInt) * minorTickInt;
        double minorEnd = floor(range.upperBounds / minorTickInt) * minorTickInt;
        
        _minorStart = minorStart;
        _minorEnd = minorEnd;
        _minorInterval = minorTickInt;
        
        minorTickCount += ((majorStart - minorStart) / minorTickInt);
        minorTickCount += ((minorEnd - majorEnd) / minorTickInt);
        
        double *minorTicks = malloc(sizeof(double) * minorTickCount);
        
        NSUInteger mIdx = 0;
        double minorTick = minorStart;
        
        while (minorTick < majorStart && mIdx < minorTickCount){
            minorTicks[mIdx] = minorTick;
            mIdx ++;
            minorTick += minorTickInt;
        }
        
        double majorTick = majorStart;
        
        for (int i = 0; i < majorTickInt; i++){
            minorTick = majorTick + minorTickInt;
            majorTick += majorTickInt;
            while (minorTick < majorTick && minorTick <= minorEnd && mIdx < minorTickCount){
                minorTicks[mIdx] = minorTick;
                mIdx ++;
                minorTick += minorTickInt;
            }
            if (mIdx >= minorTickCount){
                break;
            }
        }
        
        *tickCount = minorTickCount;
        return minorTicks;
    };
    
    if (axis.isDateAxis){
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.lowerBounds];
        NSDate *endDate = [NSDate dateWithTimeIntervalSinceReferenceDate:range.upperBounds];
        
        NSCalendarUnit major, minor;
        if ([self _getMajorUnit:&major minor:&minor fromDate:startDate toDate:endDate]){
            NSDateComponents *majorInterval = [NSDateComponents new];
            [majorInterval setValue:1 forUnit:major];
            NSDateComponents *minorInterval = [NSDateComponents new];
            [minorInterval setValue:1 forUnit:minor];
            NSDateComponents *startComponents = [calendar components:AllMajorCalendarUnits fromDate:startDate];
            
            [startComponents alignTo:minor];
            NSDate *minorStart = [calendar dateFromComponents:startComponents];
            if ([minorStart compare:startDate] == NSOrderedAscending) minorStart = [calendar dateByAddingComponents:minorInterval toDate:minorStart options:0];
            [startComponents alignTo:major];
            NSDate *majorStart = [calendar dateFromComponents:startComponents];
            if ([majorStart compare:startDate] == NSOrderedAscending) majorStart = [calendar dateByAddingComponents:majorInterval toDate:majorStart options:0];
            
            NSDate *cDate = minorStart;
            _minorStart = minorStart.timeIntervalSinceReferenceDate;
            NSDate *eDate = majorStart;
            NSUInteger minorTickCount = 0;
            
            while ([cDate compare:endDate] == NSOrderedAscending){
                NSDateComponents *components = [calendar components:minor fromDate:cDate toDate:eDate options:0];
                minorTickCount += [components valueForCalendarUnit:minor] - 1;
                cDate = eDate;
                eDate = [calendar dateByAddingComponents:majorInterval toDate:cDate options:0];
                if ([eDate compare:endDate] != NSOrderedAscending){
                    eDate = endDate;
                }
            }
            
            cDate = minorStart;
            eDate = majorStart;
            
            NSUInteger idx = 0;
            NSDate *minorTick;
            
            double *minorTicks = malloc(sizeof(double) * minorTickCount);
            
            while ([cDate compare:endDate] == NSOrderedAscending){
                NSDateComponents *components = [calendar components:minor fromDate:cDate toDate:eDate options:0];
                NSUInteger count = [components valueForCalendarUnit:minor] - 1;
                minorTick = cDate;
                for (int i = 0; i < count; i++){
                    minorTick = [calendar dateByAddingComponents:minorInterval toDate:minorTick options:0];
                    minorTicks[idx] = minorTick.timeIntervalSinceReferenceDate;
                    idx ++;
                }
                cDate = eDate;
                eDate = [calendar dateByAddingComponents:majorInterval toDate:cDate options:0];
                if ([eDate compare:endDate] != NSOrderedAscending){
                    eDate = endDate;
                }
            }
            
            _minorEnd = minorTick.timeIntervalSinceReferenceDate;
            _minorInterval = [calendar dateFromComponents:minorInterval].timeIntervalSinceReferenceDate;
            
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
