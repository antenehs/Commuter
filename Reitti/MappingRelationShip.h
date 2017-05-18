//
//  MappingRelationShip.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 5/17/17.
//  Copyright © 2017 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReittiMapping.h"

@interface MappingRelationShip : NSObject

+(instancetype)relationShipFromKeyPath:(NSString *)fromKeyPath toKeyPath:(NSString *)toKeyPath withMappingClass:(Class<Mappable>)mappableClass;

@property(strong, nonatomic)NSString *fromKeyPath;
@property(strong, nonatomic)NSString *toKeypath;
@property(nonatomic)Class<Mappable> mappableClass;

@end
