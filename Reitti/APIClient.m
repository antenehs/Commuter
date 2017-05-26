//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 31/1/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import "APIClient.h"
#import "ReittiStringFormatter.h"
#import "GraphQLQuery.h"

@implementation APIClient

@synthesize apiBaseUrl;

-(id)init{
    self = [super init];
    
    if (self) {
#ifndef APPLE_WATCH
        RKLogConfigureByName("RestKit", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/Network", RKLogLevelCritical);
#endif
        /* Debug
        RKLogConfigureByName("RestKit", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelCritical);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
        */
    }
    
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

-(void)doApiFetchWithOutMappingWithParams:(NSDictionary *)params andCompletionBlock:(ActionBlock)completionBlock{
    
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSString *apiURL = [NSString stringWithFormat:@"%@?%@",apiBaseUrl,parameters];
    
    NSURL *url = [NSURL URLWithString:apiURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(data, error);
                });
                
            }] resume];
}

-(void)doGraphQlQueryWithoutMapping:(NSString *)query andCompletionBlock:(ActionBlock)completionBlock {
    GraphQLQuery *dataObject = [[GraphQLQuery alloc] init];
    dataObject.query = query;
    
    NSError *error;
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:apiBaseUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
//    NSDictionary *requestData = [GraphQLQuery requestMappingDictionary];
    NSDictionary *requestData = @{ @"query" : query };
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(data, error);
        });
    }];
    
    [postDataTask resume];
}

-(void)doGraphQlQuery:(NSString *)query mappingDiscriptor:(MappingDescriptor *)mappingDiscriptor andCompletionBlock:(ActionBlock)completionBlock {
#ifndef APPLE_WATCH
    RKResponseDescriptor *responseDesc = [APIClient rkResponseDiscriptorForMappingDescriptor:mappingDiscriptor];
    
    [self doGraphQlQuery:query responseDiscriptor:responseDesc andCompletionBlock:completionBlock];
#else
    [self doGraphQlQueryWithoutMapping:query andCompletionBlock:^(NSData *responseData, NSError *error){
        NSArray *responseArray = [APIClient objectsFromJSONData:responseData withMappingDescriptor:mappingDiscriptor];
        completionBlock(responseArray, error);
    }];
#endif
//    [self doApiFetchWithOutMappingWithParams:searchParameters andCompletionBlock:^(NSData *responseData, NSError *error){
//        if (!error) {
//            //DO Mapping
//            completionBlock(responseData, nil);
//        }else{
//            completionBlock(nil, error);
//        }
//    }];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDescriptor:(MappingDescriptor *)mappingDescriptor andCompletionBlock:(ActionBlock)completionBlock {
#ifndef APPLE_WATCH
    RKResponseDescriptor *responseDesc = [APIClient rkResponseDiscriptorForMappingDescriptor:mappingDescriptor];
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDesc isJsonResponse:YES andCompletionBlock:completionBlock];
#endif
}

#ifndef APPLE_WATCH
-(void)doGraphQlQuery:(NSString *)query responseDiscriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock {
    
    GraphQLQuery *dataObject = [[GraphQLQuery alloc] init];
    dataObject.query = query;
    
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    RKObjectMapping *requestMapping =  [[GraphQLQuery requestMapping] inverseMapping];
    
    [objectManager addRequestDescriptor: [RKRequestDescriptor requestDescriptorWithMapping:requestMapping objectClass:[GraphQLQuery class] rootKeyPath:nil method:RKRequestMethodPOST]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
    [objectManager setRequestSerializationMIMEType: RKMIMETypeJSON];
    
    [objectManager postObject:dataObject
                        path:@""
                        parameters:nil
                        success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
//                            NSLog(@"It Worked: %@", [mappingResult array]);
                            completionBlock(mappingResult.array, nil);
                        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
//                            NSLog(@"It Failed: %@", error);
                            completionBlock(nil, error);
                        }];
}

