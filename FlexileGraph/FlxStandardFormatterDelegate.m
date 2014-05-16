//
//  FlxStandardFormatterDelegate.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/10/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxStandardFormatterDelegate.h"
#import "NSDateComponents+flxGraphDateComponentsExt.h"
#import "FlxGraphSpace.h"

@implementation FlxStandardFormatterDelegate{
    NSMutableDictionary *_majorDateFormatters;
    NSMutableDictionary *_minorDateFormatters;
    NSNumberFormatter *_standardMajorFormatter;
}
- (id) init{
    if (self = [super init]){
        _majorDateFormatters = [NSMutableDictionary new];
        _minorDateFormatters = [NSMutableDictionary new];
    }
    return self;
}
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
- (NSFormatter *) majorLabelFormatterForRange:(FlxGraphRange *)range forAxis:(FlxAxis *)axis{
    
    CGFloat majorWidth = ({
        CGFloat majorWidth = axis.graphSpace == FlxAxisSpaceX ? axis.bounds.size.width : axis.bounds.size.height;
        majorWidth *= range.tickSpan / range.boundSpan;
        majorWidth /= axis.majorTickCount;
        majorWidth;
    });
    
    if (majorWidth < 20){
        return nil;
    }
    
    NSFormatter *(^StandardFormatter)() = ^ NSFormatter *{
        if (!_standardMajorFormatter){
            _standardMajorFormatter = [[NSNumberFormatter alloc] init];
            [_standardMajorFormatter setLocale:[NSLocale currentLocale]];
        }
        double majorTickInt = [self _niceNum:range.tickSpan / 9 round:YES];
        
        double exp = floor(log10(majorTickInt));
        if (exp >= 0){
            _standardMajorFormatter.maximumFractionDigits = 0;
        } else {
            _standardMajorFormatter.maximumFractionDigits = fabs(exp);
        }
        
        return _standardMajorFormatter;
    };
    
    if (axis.isDateAxis){
        NSCalendarUnit major;
        NSCalendarUnit minor;
        if ([NSDateComponents getNiceMajorUnit:&major minor:&minor fromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMin] toDate:[NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMax]]){
            NSDateFormatter *formatter = _majorDateFormatters[@(major)];
            if (!formatter){
                formatter = [NSDateComponents majorFormatterForCalendarUnit:major];
                _majorDateFormatters[@(major)] = formatter;
            }
            return formatter;
        } else {
            if (range.tickSpan > 100){
                NSDateFormatter *formatter = _majorDateFormatters[@(NSCalendarUnitYear)];
                if (!formatter){
                    formatter = [NSDateComponents majorFormatterForCalendarUnit:NSCalendarUnitYear];
                    _majorDateFormatters[@(NSCalendarUnitYear)] = formatter;
                }
                return formatter;
            } else {
                return StandardFormatter();
            }
        }
    } else {
        return StandardFormatter();
    }
}
- (NSFormatter *) minorLabelFormatterForRange:(FlxGraphRange *)range forAxis:(FlxAxis *)axis{
    
    CGFloat minorWidth = ({
        CGFloat minorWidth = axis.graphSpace == FlxAxisSpaceX ? axis.bounds.size.width : axis.bounds.size.height;
        minorWidth *= range.tickSpan / range.boundSpan;
        minorWidth /= axis.minorTickCount;
        minorWidth;
    });
    
    if (minorWidth < 20){
        return nil;
    }

    NSFormatter *(^StandardFormatter)() = ^ NSFormatter *{
        if (!_standardMajorFormatter){
            _standardMajorFormatter = [[NSNumberFormatter alloc] init];
            [_standardMajorFormatter setLocale:[NSLocale currentLocale]];
        }
        double majorTickInt = [self _niceNum:range.tickSpan / 9 round:YES];
        
        double exp = floor(log10(majorTickInt));
        if (exp >= 0){
            _standardMajorFormatter.maximumFractionDigits = 0;
        } else {
            _standardMajorFormatter.maximumFractionDigits = fabs(exp);
        }
        
        return _standardMajorFormatter;
    };
    
    if (axis.isDateAxis){
        NSCalendarUnit major = NSCalendarUnitYear;
        NSCalendarUnit minor;
        if ([NSDateComponents getNiceMajorUnit:&major minor:&minor fromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMin] toDate:[NSDate dateWithTimeIntervalSinceReferenceDate:range.tickMax]]){
            NSDateFormatter *formatter = _minorDateFormatters[@(minor)];
            if (!formatter){
                formatter = [NSDateComponents minorFormatterForCalendarUnit:minor];
                _minorDateFormatters[@(minor)] = formatter;
            }
            return formatter;
        } else {
            return StandardFormatter();
        }
    } else {
        return StandardFormatter();
    }
}
@end
