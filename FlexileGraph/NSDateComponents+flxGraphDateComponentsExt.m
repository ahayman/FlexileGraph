//
//  NSDateComponents+flxGraphDateComponentsExt.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/10/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "NSDateComponents+flxGraphDateComponentsExt.h"

NSCalendarUnit const AllMajorCalendarUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;

@implementation NSDateComponents (flxGraphDateComponentsExt)
+ (NSDateFormatter *) majorFormatterForCalendarUnit:(NSCalendarUnit)unit{
    NSArray *majorCalendarUnits = @[@(NSCalendarUnitYear), @(NSCalendarUnitMonth),  @(NSCalendarUnitDay), @(NSCalendarUnitHour), @(NSCalendarUnitMinute), @(NSCalendarUnitSecond)];
    NSCalendarUnit leastUnit = unit;
    for (NSNumber *num in majorCalendarUnits){
        NSCalendarUnit cUnit = num.unsignedIntegerValue;
        if (cUnit & unit){
            leastUnit = cUnit;
        }
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    switch (leastUnit) {
        case NSCalendarUnitYear:
            formatter.dateFormat = @"yyyy";
            break;
        case NSCalendarUnitMonth:
            formatter.dateFormat = @"MMM ''yy";
            break;
        case NSCalendarUnitWeekOfYear:
            formatter.dateFormat = @"MMM (W)";
            break;
        case NSCalendarUnitDay:
            formatter.dateFormat = @"MMM dd";
            break;
        case NSCalendarUnitHour:
            formatter.dateFormat = @"ha";
            break;
        case NSCalendarUnitMinute:
            formatter.dateFormat = @"mm:";
            break;
        case NSCalendarUnitSecond:
            formatter.dateFormat = @":ss";
            break;
        default:
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            break;
    }
    return formatter;
}
+ (NSDateFormatter *) minorFormatterForCalendarUnit:(NSCalendarUnit)unit{
    NSArray *majorCalendarUnits = @[@(NSCalendarUnitYear), @(NSCalendarUnitMonth),  @(NSCalendarUnitDay), @(NSCalendarUnitHour), @(NSCalendarUnitMinute), @(NSCalendarUnitSecond)];
    NSCalendarUnit leastUnit = unit;
    for (NSNumber *num in majorCalendarUnits){
        NSCalendarUnit cUnit = num.unsignedIntegerValue;
        if (cUnit & unit){
            leastUnit = cUnit;
        }
    }
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    switch (leastUnit) {
        case NSCalendarUnitYear:
            formatter.dateFormat = @"yyyy";
            break;
        case NSCalendarUnitMonth:
            formatter.dateFormat = @"LL";
            break;
        case NSCalendarUnitWeekOfYear:
            formatter.dateFormat = @"W";
            break;
        case NSCalendarUnitDay:
            formatter.dateFormat = @"dd";
            break;
        case NSCalendarUnitHour:
            formatter.dateFormat = @"ha";
            break;
        case NSCalendarUnitMinute:
            formatter.dateFormat = @"mm:";
            break;
        case NSCalendarUnitSecond:
            formatter.dateFormat = @":ss";
            break;
        default:
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            break;
    }
    return formatter;
}
+ (BOOL) getNiceMajorUnit:(NSCalendarUnit *)major minor:(NSCalendarUnit *)minor fromDate:(NSDate *)startDate toDate:(NSDate *)endDate{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components;
    
    components = [calendar components:NSCalendarUnitYear fromDate:startDate toDate:endDate options:0];
    if (components.year > 10){
        return NO;
    } else if (components.year > 0){
        *major = NSCalendarUnitYear;
        *minor = NSCalendarUnitMonth;
        return YES;
    }
    
    components = [calendar components:NSCalendarUnitMonth fromDate:startDate toDate:endDate options:0];
    if (components.month > 6){
        *major = NSCalendarUnitYear;
        *minor = NSCalendarUnitMonth;
        return YES;
    } else if (components.month > 0){
        *major = NSCalendarUnitMonth;
        *minor = NSCalendarUnitDay;
        return YES;
    }
    
    components = [calendar components:NSCalendarUnitWeekOfYear fromDate:startDate toDate:endDate options:0];
    if (components.weekOfYear > 0){
        *major = NSCalendarUnitWeekOfYear;
        *minor = NSCalendarUnitDay;
        return YES;
    }
    
    components = [calendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    if (components.day > 10){
        *major = NSCalendarUnitWeekOfYear;
        *minor = NSCalendarUnitDay;
        return YES;
    } else if (components.day > 0){
        *major = NSCalendarUnitDay;
        *minor = NSCalendarUnitHour;
        return YES;
    }
    
    components = [calendar components:NSCalendarUnitHour fromDate:startDate toDate:endDate options:0];
    if (components.hour > 5){
        *major = NSCalendarUnitDay;
        *minor = NSCalendarUnitHour;
        return YES;
    } else if (components.hour > 0){
        *major = NSCalendarUnitHour;
        *minor = NSCalendarUnitMinute;
        return YES;
    }
    
    components = [calendar components:NSCalendarUnitMinute fromDate:startDate toDate:endDate options:0];
    if (components.minute > 5){
        *major = NSCalendarUnitHour;
        *minor = NSCalendarUnitMinute;
        return YES;
    } else if (components.minute > 0){
        *major = NSCalendarUnitMinute;
        *minor = NSCalendarUnitSecond;
        return YES;
    }
    
    components = [calendar components:NSCalendarUnitSecond fromDate:startDate toDate:endDate options:0];
    if (components.second > 5){
        *major = NSCalendarUnitMinute;
        *minor = NSCalendarUnitSecond;
        return YES;
    }
    
    return NO;
    
}
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
    if (unit & NSWeekOfYearCalendarUnit) self.weekOfYear = value;
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
    if (unit & NSWeekOfYearCalendarUnit) return self.weekOfYear;
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
