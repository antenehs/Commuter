//
//  WatchHslApi.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 28/6/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "WatchHslApi.h"
#import "HSLRouteOptionManager.h"
#import "ReittiStringFormatterE.h"
#import "Route.h"
#import "BusStopE.h"
#import "StopLine.h"
#import "NSString+Helper.h"
#import "EnumManager.h"

@implementation WatchHslApi

-(instancetype)init {
    self = [super init];
    if (self) {
        self.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    }
    
    return self;
}

- (void)searchRouteForFromCoords:(CLLocationCoordinate2D)fromCoords andToCoords:(CLLocationCoordinate2D)toCoords withOptions:(NSDictionary *)optionsDict andCompletionBlock:(ActionBlock)completionBlock {
    
    NSDictionary *searchParameters = [@{} mutableCopy];
    if (!optionsDict) {
        searchParameters = [@{} mutableCopy];
    } else {
        searchParameters = [[self apiRequestParametersDictionaryForRouteOptions:optionsDict] mutableCopy];
    }
    
    [searchParameters setValue:@"asacommuterwidget2" forKey:@"user"];
    [searchParameters setValue:@"rebekah" forKey:@"pass"];
    
    [searchParameters setValue:@"route" forKey:@"request"];
    [searchParameters setValue:@"4326" forKey:@"epsg_in"];
    [searchParameters setValue:@"4326" forKey:@"epsg_out"];
    [searchParameters setValue:@"json" forKey:@"format"];
    
    [searchParameters setValue:[ReittiStringFormatterE convert2DCoordToString:fromCoords] forKey:@"from"];
    [searchParameters setValue:[ReittiStringFormatterE convert2DCoordToString:toCoords] forKey:@"to"];
    
    [super doApiFetchWithOutMappingWithParams:searchParameters andCompletionBlock:^(NSData *responseData, NSError *error){
        if (!error) {
            NSArray *routes = [self routesFromJSON:responseData error:nil];
            completionBlock(routes, nil);
        }else{
            completionBlock(nil, error);
        }
    }];

}

- (void)fetchStopForCode:(NSString *)code andCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *paramsDict = [@{} mutableCopy];
    
    [paramsDict setValue:@"asacommuterwidget2" forKey:@"user"];
    [paramsDict setValue:@"rebekah" forKey:@"pass"];

    [paramsDict setValue:@"stop" forKey:@"request"];
    [paramsDict setValue:@"4326" forKey:@"epsg_in"];
    [paramsDict setValue:@"4326" forKey:@"epsg_out"];
    [paramsDict setValue:@"json" forKey:@"format"];
    [paramsDict setValue:@"20" forKey:@"dep_limit"];
    [paramsDict setValue:@"360" forKey:@"time_limit"];
    
    [paramsDict setValue:code forKey:@"code"];
    
    [super doApiFetchWithOutMappingWithParams:paramsDict andCompletionBlock:^(NSData *responseData, NSError *error){
        if (!error) {
            NSArray *stops = [self stopFromJSON:responseData error:nil];
            if (stops.count > 0)
                completionBlock(stops[0], nil);
            else
                completionBlock(nil, @"Fetching departures failed");
        }else{
            completionBlock(nil, [self stopFetchErrorMessageForError:error]);
        }
    }];
}

-(NSArray *)stopFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *stops = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in parsedObject) {
        BusStopE *stop = [[BusStopE alloc] initWithDictionary:dict];
        if (stop){
            [self parseStopLines:stop];
            [stops addObject:stop];
        }
    }
    
    return stops;
}

- (void)parseStopLines:(BusStopE *)stop {
    //Parse departures and lines
    if (stop.lines) {
        NSMutableArray *stopLinesArray = [@[] mutableCopy];
        for (NSString *lineString in stop.lines) {
            StopLine *line = [StopLine new];
            NSArray *info = [lineString asa_stringsBySplittingOnString:@":"];
            if (info.count >= 2) {
                line.name = info[1];
                line.destination = info[1];
                NSString *lineCode = info[0];
                line.fullCode = lineCode;
                line.code = [ReittiStringFormatterE parseBusNumFromLineCode:lineCode];
                
                if (lineCode.length == 7) {
                    line.direction = [lineCode substringWithRange:NSMakeRange(6, 1)];
                }
            }
            line.lineEnd = line.destination;
            [stopLinesArray addObject:line];
        }
        
        stop.lines = stopLinesArray;
    }
}

