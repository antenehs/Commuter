//
//  RouteSearchParameters.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 1/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "RouteSearchParameters.h"

@implementation RouteSearchParameters

-(id)initWithToLocation:(NSString *)toLocation toCoords:(NSString *)toCoords fromLocation:(NSString *)fromLocation fromCoords:(NSString *)fromCoords {
    self = [super init];
    if (self) {
        self.toCoords = [self nilOrValidCoordString:toCoords];
        self.toLocation = self.toCoords ? toLocation : nil;
        self.fromCoords = [self nilOrValidCoordString:fromCoords];
        self.fromLocation = self.fromCoords ? fromLocation : nil;
    }
    
    return self;
}

-(NSString *)toCoords {
    return [self nilOrValidCoordString:_toCoords];
}

-(NSString *)fromCoords {
    return [self nilOrValidCoordString:_fromCoords];
}

-(NSString *)nilOrValidCoordString:(NSString *)string {
    return [string isEqualToString:@""] ? nil : string;
}

@end
