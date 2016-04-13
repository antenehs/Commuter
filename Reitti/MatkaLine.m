//
//  MatkaLine.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 10/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaLine.h"
#import "MatkaName.h"
#import "ReittiStringFormatter.h"

@implementation MatkaLine

-(NSString *)codeFull {
    if (!_codeFull) {
        _codeFull = _codeShort;
    }
    
    return _codeFull;
}

-(NSString *)name {
    return [self nameFi] ? [self nameFi] : [self nameSe];
}

-(NSString *)nameFi {
    if (_lineNames && _lineNames.count > 0) {
        for (MatkaName *name in _lineNames) {
            if ([[name.language lowercaseString] isEqualToString:@"fi"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSString *)nameSe {
    if (_lineNames && _lineNames.count > 0) {
        for (MatkaName *name in _lineNames) {
            if ([[name.language lowercaseString] isEqualToString:@"se"]) {
                return name.name;
            }
        }
    }
    
    return nil;
}

-(NSDate *)parsedDepartureTime {
    NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:[self.departureTime stringValue]];
    return [ReittiStringFormatter createDateFromString:timeString withMinOffset:0];
}

@end
