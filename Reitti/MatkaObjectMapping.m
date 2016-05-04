//
//  MatkaObjectMapping.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 3/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaObjectMapping.h"
#import "MatkaModels.h"

@implementation MatkaObjectMapping

+ (RKResponseDescriptor *)routeResponseDescriptor {
    RKObjectMapping* routeMapping = [RKObjectMapping mappingForClass:[MatkaRoute class] ];
    [routeMapping addAttributeMappingsFromDictionary:@{
                                                       @"LENGTH.time"     : @"time",
                                                       @"LENGTH.dist" : @"distance"
                                                       }];
    
    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"POINT"
                                                                                 toKeyPath:@"points"
                                                                               withMapping:[self matkaRouteLocationMapping]]];
    
    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"LINE"
                                                                                 toKeyPath:@"routeLineLegs"
                                                                               withMapping:[self matkaRouteLegMapping]]];
    
    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"WALK"
                                                                                 toKeyPath:@"routeWalkingLegs"
                                                                               withMapping:[self matkaRouteLegMapping]]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:routeMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"MTRXML.ROUTE"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}


+ (RKObjectMapping *)matkaStopMapping {
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaStop class] ];
    [stopMapping addAttributeMappingsFromDictionary:@{
                                                      @"xCoord" : @"xCoord",
                                                      @"yCoord" : @"yCoord",
                                                      @"id"     : @"stopId",
                                                      @"distance" : @"distance",
                                                      @"code" : @"stopShortCode",
                                                      @"tranportType" : @"transportType",
                                                      @"companyCode" : @"companyCode",
                                                      }];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
                                                                                toKeyPath:@"stopNames"
                                                                              withMapping:[self matkaNameObjectMapping]]];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"LINE"
                                                                                toKeyPath:@"stopLines"
                                                                              withMapping:[self matkaLineObjectMapping]]];
    return stopMapping;
}

+ (RKResponseDescriptor *)stopResponseDescriptorForPath:(NSString *)keyPath {
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self matkaStopMapping]
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:keyPath
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

+ (RKResponseDescriptor *)lineResponseDescriptorForKeyPath:(NSString *)keyPath detailed:(BOOL)detail {
    if (detail) {
        return [RKResponseDescriptor responseDescriptorWithMapping:[self matkaDetailLineObjectMapping]
                                                            method:RKRequestMethodAny
                                                       pathPattern:nil
                                                           keyPath:keyPath
                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    } else {
        return [RKResponseDescriptor responseDescriptorWithMapping:[self matkaLineObjectMapping]
                                                            method:RKRequestMethodAny
                                                       pathPattern:nil
                                                           keyPath:keyPath
                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    }
    
}

+ (RKObjectMapping *)matkaLineObjectMapping {
    RKObjectMapping* lineMapping = [RKObjectMapping mappingForClass:[MatkaLine class] ];
    [lineMapping addAttributeMappingsFromDictionary: @{ @"id" : @"lineId",
                                                        @"code" : @"codeShort",
                                                        @"codeOriginal" : @"codeFull",
                                                        @"companyCode" : @"companyCode",
                                                        @"transportType" : @"transportType",
                                                        @"tridentClass" : @"tridentClass",
                                                        @"arrivalTime" : @"arrivalTime",
                                                        @"departureTime" : @"departureTime"
                                                        }];
    
    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
                                                                                toKeyPath:@"lineNames"
                                                                              withMapping:[self matkaNameObjectMapping]]];
    
    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"STOP"
                                                                                toKeyPath:@"lineStops"
                                                                              withMapping:[self matkaLineStopObjectMapping]]];
    
    return lineMapping;
}

+ (RKObjectMapping *)matkaDetailLineObjectMapping {
    RKObjectMapping* lineMapping = [RKObjectMapping mappingForClass:[MatkaLine class] ];
    [lineMapping addAttributeMappingsFromDictionary: @{ @"lineId" : @"lineId" }];
    
    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
                                                                                toKeyPath:@"lineNames"
                                                                              withMapping:[self matkaNameObjectMapping]]];
    
    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"STOP"
                                                                                toKeyPath:@"lineStops"
                                                                              withMapping:[self matkaLineStopObjectMapping]]];
    
    return lineMapping;
}

+ (RKObjectMapping *)matkaLineStopObjectMapping {
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaStop class] ];
    [stopMapping addAttributeMappingsFromDictionary:@{
                                                      @"xCoord" : @"xCoord",
                                                      @"yCoord" : @"yCoord",
                                                      @"id"     : @"stopId",
                                                      @"code" : @"stopShortCode",
                                                      @"tranportType" : @"transportType",
                                                      @"companyCode" : @"companyCode",
                                                      }];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
                                                                                toKeyPath:@"stopNames"
                                                                              withMapping:[self matkaNameObjectMapping]]];
    
    return stopMapping;
}

