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
- (double) tickMin{
    return MAX(_rangeMin, _lowerBounds);
}
- (double) tickMax{
    return MIN(_rangeMax, _upperBounds);
}
- (double) tickSpan{
    return self.tickMax - self.tickMin;
}
- (void) expandRangeByProportion:(double)prop{
    double span = self.rangeSpan;
    double newSpan = span * prop;
    double diff = (newSpan - span) / 2;
    self.rangeMin -= diff;
    self.rangeMax += diff;
}
- (void) expandBoundsByProportion:(double)prop{
    double span = self.boundSpan;
    double newSpan = span * prop;
    double diff = (newSpan - span) / 2;
    self.lowerBounds -= diff;
    self.upperBounds += diff;
}
@end

@implementation FlxGraphSpace
- (id) init{
    if (self = [super init]){
        _xRange = [FlxGraphRange new];
        _yRange = [FlxGraphRange new];
    }
    return self;
}
@end
