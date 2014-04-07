//
//  FlxAxisTickGenerator.h
//  FlexileGraph
//
//  Created by Aaron Hayman on 4/6/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlxAxis.h"

@interface NSDateComponents (flxUnitValue)
- (void) setValue:(NSUInteger)value forUnit:(NSCalendarUnit)unit;
- (NSInteger) valueForCalendarUnit:(NSCalendarUnit)unit;
- (void) alignTo:(NSCalendarUnit)unit;
@end

@interface FlxAxisTickGenerator : NSObject <FlxAxisTickDelegate>

@end
