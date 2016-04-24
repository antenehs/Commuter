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
#import "MatkaCommunicator.h"

@implementation MatkaLine

-(NSString *)codeFull {
    if (!_codeFull) {
        _codeFull = _codeShort;
    }
    
    return _codeFull;
}

-(NSString *)name {
    NSString *name = [self nameFi] ? [self nameFi] : [self nameSe];
    return name ? name : self.companyCode;
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
    NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:self.departureTime];
    return [ReittiStringFormatter createDateFromString:timeString withMinOffset:0];
}

-(LineType)lineType {
    if (self.transportType) {
        return [MatkaCommunicator lineTypeForMatkaTrasportType:self.transportType];
    }else{
        return LineTypeBus;
    }
}

-(NSString *)lineStart {
    if (!_lineStart) {
        if (self.name) {
            NSArray *comps = [self.name componentsSeparatedByString:@"-"];
            if (comps.count > 1) {
                _lineStart = [comps firstObject];
            }
        }
    }
    
    return _lineStart;
}

-(NSString *)lineEnd {
    if (!_lineEnd) {
        if (self.name) {
            NSArray *comps = [self.name componentsSeparatedByString:@"-"];
            if (comps.count > 1) {
                NSString *lineEnd = [comps lastObject];
                //There could be optional destinations at the end
                if ([lineEnd containsString:@"("] && [lineEnd containsString:@")"]) {
                    if (comps.count > 2) {
                        lineEnd = [NSString stringWithFormat:@"%@ - %@", comps[comps.count - 2], lineEnd];
                    }
                }
                _lineEnd = lineEnd;
            } else {
                _lineEnd = self.name;
            }
        }
    }
    
    return _lineEnd;
}

-(NSArray *)shapeCoordinates {
    if (!_shapeCoordinates) {
        if (self.lineStops && self.lineStops.count > 0) {
            NSMutableArray *tempArray = [@[] mutableCopy];
            
            for (MatkaStop *stop in self.lineStops) {
                CLLocation *loc = [[CLLocation alloc] initWithLatitude:stop.coords.latitude longitude:stop.coords.longitude];
                [tempArray addObject:loc];
            }
            _shapeCoordinates = tempArray;
        }
    }
    
    return _shapeCoordinates;
}

@end
