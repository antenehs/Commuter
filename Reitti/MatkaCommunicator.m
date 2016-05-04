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
#import "MatkaObjectMapping.h"
#import "ReittiDateFormatter.h"

@interface MatkaCommunicator()

@end

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
    
    NSDictionary *optionsDict = [self apiRequestParametersDictionaryForRouteOptions:options];
    
    [optionsDict setValue:[self getApiUsername] forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    AGSPoint *fromPoint = [ReittiStringFormatter convertCoordsToKkj3Point:fromCoords];
    AGSPoint *toPoint = [ReittiStringFormatter convertCoordsToKkj3Point:toCoords];
    if (!fromPoint || !toPoint) return;
    
    [optionsDict setValue:[NSString stringWithFormat:@"%d,%d", (int)fromPoint.x, (int)fromPoint.y] forKey:@"a"];
    [optionsDict setValue:[NSString stringWithFormat:@"%d,%d", (int)toPoint.x, (int)toPoint.y] forKey:@"b"];
    [optionsDict setValue:@"5" forKey:@"show"];
    
    [genericClient doXmlApiFetchWithParams:optionsDict responseDescriptor:[MatkaObjectMapping routeResponseDescriptor] andCompletionBlock:^(NSArray *matkaRoutes, NSError *error) {
        if (!error) {
            NSMutableArray *responseArray = [@[] mutableCopy];
            for (MatkaRoute *route in matkaRoutes) {
                Route *reittiRoute = [Route routeFromMatkaRoute:route];
                if (reittiRoute) [responseArray addObject:reittiRoute];
            }
            
            completionBlock(responseArray, nil);
        } else {
            completionBlock(nil, @"Route search failed."); //TODO: Proper error message
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
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping stopResponseDescriptorForPath:@"MATKAXML.XY2STOPS.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
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
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping stopResponseDescriptorForPath:@"MATKAXML.STOP2TIMES.STOP"] andCompletionBlock:^(NSArray *matkaStops, NSError *error) {
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
    
    [genericClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping geocodeResponseDescriptorForPath:@"MTRXML.GEOCODE.LOC"] andCompletionBlock:^(NSArray *matkaGeocodes, NSError *error) {
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
    
    [genericClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping geocodeResponseDescriptorForPath:@"MTRXML.REVERSE.LOC"] andCompletionBlock:^(NSArray *matkaGeocodes, NSError *error) {
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

- (void)fetchLinesForSearchterm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock {
    if (!searchTerm || [searchTerm isEqualToString:@""]) return;
    NSMutableDictionary *options = [@{} mutableCopy];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:@"text" forKey:@"m"];
    [options setValue:searchTerm forKey:@"text"];
    
    [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping lineResponseDescriptorForKeyPath:@"MATKAXML.TXT2LINES.LINE" detailed:NO] andCompletionBlock:^(NSArray *matkaLines, NSError *error) {
        if (!error && matkaLines && matkaLines.count > 0) {
            NSMutableArray *lines = [@[] mutableCopy];
            for (MatkaLine *matkaLine in matkaLines) {
                Line *line = [Line lineFromMatkaLine:matkaLine];
                if (line) {
                    [lines addObject:line];
                }
            }
            
            completionBlock(lines, nil);
        } else {
            completionBlock(nil, nil); //TODO: Proper error message
        }
    }];
}

- (void)fetchLinesForCodes:(NSArray *)lineCodes withCompletionBlock:(ActionBlock)completionBlock {
    if (!lineCodes || lineCodes.count == 0) return;
    NSMutableDictionary *options = [@{} mutableCopy];
    
    [options setValue:[self getApiUsername] forKey:@"user"];
    [options setValue:@"rebekah" forKey:@"pass"];
    
    [options setValue:@"lineid" forKey:@"m"];
    
    __block NSInteger numberOfLines = lineCodes.count;
    __block NSMutableArray *allLines = [@[] mutableCopy];
    
    for (NSString *lineid in lineCodes) {
        [options setValue:lineid forKey:@"lineid"];
        [timeTableClient doXmlApiFetchWithParams:options responseDescriptor:[MatkaObjectMapping lineResponseDescriptorForKeyPath:@"MATKAXML.LINE2STOPS" detailed:YES] andCompletionBlock:^(NSArray *matkaLines, NSError *error) {
            numberOfLines--;
            if (!error && matkaLines && matkaLines.count > 0) {
                for (MatkaLine *matkaLine in matkaLines) {
                    Line *line = [Line lineFromMatkaLine:matkaLine];
                    if (line)
                        [allLines addObject:line];
                }
                if (numberOfLines == 0)
                    completionBlock(allLines, nil);
            } else {
                if (numberOfLines == 0)
                    completionBlock(allLines, nil);
            }
        }];
    }
}

#pragma mark - Route search option

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(RouteSearchOptions *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    /* Optimization string */
    NSString *optimizeString;
    if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionFastest) {
        optimizeString = @"2";
    }else if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastTransfer) {
        optimizeString = @"3";
    }else if (searchOptions.selectedRouteSearchOptimization == RouteSearchOptionLeastWalking) {
        optimizeString = @"4";
    }else{
        optimizeString = @"1";
    }
    
    [parametersDict setObject:optimizeString forKey:@"optimize"];
    
    /* Search date and time */
    NSDate * searchDate = searchOptions.date;
    if (searchDate == nil)
        searchDate = [NSDate date];
    
    NSString *time = [[[ReittiDateFormatter sharedFormatter] apiHourFormatter] stringFromDate:searchDate];
    NSString *date = [[[ReittiDateFormatter sharedFormatter] apiDateFormatter] stringFromDate:searchDate];
    
    NSString *timeType;
    if (searchOptions.selectedTimeType == RouteTimeNow || searchOptions.selectedTimeType == RouteTimeDeparture)
        timeType = @"1";
    else
        timeType = @"2";
    
    [parametersDict setObject:time forKey:@"time"];
    [parametersDict setObject:date forKey:@"date"];
    [parametersDict setObject:timeType forKey:@"timemode"];
    
    /* Change Margine */
    if (searchOptions.selectedChangeMargine != nil && ![searchOptions.selectedChangeMargine isEqualToString:@"3 minutes (Default)"]) {
        [parametersDict setObject:[self.changeMargineOptions objectForKey:searchOptions.selectedChangeMargine] forKey:@"margin"];
    }
    
    /* Walking Speed */
    if (searchOptions.selectedWalkingSpeed != nil && ![searchOptions.selectedWalkingSpeed isEqualToString:@"Normal Walking (Default)"]) {
        [parametersDict setObject:[self.walkingSpeedOptions objectForKey:searchOptions.selectedWalkingSpeed] forKey:@"walkspeed"];
    }
    
    if (searchOptions.numberOfResults == kDefaultNumberOfResults) {
        [parametersDict setObject:@"5" forKey:@"show"];
    }else{
        [parametersDict setObject:[NSString stringWithFormat:@"%ld", (long)searchOptions.numberOfResults] forKey:@"show"];
    }
    
    return parametersDict;
}

-(NSArray *)allTrasportTypeNames {
    return @[@"Bus", @"Metro", @"Train", @"Tram", @"Ferry", @"Airplane", @"Uline"];
}

-(NSArray *)getTransportTypeOptions {
    return nil;
}

-(NSArray *)getTicketZoneOptions {
    return nil;
}

-(NSArray *)getChangeMargineOptions {
    return @[@{displayTextOptionKey : @"0 minute" , valueOptionKey: @"0"},
             @{displayTextOptionKey : @"1 minute" , valueOptionKey: @"1"},
             @{displayTextOptionKey : @"3 minutes (Default)", valueOptionKey : @"3", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"5 minutes", valueOptionKey : @"5"},
             @{displayTextOptionKey : @"7 minutes", valueOptionKey : @"7"},
             @{displayTextOptionKey : @"9 minutes", valueOptionKey : @"9"},
             @{displayTextOptionKey : @"10 minutes", valueOptionKey : @"10"}];
}

-(NSInteger)getDefaultValueIndexForChangeMargineOptions {
    return 2;
}

-(NSArray *)getWalkingSpeedOptions {
    return @[@{displayTextOptionKey : @"Slow Walking", detailOptionKey : @"30 m/minute", valueOptionKey : @"30"},
             @{displayTextOptionKey : @"Normal Walking (Default)" , detailOptionKey : @"70 m/minute", valueOptionKey: @"70", defaultOptionKey : @"yes"},
             @{displayTextOptionKey : @"Fast Walking", detailOptionKey : @"100 m/minute", valueOptionKey : @"100"},
             @{displayTextOptionKey : @"Running", detailOptionKey : @"200 m/minute", valueOptionKey : @"200"},
             @{displayTextOptionKey : @"Bolting", detailOptionKey : @"300 m/minute", valueOptionKey : @"300"}];
}

-(NSInteger)getDefaultValueIndexForWalkingSpeedOptions {
    return 1;
}

-(NSInteger)getDefaultValueIndexForTicketZoneOptions {
    return 0;
}

-(NSDictionary *)changeMargineOptions{
    return @{@"0 minute" : @"0",
             @"1 minute" : @"1",
             @"3 minutes (Default)" : @"3",
             @"5 minutes" : @"5",
             @"7 minutes" : @"7",
             @"9 minutes" : @"9",
             @"10 minutes" : @"10"};
}

-(NSDictionary *)walkingSpeedOptions{
    return @{@"Slow Walking" : @"1",
             @"Normal Walking (Default)" : @"2",
             @"Fast Walking" : @"3",
             @"Running" : @"4",
             @"Bolting" : @"5"};
}

//- (RKResponseDescriptor *)routeResponseDescriptor {
//    RKObjectMapping* routeMapping = [RKObjectMapping mappingForClass:[MatkaRoute class] ];
//    [routeMapping addAttributeMappingsFromDictionary:@{
//                                                      @"LENGTH.time"     : @"time",
//                                                      @"LENGTH.dist" : @"distance"
//                                                      }];
//    
//    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"POINT"
//                                                                                toKeyPath:@"points"
//                                                                              withMapping:[self matkaRouteLocationMapping]]];
//    
//    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"LINE"
//                                                                                toKeyPath:@"routeLineLegs"
//                                                                              withMapping:[self matkaRouteLegMapping]]];
//    
//    [routeMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"WALK"
//                                                                                 toKeyPath:@"routeWalkingLegs"
//                                                                               withMapping:[self matkaRouteLegMapping]]];
//    
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:routeMapping
//                                                                                            method:RKRequestMethodAny
//                                                                                       pathPattern:nil
//                                                                                           keyPath:@"MTRXML.ROUTE"
//                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    return responseDescriptor;
//}
//
//
//- (RKObjectMapping *)matkaStopMapping {
//    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaStop class] ];
//    [stopMapping addAttributeMappingsFromDictionary:@{
//                                                      @"xCoord" : @"xCoord",
//                                                      @"yCoord" : @"yCoord",
//                                                      @"id"     : @"stopId",
//                                                      @"distance" : @"distance",
//                                                      @"code" : @"stopShortCode",
//                                                      @"tranportType" : @"transportType",
//                                                      @"companyCode" : @"companyCode",
//                                                      }];
//    
//    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
//                                                                                toKeyPath:@"stopNames"
//                                                                              withMapping:[self matkaNameObjectMapping]]];
//    
//    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"LINE"
//                                                                                toKeyPath:@"stopLines"
//                                                                              withMapping:[self matkaLineObjectMapping]]];
//    return stopMapping;
//}
//
//- (RKResponseDescriptor *)stopResponseDescriptorForPath:(NSString *)keyPath {
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[self matkaStopMapping]
//                                                                                            method:RKRequestMethodAny
//                                                                                       pathPattern:nil
//                                                                                           keyPath:keyPath
//                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    return responseDescriptor;
//}
//
//- (RKResponseDescriptor *)lineResponseDescriptorForKeyPath:(NSString *)keyPath detailed:(BOOL)detail {
//    if (detail) {
//        return [RKResponseDescriptor responseDescriptorWithMapping:[self matkaDetailLineObjectMapping]
//                                                            method:RKRequestMethodAny
//                                                       pathPattern:nil
//                                                           keyPath:keyPath
//                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    } else {
//        return [RKResponseDescriptor responseDescriptorWithMapping:[self matkaLineObjectMapping]
//                                                            method:RKRequestMethodAny
//                                                       pathPattern:nil
//                                                           keyPath:keyPath
//                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    }
//    
//}
//
//- (RKObjectMapping *)matkaLineObjectMapping {
//    RKObjectMapping* lineMapping = [RKObjectMapping mappingForClass:[MatkaLine class] ];
//    [lineMapping addAttributeMappingsFromDictionary: @{ @"id" : @"lineId",
//                                                        @"code" : @"codeShort",
//                                                        @"codeOriginal" : @"codeFull",
//                                                        @"companyCode" : @"companyCode",
//                                                        @"transportType" : @"transportType",
//                                                        @"tridentClass" : @"tridentClass",
//                                                        @"arrivalTime" : @"arrivalTime",
//                                                        @"departureTime" : @"departureTime"
//                                                        }];
//    
//    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
//                                                                                toKeyPath:@"lineNames"
//                                                                              withMapping:[self matkaNameObjectMapping]]];
//    
//    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"STOP"
//                                                                                toKeyPath:@"lineStops"
//                                                                              withMapping:[self matkaLineStopObjectMapping]]];
//    
//    return lineMapping;
//}
//
//- (RKObjectMapping *)matkaDetailLineObjectMapping {
//    RKObjectMapping* lineMapping = [RKObjectMapping mappingForClass:[MatkaLine class] ];
//    [lineMapping addAttributeMappingsFromDictionary: @{ @"lineId" : @"lineId" }];
//    
//    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
//                                                                                toKeyPath:@"lineNames"
//                                                                              withMapping:[self matkaNameObjectMapping]]];
//    
//    [lineMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"STOP"
//                                                                                toKeyPath:@"lineStops"
//                                                                              withMapping:[self matkaLineStopObjectMapping]]];
//    
//    return lineMapping;
//}
//
//- (RKObjectMapping *)matkaLineStopObjectMapping {
//    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaStop class] ];
//    [stopMapping addAttributeMappingsFromDictionary:@{
//                                                      @"xCoord" : @"xCoord",
//                                                      @"yCoord" : @"yCoord",
//                                                      @"id"     : @"stopId",
//                                                      @"code" : @"stopShortCode",
//                                                      @"tranportType" : @"transportType",
//                                                      @"companyCode" : @"companyCode",
//                                                      }];
//    
//    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"name"
//                                                                                toKeyPath:@"stopNames"
//                                                                              withMapping:[self matkaNameObjectMapping]]];
//    
//    return stopMapping;
//}
//
//- (RKObjectMapping *)matkaNameObjectMapping {
//    RKObjectMapping* nameMapping = [RKObjectMapping mappingForClass:[MatkaName class] ];
//    [nameMapping addAttributeMappingsFromDictionary: @{ @"text" : @"name",
//                                                        @"lang" : @"language"
//                                                        }];
//    return nameMapping;
//}
//
//- (RKObjectMapping *)matkaRouteLocationMapping {
//    RKObjectMapping* locationMapping = [RKObjectMapping mappingForClass:[MatkaRouteLocation class] ];
//    [locationMapping addAttributeMappingsFromDictionary:@{
//                                                      @"uid"     : @"uid",
//                                                      @"x" : @"xCoord",
//                                                      @"y" : @"yCoord",
//                                                      @"type" : @"type",
//                                                      @"ARRIVAL.date" : @"arrivalDate",
//                                                      @"ARRIVAL.time" : @"arrivalTime",
//                                                      @"DEPARTURE.date" : @"departureDate",
//                                                      @"DEPARTURE.time" : @"departureTime",
//                                                      }];
//    
//    [locationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"NAME"
//                                                                                toKeyPath:@"locNames"
//                                                                              withMapping:[self matkaRouteLocNameMapping]]];
//    
//    return locationMapping;
//}
//
//- (RKObjectMapping *)matkaRouteStopMapping {
//    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[MatkaRouteStop class] ];
//    [stopMapping addAttributeMappingsFromDictionary:@{
//                                                          @"code"     : @"stopCode",
//                                                          @"id"     : @"stopId",
//                                                          @"ord"     : @"stopOrder",
//                                                          @"x" : @"xCoord",
//                                                          @"y" : @"yCoord",
//                                                          @"type" : @"type",
//                                                          @"ARRIVAL.date" : @"arrivalDate",
//                                                          @"ARRIVAL.time" : @"arrivalTime",
//                                                          @"DEPARTURE.date" : @"departureDate",
//                                                          @"DEPARTURE.time" : @"departureTime",
//                                                          }];
//    
//    [stopMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"NAME"
//                                                                                toKeyPath:@"stopNames"
//                                                                              withMapping:[self matkaRouteLocNameMapping]]];
//    
//    return stopMapping;
//}
//
//- (RKObjectMapping *)matkaRouteLocNameMapping {
//    RKObjectMapping* nameMapping = [RKObjectMapping mappingForClass:[MatkaName class] ];
//    [nameMapping addAttributeMappingsFromDictionary: @{ @"val" : @"name",
//                                                        @"lang" : @"language"
//                                                        }];
//    return nameMapping;
//}
//
//- (RKObjectMapping *)matkaRouteLegMapping {
//    RKObjectMapping* legMapping = [RKObjectMapping mappingForClass:[MatkaRouteLeg class] ];
//    [legMapping addAttributeMappingsFromDictionary:@{
//                                                          @"LENGTH.time"     : @"time",
//                                                          @"LENGTH.dist" : @"distance",
//                                                          @"id" : @"lineId",
//                                                          @"code" : @"codeShort",
//                                                          @"type" : @"transportType"
//                                                          }];
//    
//    [legMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"POINT"
//                                                                                 toKeyPath:@"startDestPoints"
//                                                                               withMapping:[self matkaRouteLocationMapping]]];
//    
//    [legMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"MAPLOC"
//                                                                               toKeyPath:@"locations"
//                                                                             withMapping:[self matkaRouteLocationMapping]]];
//    
//    [legMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"STOP"
//                                                                               toKeyPath:@"stops"
//                                                                             withMapping:[self matkaRouteStopMapping]]];
//    
//    return legMapping;
//}
//
//- (RKResponseDescriptor *)geocodeResponseDescriptorForPath:(NSString *)keyPath {
//    /*
//      <LOC name1="Teeripalontie" number="3" city="Ranua" code="" address="" type="900" category="street" x="3460901" y="7315588"/>
//     */
//    RKObjectMapping* geocodeMapping = [RKObjectMapping mappingForClass:[MatkaGeoCode class] ];
//    [geocodeMapping addAttributeMappingsFromDictionary:@{
//                                                      @"x" : @"xCoord",
//                                                      @"y" : @"yCoord",
//                                                      @"name1" : @"name",
//                                                      @"number" : @"number",
//                                                      @"city" : @"city",
//                                                      @"code" : @"code",
//                                                      @"address" : @"address",
//                                                      @"type" : @"type",
//                                                      @"category" : @"category"
//                                                      }];
//    
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:geocodeMapping
//                                                                                            method:RKRequestMethodAny
//                                                                                       pathPattern:nil
//                                                                                           keyPath:keyPath
//                                                                                       statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    return responseDescriptor;
//}

#pragma mark - Helper methods
//+ (LineType)lineTypeForMatkaTrasportType:(NSNumber *)trasportType {
//    if (!trasportType) return LineTypeBus;
//    NSArray *busTypes = @[@1, @8, @9, @10, @11, @15, @16, @17, @19, @21, @23, @25, @27, @28, @29
//                          , @31, @32, @33, @34, @35, @37, @38, @39, @42, @43, @44, @45, @48
//                          , @49, @50, @51, @52, @53, @54, @55, @56, @57, @58, @59, @60, @61
//                          , @62, @63, @64, @65, @66, @67, @68, @69, @70];
//    
//    NSArray *trainTypes = @[@7, @12, @13, @46];
//    NSArray *longdistanceTrainTypes = @[@2, @3, @4, @5, @6, @14, @47];
//    NSArray *metroTypes = @[@40];
//    NSArray *tramTypes = @[@36];
//    NSArray *ferryTypes = @[@41];
//    NSArray *airplaneTypes = @[@26];
//    NSArray *otherTypes = @[@18, @30];
//    
//    if ([busTypes containsObject:trasportType]) {
//        return LineTypeBus;
//    } else if ([trainTypes containsObject:trasportType]) {
//        return LineTypeTrain;
//    } else if ([longdistanceTrainTypes containsObject:trasportType]) {
//        return LineTypeLongDistanceTrain;
//    } else if ([metroTypes containsObject:trasportType]) {
//        return LineTypeMetro;
//    } else if ([tramTypes containsObject:trasportType]) {
//        return LineTypeTram;
//    } else if ([ferryTypes containsObject:trasportType]) {
//        return LineTypeFerry;
//    } else if ([airplaneTypes containsObject:trasportType]) {
//        return LineTypeAirplane;
//    } else if ([otherTypes containsObject:trasportType])  {
//        return LineTypeOther;
//    } else {
//        return LineTypeOther;
//    }
//}
//
//+ (LegTransportType)legTypeForMatkaTrasportType:(NSNumber *)trasportType {
//    LineType lineType = [MatkaCommunicator lineTypeForMatkaTrasportType:trasportType];
//    return [EnumManager legTrasportTypeForLineType:lineType];
//}

- (NSString *)getApiUsername{
    return apiUserNames[0];
}

@end
