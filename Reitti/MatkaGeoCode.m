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
    return [ReittiStringFormatter coordStringFromKkj3CoorsWithX:_xCoord andY:_yCoord];
}

-(CLLocationCoordinate2D)coord{
    return [ReittiStringFormatter convertStringTo2DCoord:_coordString];
}

@end