-(NSString *)stopFetchErrorMessageForError:(NSError *)error{
    if (!error) return nil;
    if (error.code == -1009) {
        return @"No internet connection.";
    }else{
        return @"Fetching departures failed";
    }
}

-(NSArray *)routesFromJSON:(NSData *)objectNotation error:(NSError **)error{
    NSError *localError = nil;
    NSArray *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *routes = [[NSMutableArray alloc] init];
    
    for (NSArray *routeArray in parsedObject) {
        for (NSDictionary *routeDict in routeArray) {
            Route *route = [[Route alloc] init];
            route.routeDurationInSeconds = [self objectOrNilForKey:@"duration" fromDictionary:routeDict];
            route.routeLength = [self objectOrNilForKey:@"length" fromDictionary:routeDict];
            NSArray *legsArray = [self objectOrNilForKey:@"legs" fromDictionary:routeDict];
            if (!legsArray) continue;
            
            route.routeLegs = [self mapRouteLegsFromArray:legsArray];
            
            @try {
                for (RouteLeg *leg in route.routeLegs) {
                    @try {
                        if (!leg.lineCode)
                            continue;
                        
                        leg.lineName = [WatchHslApi parseBusNumFromLineCode:leg.lineCode];
                    }
                    @catch (NSException *exception) {
                        leg.lineName = leg.lineCode;
                    }
                }
            }
            @catch (NSException *exception) {}
            
            [routes addObject:route];
            
            break;
        }
    }
    
    return routes;
}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in arrayResponse) {
        //NSLog(@"a dictionary %@",legDict);
        RouteLeg *leg = [[RouteLeg alloc] initFromHSLandTREDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}


- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}



//#pragma mark - Datasource value mapping

-(NSDictionary *)apiRequestParametersDictionaryForRouteOptions:(NSDictionary *)searchOptions{
    NSMutableDictionary *parametersDict = [@{} mutableCopy];
    
    if (!searchOptions)
        return parametersDict;
    
    parametersDict = [[[HSLRouteOptionManager sharedManager] apiRequestParametersDictionaryForRouteOptions:searchOptions] mutableCopy];
    [parametersDict setObject:@"3" forKey:@"show"];
    
    //Make sure there is default
    [parametersDict removeObjectForKey:@"date"];
    [parametersDict removeObjectForKey:@"time"];
    [parametersDict removeObjectForKey:@"timetype"];
    
    return parametersDict;
}


//Expected format is XXXX(X) X
//Parsing logic https://github.com/HSLdevcom/navigator-proto/blob/master/src/routing.coffee#L40
//Original logic - http://developer.reittiopas.fi/pages/en/http-get-interface/frequently-asked-questions.php
+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    //TODO: Test with 1230 for weird numbers of the same 24 bus.
    //    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
    //    NSString *code = [codes objectAtIndex:0];
    
    //Line codes from HSL live could be only 4 characters
    if (lineCode.length < 4)
        return lineCode;
    
    //Can be assumed a metro
    if ([lineCode hasPrefix:@"1300"])
        return @"Metro";
    
    //Can be assumed a ferry
    if ([lineCode hasPrefix:@"1019"])
        return @"Ferry";
    
    //Can be assumed a train line
    if (([lineCode hasPrefix:@"3001"] || [lineCode hasPrefix:@"3002"]) && lineCode.length > 4) {
        NSString * trainLineCode = [lineCode substringWithRange:NSMakeRange(4, 1)];
        if (trainLineCode != nil && trainLineCode.length > 0)
            return trainLineCode;
    }
    
    //2-4. character = line code (e.g. 102)
    NSString *codePart = [lineCode substringWithRange:NSMakeRange(1, 3)];
    while ([codePart hasPrefix:@"0"]) {
        codePart = [codePart substringWithRange:NSMakeRange(1, codePart.length - 1)];
    }
    
    if (lineCode.length <= 4)
        return codePart;
    
    //5 character = letter variant (e.g. T)
    NSString *firstLetterVariant = [lineCode substringWithRange:NSMakeRange(4, 1)];
    if ([firstLetterVariant isEqualToString:@" "])
        return codePart;
    
    if (lineCode.length <= 5)
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    //6 character = letter variant or numeric variant (ignore number variant)
    NSString *secondLetterVariant = [lineCode substringWithRange:NSMakeRange(5, 1)];
    if ([secondLetterVariant isEqualToString:@" "] || [secondLetterVariant intValue])
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    return [NSString stringWithFormat:@"%@%@%@", codePart, firstLetterVariant, secondLetterVariant];
}


@end
