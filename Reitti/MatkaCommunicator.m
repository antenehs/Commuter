//
//  MatkaCommunicator.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 9/4/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MatkaCommunicator.h"
#import "MatkaStop.h"
#import "ReittiStringFormatter.h"
#import "ReittiModels.h"


@implementation MatkaCommunicator

-(id)init{
    self = [super init];
    
    timeTableClient = [[APIClient alloc] init];
    timeTableClient.apiBaseUrl = @"http://api.matka.fi/timetables";
    
    genericClient = [[APIClient alloc] init];
    genericClient.apiBaseUrl = @"http://api.matka.fi";
    
    apiUserNames = @[@"asacommuter"];
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(RouteSearchOptions *)options andCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    [optionsDict setValue:[self getApiUsername] forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *fromPoint = [ReittiStringFormatter convertCoordsToKkj3Point:fromCoords];
    AGSPoint *toPoint = [ReittiStringFormatter convertCoordsToKkj3Point:toCoords];
    if (!fromPoint || !toPoint) return;
    
    [optionsDict setValue:[NSString stringWithFormat:@"%d,%d", (int)fromPoint.x, (int)fromPoint.y] forKey:@"a"];
    [optionsDict setValue:[NSString stringWithFormat:@"%d,%d", (int)toPoint.x, (int)toPoint.y] forKey:@"b"];
    
    [genericClient doXmlApiFetchWithParams:optionsDict responseDescriptor:[self routeResponseDescriptor] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        if (!error) {
//            NSMutableArray *responseArray = [@[] mutableCopy];
//            for (MatkaStop *stop in matkaStops) {
//                BusStopShort *reittiStop = [BusStopShort stopFromMatkaStop:stop];
//                if (reittiStop) [responseArray addObject:reittiStop];
//            }
            
            completionBlock(responseArray, nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
}

- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"stop" forKey:@"m"];
    [options setValue:@"50" forKey:@"count"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *point = [ReittiStringFormatter convertCoordsToKkj3Point:regionCenter];
    if (!point) return;
    
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.x] forKey:@"x"];
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.y] forKey:@"y"];
    
    [options setValue:[NSString stringWithFormat:@"%ld", diameter] forKey:@"radius"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[self stopResponseDescriptorForPath:@"MATKAXML.XY2STOPS.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        if (!error) {
            NSMutableArray *responseArray = [@[] mutableCopy];
            for (MatkaStop *stop in matkaStops) {
                BusStopShort *reittiStop = [BusStopShort stopFromMatkaStop:stop];
                if (reittiStop) [responseArray addObject:reittiStop];
            }
            
            completionBlock(responseArray, nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
}

- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"stopid" forKey:@"m"];
    [options setValue:@"50" forKey:@"count"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:stopCode forKey:@"stopid"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[self stopResponseDescriptorForPath:@"MATKAXML.STOP2TIMES.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
        if (!error && matkaStops.count > 0) {
            BusStop *stop = [BusStop stopFromMatkaStop:matkaStops[0]];

            completionBlock(stop, nil);
        } else {
            //API seems to fail if there is no departure. Differentiate that with other failures
            completionBlock(nil, nil); //TODO: Proper error message
        }
    }];
}

