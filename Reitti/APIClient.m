//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "RKXMLReaderSerialization.h"
#import "ReittiStringFormatter.h"

@implementation APIClient

@synthesize stopList;
@synthesize nearByStopList;
@synthesize lineInfoList;
@synthesize geoCodeList;
@synthesize reverseGeoCodeList;
@synthesize routeList;
@synthesize disruptionList;
@synthesize requestedKey;
@synthesize apiBaseUrl;

-(id)init{
    return self;
}

#pragma mark - Rest api helpers
+(NSString *)formatRestQueryFilterForDictionary:(NSDictionary *)paramsDictionary{
    if (paramsDictionary == nil)
        return @"";
    
    NSMutableArray *paramsArray = [@[] mutableCopy];
    for (NSString *key in paramsDictionary.allKeys) {
        [paramsArray addObject:[NSString stringWithFormat:@"%@=%@",key, paramsDictionary[key]]];
    }
    
    return [ReittiStringFormatter commaSepStringFromArray:paramsArray withSeparator:@"&"];
}

#pragma mark - Generic fetch method

-(void)doApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping andCompletionBlock:(ActionBlock)completionBlock{
    
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *responseMApping = [RKObjectMapping mappingForClass:[Route class]];
    [responseMApping addAttributeMappingsFromDictionary:mapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMApping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    parameters = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?%@",apiBaseUrl,parameters];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        completionBlock(mappingResult.array, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}


#pragma mark - api fetch methods

-(void)searchRouteForCoordinates:(NSString *)fromCoordinate andToCoordinate:(NSString *)toCoordinate andParams:(NSDictionary *)params{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *routeMapping = [RKObjectMapping mappingForClass:[Route class]];
    [routeMapping addAttributeMappingsFromDictionary:@{
                                                     @"length" : @"unMappedRouteLength",
                                                     @"duration" : @"unMappedRouteDurationInSeconds",
                                                     @"legs" : @"unMappedRouteLegs"
                                                     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:routeMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
    fromCoordinate = [fromCoordinate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    fromCoordinate = [fromCoordinate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    toCoordinate = [toCoordinate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    toCoordinate = [toCoordinate stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    parameters = [parameters stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSString *apiURL = [NSString stringWithFormat:@"%@?request=route&epsg_in=4326&epsg_out=4326&user=asacommuterroutes&pass=rebekah&format=json&detail=full&from=%@&to=%@&date=%@&time=%@&timetype=%@&optimize=%@&show=%d",apiBaseUrl, fromCoordinate,toCoordinate,date,time,timeType,optimize,numOfResults];
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?request=route&epsg_in=4326&epsg_out=4326&user=asacommuterstops&pass=rebekah&format=json&from=%@&to=%@&%@",apiBaseUrl, fromCoordinate,toCoordinate,parameters];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.routeList = mappingResult.array;
        for (Route *route in self.routeList) {
            route.routeLegs = [self mapRouteLegsFromArray:route.unMappedRouteLegs];
            NSLog(@"route length is %@", route.routeLength);
            route.routeLength = [route.unMappedRouteLength objectAtIndex:0];
            route.routeDurationInSeconds = [route.unMappedRouteDurationInSeconds objectAtIndex:0];
        }
       
        //NSLog(@"Mapped Legs are %@",[leg.legLocations objectAtIn]);
        [self RouteSearchDidComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Operation failed with error: %@", error);
//        NSLog(@"Response ERROR ASA:%@", error);
        [self RouteSearchFailed:(int)error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

-(NSArray *)mapRouteLegsFromArray:(NSArray *)arrayResponse{
    NSMutableArray *legsArray = [[NSMutableArray alloc] init];
    int legOrder = 0;
    for (NSDictionary *legDict in [arrayResponse objectAtIndex:0]) {
        //NSLog(@"a dictionary %@",legDict);
        RouteLeg *leg = [[RouteLeg alloc] initFromDictionary:legDict];
        leg.legOrder = legOrder;
        [legsArray addObject:leg];
        legOrder++;
    }
    
    return legsArray;
}

-(void)searchGeocodeForKey:(NSString *)key{
    self.requestedKey = key;
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[GeoCode class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"locType" : @"locType",
                                                     @"locTypeId" : @"locTypeId",
                                                     @"name" : @"name",
                                                     @"city" : @"city",
                                                     @"matchedName" : @"matchedName",
                                                     @"lang" : @"lang",
                                                     @"coords" : @"coords",
                                                     @"details" : @"details"
                                                     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
    key = [key stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?request=geocode&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&format=json&key=%@", apiBaseUrl, key];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.geoCodeList = mappingResult.array;
        [self GeocodeSearchDidComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self GeocodeSearchFailed:(int)error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

//Reverse geocode
-(void)searchAddressForCoordinate:(NSString *)coords{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[GeoCode class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"locType" : @"locType",
                                                     @"locTypeId" : @"locTypeId",
                                                     @"name" : @"name",
                                                     @"city" : @"city",
                                                     @"lang" : @"lang",
                                                     @"coords" : @"coords",
                                                     @"details" : @"details"
                                                     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
    coords = [coords stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    coords = [coords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?request=reverse_geocode&epsg_in=4326&epsg_out=4326&user=commuterreversegeo&pass=rebekah&format=json&coordinate=%@", apiBaseUrl, coords];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.reverseGeoCodeList = mappingResult.array;
        [self ReverseGeocodeSearchDidComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self ReverseGeocodeSearchFailed:(int)error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}


-(void)getStopInfoForCode:(NSString *)code{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[BusStop class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"code" : @"code",
                                                     @"code_short" : @"code_short",
                                                     @"name_fi" : @"name_fi",
                                                     @"name_sv" : @"name_sv",
                                                     @"city_fi" : @"city_fi",
                                                     @"city_sv" : @"city_sv",
                                                     @"lines" : @"lines",
                                                     @"coords" : @"coords",
                                                     @"wgs_coords" : @"wgs_coords",
                                                     @"accessibility" : @"accessibility",
                                                     @"departures" : @"departures",
                                                     @"timetable_link" : @"timetable_link",
                                                     @"omatlahdot_link" : @"omatlahdot_link",
                                                     @"address_fi" : @"address_fi",
                                                     @"address_sv" : @"address_sv"
                                                     }];
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
    code = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    code = [code stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?request=stop&epsg_in=4326&epsg_out=4326&user=asacommuterstops&pass=rebekah&dep_limit=20&time_limit=360&format=json&code=%@", apiBaseUrl, code];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.stopList = mappingResult.array;
        [self StopFetchDidComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self StopFetchFailed:(int)error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

-(void)getStopsInArea:(CLLocationCoordinate2D)center forDiameter:(int)diameter{
    NSString * centerString = [NSString stringWithFormat:@"%f,%f", center.longitude, center.latitude];
    
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[BusStopShort class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"code" : @"code",
                                                     @"codeShort" : @"codeShort",
                                                     @"name" : @"name",
                                                     @"city" : @"city",
                                                     @"coords" : @"coords",
                                                     @"address" : @"address",
                                                     @"dist" : @"distance"
                                                     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
    //    qstr = [qstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    //epsg_in=4326 - WGS84
    NSString *apiURL = [NSString stringWithFormat:@"%@?request=stops_area&epsg_in=4326&epsg_out=4326&user=asacommuternearby&pass=rebekah&format=json&limit=60&center_coordinate=%@&diameter=%d",apiBaseUrl, centerString, diameter];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.nearByStopList = mappingResult.array;
        [self StopInAreaFetchDidComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self StopInAreaFetchFailed:(int)error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];

}

- (void)getStopsFromPubTransInArea:(CLLocationCoordinate2D)center forDiameter:(int)diameter{
    NSString * longString = [NSString stringWithFormat:@"%f", center.longitude];
    NSString * latString = [NSString stringWithFormat:@"%f", center.latitude];
    
//    diameter = 200;
    
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.pubtrans.it/hsl/stops?lon=%@&lat=%@&rad=%d&cid=asareitticlient&dup=1&max=20", longString, latString, diameter];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
//    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self StopInAreaFetchFromPubtransFailed:error];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self StopInAreaFetchFromPubtransDidComplete:data];
            });
        }
    }];
}

-(void)getDisruptions{
    
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/1_2_0/"];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeXML];
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/xml"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[Disruption class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"id" : @"disruptionId",
                                                     @"type" : @"disruptionType",
                                                     @"source" : @"disruptionSource",
                                                     @"INFO.TEXT.text" : @"disruptionInfo",
                                                     @"VALIDITY.from" : @"disruptionStartTime",
                                                     @"VALIDITY.to" : @"disruptionEndTime",
                                                     @"TARGETS.LINE.id" : @"lineId",
                                                     @"TARGETS.LINE.direction" : @"lineDirection",
                                                     @"TARGETS.LINE.linetype" : @"lineType",
                                                     @"TARGETS.LINE.text" : @"lineName"
                                                     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"DISRUPTIONS.DISRUPTION" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
    //    qstr = [qstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    ///241020141800
    NSString *apiURL = @"http://www.poikkeusinfo.fi/xml/v2/en";
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.disruptionList = mappingResult.array;
//        NSLog(@"Disruptions: %@",[[disruptionList objectAtIndex:0] disruptionEndTime]);
//        NSLog(@"Disruptions: %@",[[disruptionList objectAtIndex:0] disruptionInfo]);
//        NSLog(@"Disruptions: %@",[[disruptionList objectAtIndex:0] disruptionStartTime]);
        [self DisruptionFetchComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Operation failed with error: %@", error);
//        NSLog(@"Response ERROR ASA:%@", error);
        [self DisruptionFetchFailed:(int)error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
    
}

-(void)getLineInformation:(NSString *)codeList{
    
    //Do the API call
    codeList = [codeList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    NSString *urlAsString = [NSString stringWithFormat:@"%@?request=lines&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&format=json&query=%@",apiBaseUrl,codeList];
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    //    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self LineInfoFetchFailed:error];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self LineInfoFetchDidComplete:data];
            });
        }
    }];
    
//    
//    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
//    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
//    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
//    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
//    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
//    
//    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[LineInfo class]];
//    [setMapping addAttributeMappingsFromDictionary:@{
//                                                     @"code_short" : @"code_short"
//                                                     }];
//    
//    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
//    
//    codeList = [codeList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
//    
//    NSString *apiURL = [NSString stringWithFormat:@"%@?request=lines&user=asareitti&pass=rebekah&format=txt&query=%@",apiBaseUrl,codeList];
//    
//    NSURL *URL = [NSURL URLWithString:apiURL];
//    
//    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
//    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
//    
//    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//        self.lineInfoList = mappingResult.array;
//        [self LineInfoFetchDidComplete];
//        
//    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//        RKLogError(@"Operation failed with error: %@", error);
//        NSLog(@"Response ERROR ASA:%@", error);
//        [self LineInfoFetchFailed];
//    }];
//    
//    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

#pragma mark - PubTrans Methods
- (void)getAllLiveVehiclesFromPubTrans:(NSString *)lineCodes{
    NSString *urlAsString = [NSString stringWithFormat:@"http://www.pubtrans.it/hsl/vehicles?trams=0&longdistancetrains=0"];
    if (lineCodes != nil) {
        //convert unsafe strings in search string
        lineCodes = [lineCodes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        lineCodes = [lineCodes stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
        urlAsString = [NSString stringWithFormat:@"http://www.pubtrans.it/hsl/vehicles?trams=0&longdistancetrains=0&lines=%@", lineCodes];
    }
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
//    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self VehiclesFetchFromPubtransFailed:error];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self VehiclesFetchFromPubtransComplete:data];
            });
        }
    }];
}

#pragma mark - HSL Live Methods
- (void)getAllLiveVehiclesFromHSLLive:(NSString *)lineCodes{
    
    NSString *urlAsString = [NSString stringWithFormat:@"http://83.145.232.209:10001/?type=vehicles&lng1=22&lat1=59&lng2=26&lat2=62&online=1&vehicletype=0,1,2,3,5"];
    
    if (lineCodes != nil) {
        urlAsString = [NSString stringWithFormat:@"http://83.145.232.209:10001/?type=vehicles&lng1=22&lat1=59&lng2=26&lat2=62&online=1&vehicletype=0,1,2,3,5&lines=%@", lineCodes];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
//    NSLog(@"%@", urlAsString);
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self VehiclesFetchFromHslLiveFailed:error];
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self VehiclesFetchFromHslLiveComplete:data];
            });
        }
    }];
}


#pragma mark - Test method

-(void) testHSLAPI{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[BusStop class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"code": @"stopId",
                                                     @"name_fi": @"address"
                                                     }];
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    //convert unsafe strings in search string
//    qstr = [qstr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?request=stop&user=asareitti&pass=rebekah&format=json&code=2222222",apiBaseUrl];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //RKLogInfo(@"Load collection of Venues: %@", mappingResult.array);
        NSArray *setList = mappingResult.array;
        NSLog(@"Response:%@", setList);
        [self StopFetchDidComplete];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
            NSLog(@"Response ERROR ASA:%@", error);
//        self.requestError = error;
        [self StopFetchFailed:0];
    }];
    
    //[objectRequestOperation start];
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

#pragma mark - completion methods
- (void)StopFetchDidComplete{}
- (void)StopFetchFailed:(int)errorCode{}
- (void)StopInAreaFetchDidComplete{}
- (void)StopInAreaFetchFailed:(int)errorCode{}
- (void)LineInfoFetchDidComplete:(NSData *)objectNotation{}
- (void)LineInfoFetchFailed:(NSError *)error{}
- (void)GeocodeSearchDidComplete{}
- (void)GeocodeSearchFailed:(int)errorCode{}
- (void)ReverseGeocodeSearchDidComplete{}
- (void)ReverseGeocodeSearchFailed:(int)errorCode{}
- (void)RouteSearchDidComplete{}
- (void)RouteSearchFailed:(int)errorCode{}
- (void)DisruptionFetchComplete{}
- (void)DisruptionFetchFailed:(int)errorCode{}
- (void)StopInAreaFetchFromPubtransDidComplete:(NSData *)objectNotation{}
- (void)StopInAreaFetchFromPubtransFailed:(NSError *)error{}
- (void)VehiclesFetchFromPubtransComplete:(NSData *)objectNotation{}
- (void)VehiclesFetchFromPubtransFailed:(NSError *)error{}
- (void)VehiclesFetchFromHslLiveComplete:(NSData *)objectNotation{}
- (void)VehiclesFetchFromHslLiveFailed:(NSError *)error{}

- (void)dealloc
{
    NSLog(@"Communication:This bitchass ARC deleted my UIView.");
}

@end
