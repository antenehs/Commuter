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

-(NSString *)coordString {
    return [ReittiStringFormatter coordStringFromKkj3CoorsWithX:_xCoord andY:_yCoord];
}

-(CLLocationCoordinate2D)coord{
    return [ReittiStringFormatter convertStringTo2DCoord:_coordString];
}

@end
