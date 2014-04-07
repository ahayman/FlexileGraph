//
//  FlxGraphSpace.m
//  FlexileGraph
//
//  Created by Aaron Hayman on 3/27/14.
//  Copyright (c) 2014 FlexileSoft, LLC. All rights reserved.
//

#import "FlxGraphSpace.h"

@implementation FlxGraphRange{
    double _rangeMax;
    double _rangeMin;
    double _upperBounds;
    double _lowerBounds;
}
- (id) init{
    if (self = [super init]){
        _rangeMax = 0;
        _rangeMin = 0;
        _upperBounds = 0;
        _lowerBounds = 0;
    }
    return self;
}
- (void) setRangeMax:(double)rangeMax{
    _rangeMax = rangeMax;
    if (_rangeMax < _rangeMin) _rangeMin = _rangeMax;
    if (_upperBounds > _rangeMax) _upperBounds = _rangeMax;
    if (_lowerBounds > _rangeMax) _lowerBounds = _rangeMax;
}
- (double) rangeMax{
    return  _rangeMax;
}
- (void) setRangeMin:(double)rangeMin{
    _rangeMin = rangeMin;
    if (_rangeMax < _rangeMin) _rangeMax = _rangeMin;
    if (_lowerBounds < _rangeMin) _lowerBounds = _rangeMin;
    if (_upperBounds < _rangeMin) _upperBounds = _rangeMin;
}
- (double) rangeMin{
    return _rangeMin;
}
- (double) rangeSpan{
    return _rangeMax - _rangeMin;
}
- (double) boundSpan{
    return _upperBounds - _lowerBounds;
}
@end

@implementation FlxGraphSpace

@end
