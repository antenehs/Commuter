//
//  MatkaGeoCode.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaGeoCode.h"
#import "ReittiStringFormatter.h"

@implementation MatkaGeoCode

-(NSString *)address {
    if (!_address || [_address isEqualToString:@""]) {
        _address = _name;
    }
    
    return _address;
}

-(NSString *)coordString {
#if !(DEPARTURES_WIDGET)
    return [ReittiStringFormatter coordStringFromKkj3CoorsWithX:_xCoord andY:_yCoord];
#else
    return [NSString stringWithFormat:@"%@,%@", _xCoord, _yCoord];
#endif
}

-(CLLocationCoordinate2D)coord{
    return [ReittiStringFormatter convertStringTo2DCoord:_coordString];
}

@end