-(void)doApiFetchWithParams:(NSDictionary *)params responseDiscriptor:(RKResponseDescriptor *)responseDescriptor isJsonResponse:(BOOL)isJson andCompletionBlock:(ActionBlock)completionBlock{
    NSURL *baseURL = [NSURL URLWithString:apiBaseUrl];
    AFHTTPClient * client = [AFHTTPClient clientWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:isJson ? RKMIMETypeJSON : RKMIMETypeXML];
    [RKMIMETypeSerialization registerClass:isJson ? [RKNSJSONSerialization class] : [RKXMLReaderSerialization class] forMIMEType:isJson ? @"text/plain" : @"text/xml"];
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    //Construct params query string
    NSString *parameters = [APIClient formatRestQueryFilterForDictionary:params];
    if ([parameters respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        parameters = [parameters stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
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

-(void)doJsonApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doXmlApiFetchWithParams:(NSDictionary *)params responseDescriptor:(RKResponseDescriptor *)responseDescriptor andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:NO andCompletionBlock:completionBlock];
}

-(void)doApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath isJsonResponse:(BOOL)isJson andCompletionBlock:(ActionBlock)completionBlock{
    RKObjectMapping *responseMApping = [RKObjectMapping mappingForClass:mapToClass];
    [responseMApping addAttributeMappingsFromDictionary:mapping];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMApping method:RKRequestMethodGET pathPattern:nil keyPath:keyPath statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    [self doApiFetchWithParams:params responseDiscriptor:responseDescriptor isJsonResponse:isJson andCompletionBlock:completionBlock];
}

-(void)doJsonApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock{
    
    [self doApiFetchWithParams:params mappingDictionary:mapping mapToClass:mapToClass mapKeyPath:keyPath isJsonResponse:YES andCompletionBlock:completionBlock];
}

-(void)doXmlApiFetchWithParams:(NSDictionary *)params mappingDictionary:(NSDictionary *)mapping mapToClass:(Class)mapToClass mapKeyPath:(NSString *)keyPath andCompletionBlock:(ActionBlock)completionBlock{
    [self doApiFetchWithParams:params mappingDictionary:mapping mapToClass:mapToClass mapKeyPath:keyPath isJsonResponse:NO andCompletionBlock:completionBlock];
}
#endif

#pragma mark - Dictioany Mapping
+(NSArray *)objectsFromJSONData:(NSData *)jsonData withMappingDescriptor:(MappingDescriptor *)mappingDescriptor {
    NSError *localError = nil;
    id parsedObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&localError];
    
    if (localError != nil) { return nil; }
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSArray *objectArray = nil;
    if ([parsedObject isKindOfClass:[NSArray class]]) {
        if (mappingDescriptor.path && ![mappingDescriptor.path isEqualToString:@""]) {
            NSLog(@"Path is set for mapping but recieved an array");
            return nil;
        } else {
            objectArray = parsedObject;
        }
    } else if ([parsedObject isKindOfClass:[NSDictionary class]]) {
        if (mappingDescriptor.path && ![mappingDescriptor.path isEqualToString:@""]) {
            id dictionaryArray = [(NSDictionary *)parsedObject valueForKeyPath:mappingDescriptor.path];
            if (!dictionaryArray || ![dictionaryArray isKindOfClass:[NSArray class]]) return nil;
            
            objectArray = dictionaryArray;
        } else {
            objectArray = @[parsedObject];
        }
    } else {
        NSLog(@"Unknown object type");
        return nil;
    }
    
    if(!objectArray) return nil;
    
    for (NSDictionary *dict in objectArray) {
        if ([mappingDescriptor.classType conformsToProtocol:@protocol(DictionaryMappable)]) {
            id mappedObject = [(Class<DictionaryMappable>)mappingDescriptor.classType modelObjectWithDictionary:dict];
            
            if (mappedObject) { [objects addObject:mappedObject]; }
            else {
                NSLog(@"Class is not mappable");
                return nil;
            }
        } else {
            NSLog(@"Class is not mappable");
            return nil;
        }
        
    }
    
    return objects;
}

#pragma mark - Mapping helpers
#ifndef APPLE_WATCH
+(RKResponseDescriptor *)rkResponseDiscriptorForMappingDescriptor:(MappingDescriptor *)mappingDescriptor {
    
    return [RKResponseDescriptor responseDescriptorWithMapping:[APIClient rKobjectMappingFromMappingDescriptor:mappingDescriptor]
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:mappingDescriptor.path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

+(RKObjectMapping *)rKobjectMappingFromMappingDescriptor:(MappingDescriptor *)mappingDescriptor {
    RKObjectMapping* mapping = [RKObjectMapping mappingForClass:mappingDescriptor.classType];
    [mapping addAttributeMappingsFromDictionary:mappingDescriptor.mappingDictionary];
    
    for (MappingRelationShip *relation in mappingDescriptor.relationShips) {
        MappingDescriptor *mappindDesc = [relation.mappableClass mappingDescriptorForPath:nil];
        
        [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:relation.fromKeyPath
                                                                                toKeyPath:relation.toKeypath
                                                                              withMapping:[APIClient rKobjectMappingFromMappingDescriptor:mappindDesc]]];
    }
    
    return mapping;
}
#endif


@end
