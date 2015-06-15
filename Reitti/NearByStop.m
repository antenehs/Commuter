//
//  NearByStop.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 23/5/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "NearByStop.h"
#import "StopLines.h"

@implementation NearByStop

-(NSString *)stopCode{
    return self.properties.propertiesIdentifier;
}

-(NSString *)stopShortCode{
    return self.properties.code;
}

-(NSString *)stopName{
    return self.properties.name;
}

-(CLLocationCoordinate2D )coords{
    NSNumber *longitude = [self.geometry.coordinates objectAtIndex:0];
    NSNumber *latitude = [self.geometry.coordinates objectAtIndex:1];
    CLLocationCoordinate2D coordinate = {.latitude = [latitude doubleValue] , .longitude =  [longitude doubleValue]};
    
    return coordinate;
}

-(double)distance{
    return self.properties.dist;
}

-(StopType)stopType{
    return [EnumManager stopTypeForPubTransStopType:self.properties.type];
}

-(NSArray *)lines{
    return self.properties.lines;
}

-(NSString *)stopAddress{
    return self.properties.addr;
}


-(NSString *)linesAsCommaSepString{
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (StopLines *line in self.lines) {
        if (![tempArray containsObject:line.name]) {
            [tempArray addObject:line.name];
        }
    }
    if (tempArray.count > 0) {
        return [[tempArray valueForKey:@"description"] componentsJoinedByString:@"|"];
    }else{
        return @"";
    }
}

@end