+ (RKObjectMapping *)matkaNameObjectMapping {
    RKObjectMapping* nameMapping = [RKObjectMapping mappingForClass:[MatkaName class] ];
    [nameMapping addAttributeMappingsFromDictionary: @{ @"text" : @"name",
                                                        @"lang" : @"language"
                                                        }];
    return nameMapping;
}

+ (RKObjectMapping *)matkaRouteLocationMapping {
    RKObjectMapping* locationMapping = [RKObjectMapping mappingForClass:[MatkaRouteLocation class] ];
    [locationMapping addAttributeMappingsFromDictionary:@{
                                                          @"uid"     : @"uid",
                                                          @"x" : @"xCoord",
                                                          @"y" : @"yCoord",
                                                          @"type" : @"type",
                                                          @"ARRIVAL.date" : @"arrivalDate",
                                                          @"ARRIVAL.time" : @"arrivalTime",
                                                          @"DEPARTURE.date" : @"departureDate",
                                                          @"DEPARTURE.time" : @"departureTime",
                                                          }];
    
    [locationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"NAME"
                                                                                    toKeyPath:@"locNames"
                                                                                  withMapping:[self matkaRouteLocNameMapping]]];
    
    return locationMapping;
}

+ (RKObjectMapping *)matkaRouteStopMapping {
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaRouteStop class] ];
    [stopMapping addAttributeMappingsFromDictionary:@{
                                                      @"code"     : @"stopCode",
                                                      @"id"     : @"stopId",
                                                      @"ord"     : @"stopOrder",
                                                      @"x" : @"xCoord",
                                                      @"y" : @"yCoord",
                                                      @"type" : @"type",
                                                      @"ARRIVAL.date" : @"arrivalDate",
                                                      @"ARRIVAL.time" : @"arrivalTime",
                                                      @"DEPARTURE.date" : @"departureDate",
                                                      @"DEPARTURE.time" : @"departureTime",
                                                      }];
    
    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"NAME"
                                                                                toKeyPath:@"stopNames"
                                                                              withMapping:[self matkaRouteLocNameMapping]]];
    
    return stopMapping;
}

+ (RKObjectMapping *)matkaRouteLocNameMapping {
    RKObjectMapping* nameMapping = [RKObjectMapping mappingForClass:[MatkaName class] ];
    [nameMapping addAttributeMappingsFromDictionary: @{ @"val" : @"name",
                                                        @"lang" : @"language"
                                                        }];
    return nameMapping;
}

+ (RKObjectMapping *)matkaRouteLegMapping {
    RKObjectMapping* legMapping = [RKObjectMapping mappingForClass:[MatkaRouteLeg class] ];
    [legMapping addAttributeMappingsFromDictionary:@{
                                                     @"LENGTH.time"     : @"time",
                                                     @"LENGTH.dist" : @"distance",
                                                     @"id" : @"lineId",
                                                     @"code" : @"codeShort",
                                                     @"type" : @"transportType"
                                                     }];
    
    [legMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"POINT"
                                                                               toKeyPath:@"startDestPoints"
                                                                             withMapping:[self matkaRouteLocationMapping]]];
    
    [legMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"MAPLOC"
                                                                               toKeyPath:@"locations"
                                                                             withMapping:[self matkaRouteLocationMapping]]];
    
    [legMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"STOP"
                                                                               toKeyPath:@"stops"
                                                                             withMapping:[self matkaRouteStopMapping]]];
    
    return legMapping;
}

+ (RKResponseDescriptor *)geocodeResponseDescriptorForPath:(NSString *)keyPath {
    /*
     <LOC name1="Teeripalontie" number="3" city="Ranua" code="" address="" type="900" category="street" x="3460901" y="7315588"/>
     */
    RKObjectMapping* geocodeMapping = [RKObjectMapping mappingForClass:[MatkaGeoCode class] ];
    [geocodeMapping addAttributeMappingsFromDictionary:@{
                                                         @"x" : @"xCoord",
                                                         @"y" : @"yCoord",
                                                         @"name1" : @"name",
                                                         @"number" : @"number",
                                                         @"city" : @"city",
                                                         @"code" : @"code",
                                                         @"address" : @"address",
                                                         @"type" : @"type",
                                                         @"category" : @"category"
                                                         }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:geocodeMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:keyPath
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}


@end
