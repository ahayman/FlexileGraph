//
//  NSDateComponents+flxGraphDateComponentsExt.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/10/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSCalendarUnit const AllMajorCalendarUnits;

@interface NSDateComponents (flxGraphDateComponentsExt)
+ (NSDateFormatter *) majorFormatterForCalendarUnit:(NSCalendarUnit)unit;
+ (NSDateFormatter *) minorFormatterForCalendarUnit:(NSCalendarUnit)unit;
+ (BOOL) getNiceMajorUnit:(NSCalendarUnit *)major minor:(NSCalendarUnit *)minor fromDate:(NSDate *)startDate toDate:(NSDate *)endDate;
- (void) setValue:(NSUInteger)value forUnit:(NSCalendarUnit)unit;
- (NSInteger) valueForCalendarUnit:(NSCalendarUnit)unit;
- (void) alignTo:(NSCalendarUnit)unit;
@end
