//
//  DigiVehicleActivityContainer.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/21/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "DigiVehicleActivityContainer.h"
#import "DigiVehicle.h"

@implementation DigiVehicleActivityContainer

#pragma mark - Mapping
+(NSDictionary *)mappingDictionary {
    return @{ @"version"            : @"version",
              @"ResponseTimestamp"  : @"ResponseTimestamp"
             };
}

+(MappingDescriptor *)mappingDescriptorForPath:(NSString *)path {
    
    MappingRelationShip *vehiclesRelation = [MappingRelationShip relationShipFromKeyPath:@"VehicleActivity"
                                                                               toKeyPath:@"vehicles"
                                                                        withMappingClass:[DigiVehicle class]];
    
    return [MappingDescriptor descriptorFromPath:path
                                        forClass:[self class]
                           withMappingDictionary:[self mappingDictionary]
                                andRelationShips:@[vehiclesRelation]];
    
}

@end
