//
//  MappingRelationShip.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import "MappingRelationShip.h"

@implementation MappingRelationShip

+(instancetype)relationShipFromKeyPath:(NSString *)fromKeyPath toKeyPath:(NSString *)toKeyPath withMappingClass:(Class<Mappable>)mappableClass {
    MappingRelationShip *relationShip = [self new];
    relationShip.fromKeyPath = fromKeyPath;
    relationShip.toKeypath = toKeyPath;
    relationShip.mappableClass = mappableClass;
    return relationShip;
}

@end
