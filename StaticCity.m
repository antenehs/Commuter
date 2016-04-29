//
//  StaticCity.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 26/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "StaticCity.h"

@implementation StaticCity

-(NSArray *)getArrayOfBoundaryArrays {
    if (!self.bounderies && self.bounderies.count == 0) return nil;
    NSMutableArray *boundaries = [@[] mutableCopy];
    
    for (NSString *coordsString in self.bounderies) {
        NSArray *coords = [coordsString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        [boundaries addObject:coords];
    }
    
    return boundaries;
}

@end
