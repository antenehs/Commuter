//
//  DigiStopAtDistance.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/17/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DigiStopAtDistance.h"

@implementation DigiStopAtDistance


+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    MappingRelationShip *stopRelationShip = [MappingRelationShip relationShipFromKeyPath:@"node.stop"
                                                                               toKeyPath:@"stop"
                                                                        withMappingClass:[DigiStop class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:@{ @"node.distance" : @"distance" }
                                andRelationShips:@[stopRelationShip]];
}

@end