- (void)searchGeocodeForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    [options setValue:@"100" forKey:@"count"];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:searchTerm forKey:@"key"];
    
    [genericClient doXmlApiFetchWithParams:options responseDescriptor:[self geocodeResponseDescriptorForPath:@"MTRXML.GEOCODE.LOC"] andCompletionBlock:^(NSArray *matkaGeocodes, NSError *error) {
        if (!error) {
            NSMutableArray *geocodes = [@[] mutableCopy];
            for (MatkaGeoCode *matkaGeocode in matkaGeocodes)
                [geocodes addObject:[GeoCode geocodeForMatkaGeocode:matkaGeocode]];
            
            completionBlock(geocodes, nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
}

- (void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock {
    NSMutableDictionary *options = [@{} mutableCopy];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *point = [ReittiStringFormatter convertCoordsToKkj3Point:coords];
    if (!point) return;
    
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.x] forKey:@"x"];
    [options setValue:[NSString stringWithFormat:@"%d", (int)point.y] forKey:@"y"];
    
    [genericClient doXmlApiFetchWithParams:options responseDescriptor:[self geocodeResponseDescriptorForPath:@"MTRXML.REVERSE.LOC"] andCompletionBlock:^(NSArray *matkaGeocodes, NSError *error) {
        if (!error && matkaGeocodes.count > 0) {
            MatkaGeoCode *geocode = matkaGeocodes[0];
            geocode.xCoord = [NSNumber numberWithInteger:(int)point.x];
            geocode.yCoord = [NSNumber numberWithInteger:(int)point.y];
            completionBlock([GeoCode geocodeForMatkaGeocode:geocode], nil);
        } else {
            completionBlock(nil, @"Error occured"); //TODO: Proper error message
        }
    }];
}

- (RKResponseDescriptor *)routeResponseDescriptor {
    RKObjectMapping* routeMapping = [RKObjectMapping mappingForClass:[MatkaRouteLocation class] ];
    [routeMapping addAttributeMappingsFromDictionary:@{
                                                      @"LENGTH.time"     : @"time",
                                                      @"LENGTH.dist" : @"distance"
                                                      }];
    
    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"POINT"
                                                                                toKeyPath:@"points"
                                                                              withMapping:[self matkaRouteLocationMapping]]];
    
    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"LINE"
                                                                                toKeyPath:@"routeLegs"
                                                                              withMapping:[self matkaRouteLegMapping]]];
    
    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"WALK"
                                                                                 toKeyPath:@"routeLegs"
                                                                               withMapping:[self matkaRouteLegMapping]]];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:routeMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:@"MTRXML.ROUTE"
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}


- (RKResponseDescriptor *)stopResponseDescriptorForPath:(NSString *)keyPath {
   
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
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:stopMapping
                                                                                            method:RKRequestMethodAny
                                                                                       pathPattern:nil
                                                                                           keyPath:keyPath
                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    return responseDescriptor;
}

- (RKObjectMapping *)matkaLineObjectMapping {
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
    
    return lineMapping;
}

- (RKObjectMapping *)matkaNameObjectMapping {
    RKObjectMapping* nameMapping = [RKObjectMapping mappingForClass:[MatkaName class] ];
    [nameMapping addAttributeMappingsFromDictionary: @{ @"text" : @"name",
                                                        @"lang" : @"language"
                                                        }];
    return nameMapping;
}

- (RKObjectMapping *)matkaRouteLocationMapping {
    RKObjectMapping* locationMapping = [RKObjectMapping mappingForClass:[MatkaRouteLocation class] ];
    [locationMapping addAttributeMappingsFromDictionary:@{
                                                      @"uid"     : @"uid",
                                                      @"xCoord" : @"xCoord",
                                                      @"yCoord" : @"yCoord",
                                                      @"type" : @"type",
                                                      @"ARRIVAL.date" : @"arrivalDate",
                                                      @"ARRIVAL.time" : @"arrivalTime",
                                                      @"DEPARTURE.date" : @"departureDate",
                                                      @"DEPARTURE.time" : @"departureTime",
                                                      }];
    
    return locationMapping;
}

- (RKObjectMapping *)matkaRouteLegMapping {
    RKObjectMapping* legMapping = [RKObjectMapping mappingForClass:[MatkaRouteLocation class] ];
    [legMapping addAttributeMappingsFromDictionary:@{
                                                          @"LENGTH.time"     : @"time",
                                                          @"LENGTH.dist" : @"distance"
                                                          }];
    
    return legMapping;
}

- (RKResponseDescriptor *)geocodeResponseDescriptorForPath:(NSString *)keyPath {
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

#pragma mark - Helper methods
- (NSString *)getApiUsername{
    return apiUserNames[0];
}

@end
