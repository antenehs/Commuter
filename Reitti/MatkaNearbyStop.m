//
//  MatkaNearbyStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaNearbyStop.h"

@implementation MatkaNearbyStop

-(NSString *)nameFi {
    if (_stopNames && _stopNames.count > 0) {
        for (MatkaStopName *name in _stopNames) {
            if ([[name.language lowercaseString] isEqualToString:@"fi"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameSe {
    if (_stopNames && _stopNames.count > 0) {
        for (MatkaStopName *name in _stopNames) {
            if ([[name.language lowercaseString] isEqualToString:@"se"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)coordString {
    return nil;
}

@end
