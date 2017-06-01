//
//  MatkaNearbyStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaStop.h"
#import "ReittiStringFormatter.h"

@implementation MatkaStop

-(NSString *)nameFi {
    if (_stopNames && _stopNames.count > 0) {
        for (MatkaName *name in _stopNames) {
            if ([[name.language lowercaseString] isEqualToString:@"fi"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameSe {
    if (_stopNames && _stopNames.count > 0) {
        for (MatkaName *name in _stopNames) {
            if ([[name.language lowercaseString] isEqualToString:@"se"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)name {
    return self.nameFi ? self.nameFi : self.nameSe;
}

//-(NSString *)coordString {
//#if !(DEPARTURES_WIDGET)
//    return [ReittiStringFormatter coordStringFromKkj3CoorsWithX:_xCoord andY:_yCoord];
//#else
//    return [NSString stringWithFormat:@"%@,%@", _xCoord, _yCoord];
//#endif
//}

-(CLLocationCoordinate2D)coords{
    return [ReittiStringFormatter convertStringTo2DCoord:self.coordString];
}

@end
