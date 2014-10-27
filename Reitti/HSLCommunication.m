//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "HSLCommunication.h"
#import "RKXMLReaderSerialization.h"

@implementation HSLCommunication

@synthesize delegate;
@synthesize stopList;
@synthesize nearByStopList;
@synthesize lineInfoList;
@synthesize geoCodeList;
@synthesize routeList;
@synthesize disruptionList;
@synthesize requestedKey;

-(id)init{
    return self;
}

-(void)searchRouteForCoordinates:(NSString *)fromCoordinate andToCoordinate:(NSString *)toCoordinate  time:(NSString *)time andDate:(NSString *)date andTimeType:(NSString *)timeType andOptimize:(NSString *)optimize{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
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
    
    NSString *apiURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=route&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&format=json&detail=full&from=%@&to=%@&date=%@&time=%@&timetype=%@&optimize=%@&show=5", fromCoordinate,toCoordinate,date,time,timeType,optimize];
    
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
        [delegate hslRouteSearchDidComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self.delegate hslRouteSearchFailed:error.code];
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
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
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
    
    NSString *apiURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=geocode&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&format=json&key=%@", key];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.geoCodeList = mappingResult.array;
        [delegate hslGeocodeSearchDidComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self.delegate hslGeocodeSearchFailed:error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

-(void)getStopInfoForCode:(NSString *)code{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
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
    
    NSString *apiURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=stop&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&dep_limit=20&time_limit=360&format=json&code=%@", code];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.stopList = mappingResult.array;
        [delegate hslStopFetchDidComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self.delegate hslStopFetchFailed:error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

-(void)getStopsInArea:(CLLocationCoordinate2D)center forDiameter:(int)diameter{
    NSString * centerString = [NSString stringWithFormat:@"%f,%f", center.longitude, center.latitude];
    
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
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
    NSString *apiURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=stops_area&epsg_in=4326&epsg_out=4326&user=asareitti&pass=rebekah&format=json&limit=100&center_coordinate=%@&diameter=%d", centerString, diameter];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.nearByStopList = mappingResult.array;
        [delegate hslStopInAreaFetchDidComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self.delegate hslStopInAreaFetchFailed:error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];

}

-(void)getDisruptions{
    
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
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
        NSLog(@"Disruptions: %@",[[disruptionList objectAtIndex:0] disruptionEndTime]);
        NSLog(@"Disruptions: %@",[[disruptionList objectAtIndex:0] disruptionInfo]);
        NSLog(@"Disruptions: %@",[[disruptionList objectAtIndex:0] disruptionStartTime]);
        [delegate hslDisruptionFetchComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self.delegate hslDisruptionFetchFailed:error.code];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
    
}

-(void)getLineInformation:(NSString *)codeList{
    
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *setMapping = [RKObjectMapping mappingForClass:[LineInfo class]];
    [setMapping addAttributeMappingsFromDictionary:@{
                                                     @"code_short" : @"code_short"
                                                     }];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:setMapping method:RKRequestMethodGET pathPattern:nil keyPath:@"" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    codeList = [codeList stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
    
    NSString *apiURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=lines&user=asareitti&pass=rebekah&format=txt&query=%@",codeList];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.lineInfoList = mappingResult.array;
        [delegate hslLineInfoFetchDidComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
        NSLog(@"Response ERROR ASA:%@", error);
        [self.delegate hslLineInfoFetchFailed:self];
    }];
    
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

#pragma mark - Test method

-(void) testHSLAPI{
    //Do the API call
    NSURL *baseURL = [NSURL URLWithString:@"http://api.reittiopas.fi/hsl/prod/"];
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
    
    NSString *apiURL = [NSString stringWithFormat:@"http://api.reittiopas.fi/hsl/prod/?request=stop&user=asareitti&pass=rebekah&format=json&code=2222222"];
    
    NSURL *URL = [NSURL URLWithString:apiURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    RKObjectRequestOperation *objectRequestOperation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[ responseDescriptor ]];
    
    [objectRequestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        //RKLogInfo(@"Load collection of Venues: %@", mappingResult.array);
        NSArray *setList = mappingResult.array;
        NSLog(@"Response:%@", setList);
        [self.delegate hslStopFetchDidComplete:self];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        RKLogError(@"Operation failed with error: %@", error);
            NSLog(@"Response ERROR ASA:%@", error);
//        self.requestError = error;
        [self.delegate hslStopFetchFailed:self];
    }];
    
    //[objectRequestOperation start];
    [objectManager enqueueObjectRequestOperation:objectRequestOperation];
}

- (void)dealloc
{
    NSLog(@"HSLCommunication:This bitchass ARC deleted my UIView.");
}

@end